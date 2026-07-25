import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/supabase_service.dart';

class NotificationPrefs {
  const NotificationPrefs({required this.emailEnabled, required this.pushEnabled});

  final bool emailEnabled;
  final bool pushEnabled;

  NotificationPrefs copyWith({bool? emailEnabled, bool? pushEnabled}) {
    return NotificationPrefs(
      emailEnabled: emailEnabled ?? this.emailEnabled,
      pushEnabled: pushEnabled ?? this.pushEnabled,
    );
  }
}

/// Same pattern as PathwayNotifier: synchronous with background
/// hydrate/persist, so Account settings can render instantly with sane
/// defaults rather than the toggles needing to be async-loading widgets.
class NotificationPrefsNotifier extends Notifier<NotificationPrefs> {
  @override
  NotificationPrefs build() {
    _hydrate();
    return const NotificationPrefs(emailEnabled: true, pushEnabled: true);
  }

  Future<void> _hydrate() async {
    if (!SupabaseService.isReady) return;
    final userId = AuthService.currentUser?.id;
    if (userId == null) return;
    try {
      final row = await SupabaseService.client
          .from('profiles')
          .select('email_notifications, push_notifications')
          .eq('id', userId)
          .maybeSingle();
      if (row == null) return;
      state = NotificationPrefs(
        emailEnabled: row['email_notifications'] as bool,
        pushEnabled: row['push_notifications'] as bool,
      );
    } catch (_) {
      // Stay on defaults — a failed hydrate shouldn't block the settings page.
    }
  }

  void setEmailEnabled(bool value) {
    state = state.copyWith(emailEnabled: value);
    _persist();
  }

  void setPushEnabled(bool value) {
    state = state.copyWith(pushEnabled: value);
    _persist();
  }

  Future<void> _persist() async {
    if (!SupabaseService.isReady) return;
    final userId = AuthService.currentUser?.id;
    if (userId == null) return;
    try {
      await SupabaseService.client.from('profiles').update({
        'email_notifications': state.emailEnabled,
        'push_notifications': state.pushEnabled,
      }).eq('id', userId);
    } catch (_) {
      // Optimistic local state stands even if the write failed — same
      // simplification as the rest of this app's sync notifiers.
    }
  }
}

final notificationPrefsProvider =
    NotifierProvider<NotificationPrefsNotifier, NotificationPrefs>(NotificationPrefsNotifier.new);
