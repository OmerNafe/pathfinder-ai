import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks which to-do steps are checked off in the Licensing Registry,
/// keyed by "occupation|country|stepIndex". Unlike the single-pathway
/// registration tracker (one flow visible at a time, so category-level
/// keys are enough), this is a browsable reference covering many
/// occupation/country cells at once, so keys must be occupation-specific
/// to avoid e.g. Registered Nurse UK and Midwife UK colliding.
class LicensingChecklistProgressNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  void toggle(String stepKey) {
    final next = {...state};
    if (!next.remove(stepKey)) {
      next.add(stepKey);
    }
    state = next;
  }
}

final licensingChecklistProgressProvider =
    NotifierProvider<LicensingChecklistProgressNotifier, Set<String>>(
  LicensingChecklistProgressNotifier.new,
);

/// Null per "occupation|country" cell key until the applicant submits that
/// specific checklist; holds the submission timestamp once they have.
/// Session-local "saved" marker only — same honesty convention as the
/// document upload submission state, since there's no backend yet.
class LicensingChecklistSubmissionNotifier extends Notifier<Map<String, DateTime?>> {
  @override
  Map<String, DateTime?> build() => {};

  void submit(String cellKey) => state = {...state, cellKey: DateTime.now()};

  void unsubmit(String cellKey) => state = {...state, cellKey: null};
}

final licensingChecklistSubmissionProvider =
    NotifierProvider<LicensingChecklistSubmissionNotifier, Map<String, DateTime?>>(
  LicensingChecklistSubmissionNotifier.new,
);
