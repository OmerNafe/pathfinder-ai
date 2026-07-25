import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/supabase_service.dart';

/// A streak day (or milestone count) crossing every [majorStreakInterval]
/// is treated as a bigger moment worth a confetti/sound celebration, rather
/// than every single one.
const int majorStreakInterval = 5;

/// Growth-point thresholds for each trophy stage — seed, sprout, small
/// plant, budding plant, sapling, flourishing tree.
const List<int> growthStageThresholds = [0, 2, 5, 10, 20, 35];

const List<String> growthStageLabels = [
  'Seed',
  'Sprout',
  'Small plant',
  'Budding plant',
  'Sapling',
  'Flourishing tree',
];

int growthStageFor(int points) {
  for (var i = growthStageThresholds.length - 1; i >= 0; i--) {
    if (points >= growthStageThresholds[i]) return i;
  }
  return 0;
}

/// 0.0–1.0 progress within the current stage, toward the next one — 1.0 at
/// the final (maxed-out) stage.
double growthStageProgress(int points) {
  final stage = growthStageFor(points);
  if (stage == growthStageThresholds.length - 1) return 1.0;
  final lower = growthStageThresholds[stage];
  final upper = growthStageThresholds[stage + 1];
  return ((points - lower) / (upper - lower)).clamp(0.0, 1.0);
}

const _zeroState = GrowthState(
  currentStreak: 0,
  longestStreak: 0,
  milestoneCount: 0,
  justReachedMajorStreak: false,
);

/// The applicant's commitment state — a streak of consecutive days on
/// which they actually did something (uploaded a document, completed a
/// milestone), plus the running count of everything completed — combined
/// into one "growth" score that decides how far the [GrowthTrophy] has grown.
class GrowthState {
  const GrowthState({
    required this.currentStreak,
    required this.longestStreak,
    required this.milestoneCount,
    required this.justReachedMajorStreak,
  });

  final int currentStreak;
  final int longestStreak;
  final int milestoneCount;

  /// True only right after [currentStreak] or [milestoneCount] first
  /// crosses a new multiple of [majorStreakInterval] — the UI uses this to
  /// fire the celebration exactly once per milestone, ever.
  final bool justReachedMajorStreak;

  int get growthPoints => currentStreak + milestoneCount;

  GrowthState copyWith({
    int? currentStreak,
    int? longestStreak,
    int? milestoneCount,
    bool? justReachedMajorStreak,
  }) =>
      GrowthState(
        currentStreak: currentStreak ?? this.currentStreak,
        longestStreak: longestStreak ?? this.longestStreak,
        milestoneCount: milestoneCount ?? this.milestoneCount,
        justReachedMajorStreak: justReachedMajorStreak ?? false,
      );
}

/// Persists in Supabase's `growth_state` table, one row per user — replaces
/// the earlier SharedPreferences version, which was local-only and reset on
/// a different device. Falls back to a real, honest zero state (not fake
/// progress) whenever there's no backend or no signed-in user.
///
/// Unlike a simple daily-login counter, the streak here is only ever
/// advanced by [recordAction] — i.e. by actually uploading a document or
/// completing a milestone, not merely opening the app.
class GrowthNotifier extends AsyncNotifier<GrowthState> {
  @override
  Future<GrowthState> build() async {
    final userId = AuthService.currentUser?.id;
    if (!SupabaseService.isReady || userId == null) return _zeroState;

    final row = await SupabaseService.client
        .from('growth_state')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    if (row == null) return _zeroState;

    return GrowthState(
      currentStreak: row['current_streak'] as int,
      longestStreak: row['longest_streak'] as int,
      milestoneCount: row['milestone_count'] as int,
      justReachedMajorStreak: false,
    );
  }

  /// Call whenever the applicant completes something worth nourishing the
  /// trophy for — a submitted document checklist, a submitted licensing
  /// checklist. Advances the streak only if today doesn't already have
  /// credit, and resets it if a day was missed since the last action.
  Future<void> recordAction() async {
    final current = state.value;
    final userId = AuthService.currentUser?.id;
    if (current == null || !SupabaseService.isReady || userId == null) return;

    final client = SupabaseService.client;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final row = await client.from('growth_state').select().eq('user_id', userId).maybeSingle();

    var streak = current.currentStreak;
    final lastActionDateStr = row?['last_action_date'] as String?;

    if (lastActionDateStr == null) {
      streak = 1;
    } else {
      final last = DateTime.parse(lastActionDateStr);
      final lastDay = DateTime(last.year, last.month, last.day);
      final dayDiff = today.difference(lastDay).inDays;
      if (dayDiff == 1) {
        streak += 1;
      } else if (dayDiff > 1) {
        streak = 1;
      }
      // dayDiff == 0: another action today — streak day already earned,
      // only the milestone count below grows.
    }

    final longest = streak > current.longestStreak ? streak : current.longestStreak;
    final milestones = current.milestoneCount + 1;
    final lastCelebrated = (row?['last_celebrated_streak'] as int?) ?? 0;
    final justReachedMajor = streak > 0 && streak % majorStreakInterval == 0 && streak != lastCelebrated;

    await client.from('growth_state').upsert({
      'user_id': userId,
      'current_streak': streak,
      'longest_streak': longest,
      'milestone_count': milestones,
      'last_action_date': today.toIso8601String().split('T').first,
      'last_celebrated_streak': justReachedMajor ? streak : lastCelebrated,
    });

    state = AsyncData(GrowthState(
      currentStreak: streak,
      longestStreak: longest,
      milestoneCount: milestones,
      justReachedMajorStreak: justReachedMajor,
    ));
  }
}

final growthProvider = AsyncNotifierProvider<GrowthNotifier, GrowthState>(GrowthNotifier.new);

const List<String> growthMotivationalPhrases = [
  'Every root you grow today is a step closer to home.',
  'Small, steady steps are how a whole life abroad gets built.',
  'Keep nourishing your journey — day by day, it takes shape.',
  'Your pathway is growing stronger with every milestone.',
  'Consistency is the quiet work behind every successful move.',
  'One more thing done is one root deeper toward arrival.',
];

String growthPhraseFor(int growthPoints) =>
    growthMotivationalPhrases[growthPoints % growthMotivationalPhrases.length];
