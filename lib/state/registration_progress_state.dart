import 'package:flutter_riverpod/flutter_riverpod.dart';

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
/// progress is scoped to the applicant's current pathway.
class RegistrationProgressNotifier extends Notifier<Set<String>> {
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

final registrationProgressProvider =
    NotifierProvider<RegistrationProgressNotifier, Set<String>>(RegistrationProgressNotifier.new);
