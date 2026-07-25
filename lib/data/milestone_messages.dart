import 'dart:math';

/// Shown on a real milestone (a submitted checklist, a streak reached) —
/// deliberately a pool rather than one fixed string, so it doesn't read as
/// a canned, repeated notification the tenth time someone sees it.
const milestoneMessages = [
  "You're right on track.",
  "That's real progress — keep going.",
  "One step closer to being licensed.",
  "Nicely done. The path is holding.",
  "Momentum like that adds up.",
  "You're moving in the right direction.",
  "Solid step forward.",
  "That's the pathway working.",
];

final _random = Random();

String randomMilestoneMessage() => milestoneMessages[_random.nextInt(milestoneMessages.length)];
