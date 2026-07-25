import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/sample_dashboard_data.dart';
import '../services/auth_service.dart';
import '../services/supabase_service.dart';

class PathwayData {
  const PathwayData({
    required this.occupation,
    required this.targetCountry,
    required this.progress,
    required this.hasCompletedSetup,
  });

  final String occupation;
  final String targetCountry;
  final double progress;

  /// False until the applicant has confirmed a pathway at least once.
  /// Drives whether the pathway editor treats this as first-time setup
  /// (no reset warning, always-enabled confirm) or an update (warns that
  /// progress and gaps will be recalculated).
  final bool hasCompletedSetup;

  PathwayData copyWith({
    String? occupation,
    String? targetCountry,
    double? progress,
    bool? hasCompletedSetup,
  }) {
    return PathwayData(
      occupation: occupation ?? this.occupation,
      targetCountry: targetCountry ?? this.targetCountry,
      progress: progress ?? this.progress,
      hasCompletedSetup: hasCompletedSetup ?? this.hasCompletedSetup,
    );
  }
}

/// Kept as a synchronous [Notifier] (not [AsyncNotifier]) deliberately —
/// every screen that reads pathwayProvider does so synchronously, and
/// converting to async would mean touching every one of those call sites.
/// Instead: show sensible defaults instantly, then hydrate from Supabase
/// in the background and overwrite state once the real row loads. Writes
/// go the same way — update local state immediately, persist after.
///
/// This is a deliberate simplification: a failed background sync or save
/// currently fails silently rather than surfacing a "not saved" indicator.
/// Good enough for this pass; worth revisiting once there's a UI pattern
/// for "saving…" states across the app.
class PathwayNotifier extends Notifier<PathwayData> {
  @override
  PathwayData build() {
    _hydrate();
    return PathwayData(
      occupation: occupationOptions.first,
      targetCountry: targetCountryOptions.first,
      progress: 0.65,
      hasCompletedSetup: false,
    );
  }

  Future<void> _hydrate() async {
    if (!SupabaseService.isReady) return;
    final userId = AuthService.currentUser?.id;
    if (userId == null) return;
    try {
      final row = await SupabaseService.client
          .from('pathways')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      if (row == null) return;
      state = PathwayData(
        occupation: row['occupation'] as String,
        targetCountry: row['target_country'] as String,
        progress: (row['progress'] as num).toDouble(),
        hasCompletedSetup: row['has_completed_setup'] as bool,
      );
    } catch (_) {
      // Stay on defaults — see class doc.
    }
  }

  void updatePathway({required String occupation, required String targetCountry}) {
    state = state.copyWith(
      occupation: occupation,
      targetCountry: targetCountry,
      progress: 0,
      hasCompletedSetup: true,
    );
    _persist();
  }

  Future<void> _persist() async {
    if (!SupabaseService.isReady) return;
    final userId = AuthService.currentUser?.id;
    if (userId == null) return;
    try {
      await SupabaseService.client.from('pathways').upsert({
        'user_id': userId,
        'occupation': state.occupation,
        'target_country': state.targetCountry,
        'progress': state.progress,
        'has_completed_setup': state.hasCompletedSetup,
      });
    } catch (_) {
      // Stay on the optimistic local state — see class doc.
    }
  }
}

final pathwayProvider = NotifierProvider<PathwayNotifier, PathwayData>(PathwayNotifier.new);
