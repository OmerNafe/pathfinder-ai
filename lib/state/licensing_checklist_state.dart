import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/supabase_service.dart';

/// Tracks which to-do steps are checked off in the Licensing Registry,
/// keyed by "occupation|country|stepIndex". Unlike the single-pathway
/// registration tracker (one flow visible at a time, so category-level
/// keys are enough), this is a browsable reference covering many
/// occupation/country cells at once, so keys must be occupation-specific
/// to avoid e.g. Registered Nurse UK and Midwife UK colliding. Same sync
/// hydrate/persist pattern as PathwayNotifier, backed by the shared
/// checklist_progress table (namespace: 'licensing').
class LicensingChecklistProgressNotifier extends Notifier<Set<String>> {
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
          .eq('namespace', 'licensing');
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
          'namespace': 'licensing',
          'step_key': stepKey,
        });
      } else {
        await SupabaseService.client
            .from('checklist_progress')
            .delete()
            .eq('user_id', userId)
            .eq('namespace', 'licensing')
            .eq('step_key', stepKey);
      }
    } catch (_) {
      // Optimistic local state stands even if the write failed.
    }
  }
}

final licensingChecklistProgressProvider =
    NotifierProvider<LicensingChecklistProgressNotifier, Set<String>>(
  LicensingChecklistProgressNotifier.new,
);

/// Null per "occupation|country" cell key until the applicant submits that
/// specific checklist; holds the submission timestamp once they have. Real,
/// persisted state now (checklist_submissions table) — previously
/// session-local only despite looking committed to the user.
class LicensingChecklistSubmissionNotifier extends Notifier<Map<String, DateTime?>> {
  @override
  Map<String, DateTime?> build() {
    _hydrate();
    return {};
  }

  Future<void> _hydrate() async {
    if (!SupabaseService.isReady) return;
    final userId = AuthService.currentUser?.id;
    if (userId == null) return;
    try {
      final rows = await SupabaseService.client
          .from('checklist_submissions')
          .select('cell_key, submitted_at')
          .eq('user_id', userId);
      state = {
        for (final row in rows)
          row['cell_key'] as String: DateTime.parse(row['submitted_at'] as String),
      };
    } catch (_) {
      // Stay on defaults — a failed hydrate shouldn't block the page.
    }
  }

  void submit(String cellKey) {
    final now = DateTime.now();
    state = {...state, cellKey: now};
    _persistSubmit(cellKey, now);
  }

  void unsubmit(String cellKey) {
    state = {...state, cellKey: null};
    _persistUnsubmit(cellKey);
  }

  Future<void> _persistSubmit(String cellKey, DateTime submittedAt) async {
    if (!SupabaseService.isReady) return;
    final userId = AuthService.currentUser?.id;
    if (userId == null) return;
    try {
      await SupabaseService.client.from('checklist_submissions').upsert({
        'user_id': userId,
        'cell_key': cellKey,
        'submitted_at': submittedAt.toUtc().toIso8601String(),
      });
    } catch (_) {
      // Optimistic local state stands even if the write failed.
    }
  }

  Future<void> _persistUnsubmit(String cellKey) async {
    if (!SupabaseService.isReady) return;
    final userId = AuthService.currentUser?.id;
    if (userId == null) return;
    try {
      await SupabaseService.client
          .from('checklist_submissions')
          .delete()
          .eq('user_id', userId)
          .eq('cell_key', cellKey);
    } catch (_) {
      // Optimistic local state stands even if the write failed.
    }
  }
}

final licensingChecklistSubmissionProvider =
    NotifierProvider<LicensingChecklistSubmissionNotifier, Map<String, DateTime?>>(
  LicensingChecklistSubmissionNotifier.new,
);
