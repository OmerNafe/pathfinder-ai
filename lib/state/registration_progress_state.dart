import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/supabase_service.dart';

/// Generic steps common to virtually every professional registration body's
/// process — create an account, submit evidence, get assessed, pay, wait,
/// receive the outcome. Exact steps/fees/timelines vary by body; this is a
/// structured general guide, not the specific body's own published process.
List<String> registrationStepLabels(String bodyName) => [
      'Create an account with $bodyName',
      'Submit your identity and qualification documents for verification',
      'Complete any required competency or skills assessment',
      'Pay the $bodyName application/registration fee',
      'Respond to any requests for additional evidence',
      'Receive your registration or license confirmation',
    ];

/// Tracks which steps are complete, keyed by "country|category|stepIndex" so
/// progress is scoped to the applicant's current pathway. Same sync
/// hydrate/persist pattern as PathwayNotifier, backed by the shared
/// checklist_progress table (namespace: 'registration').
class RegistrationProgressNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    _hydrate();
    return {};
  }

  Future<void> _hydrate() async {
    if (!SupabaseService.isReady) return;
    final userId = AuthService.currentUser?.id;
    if (userId == null) return;
    try {
      final rows = await SupabaseService.client
          .from('checklist_progress')
          .select('step_key')
          .eq('user_id', userId)
          .eq('namespace', 'registration');
      state = {for (final row in rows) row['step_key'] as String};
    } catch (_) {
      // Stay on defaults — a failed hydrate shouldn't block the page.
    }
  }

  void toggle(String stepKey) {
    final next = {...state};
    final wasChecked = !next.remove(stepKey);
    if (wasChecked) next.add(stepKey);
    state = next;
    _persist(stepKey: stepKey, checked: wasChecked);
  }

  Future<void> _persist({required String stepKey, required bool checked}) async {
    if (!SupabaseService.isReady) return;
    final userId = AuthService.currentUser?.id;
    if (userId == null) return;
    try {
      if (checked) {
        await SupabaseService.client.from('checklist_progress').insert({
          'user_id': userId,
          'namespace': 'registration',
          'step_key': stepKey,
        });
      } else {
        await SupabaseService.client
            .from('checklist_progress')
            .delete()
            .eq('user_id', userId)
            .eq('namespace', 'registration')
            .eq('step_key', stepKey);
      }
    } catch (_) {
      // Optimistic local state stands even if the write failed.
    }
  }
}

final registrationProgressProvider =
    NotifierProvider<RegistrationProgressNotifier, Set<String>>(RegistrationProgressNotifier.new);
