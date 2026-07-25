import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/milestone_messages.dart';
import '../data/sample_dashboard_data.dart';
import '../services/app_sounds.dart';
import '../services/legal_acceptance_service.dart';
import '../state/growth_state.dart';
import '../state/pathway_state.dart';
import '../state/pathway_tasks.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/app_banner.dart';
import '../widgets/elegant_progress_bar.dart';
import '../widgets/eta_estimate_card.dart';
import '../widgets/floating_card.dart';
import '../widgets/gap_alert_card.dart';
import '../widgets/growth_trophy.dart';
import '../widgets/journey_path_hero.dart';
import '../widgets/landing_card.dart';
import '../widgets/page_shell.dart';
import '../widgets/quick_nav_bar.dart';
import '../widgets/section_title.dart';
import '../widgets/setup_required_card.dart';
import '../widgets/stage_rail.dart';
import '../widgets/task_row.dart';
import '../widgets/today_task_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  // Static, not instance state -- a fresh DashboardScreen is created every
  // time go_router navigates back to '/', but this should only ever show
  // once per real app session (i.e. once per login), not on every visit.
  static bool _hasShownWelcomeThisSession = false;

  @override
  void initState() {
    super.initState();
    // A material Terms/Privacy update re-gates access on next dashboard
    // visit rather than silently assuming an old acceptance still covers
    // new terms — checked post-frame so it never blocks the first paint.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (await LegalAcceptanceService.needsReacceptance() && mounted) {
        context.go('/legal/reaccept');
        return;
      }
      _maybeShowWelcomeBack();
    });
  }

  void _maybeShowWelcomeBack() {
    if (_hasShownWelcomeThisSession || !mounted) return;
    final pathway = ref.read(pathwayProvider);
    if (!pathway.hasCompletedSetup) return;
    _hasShownWelcomeThisSession = true;

    final growth = ref.read(growthProvider).value;
    final percent = (pathway.progress * 100).round();
    final streak = growth?.currentStreak ?? 0;
    final message = streak > 1
        ? "Welcome back — $percent% of the way there, $streak-day streak going."
        : "Welcome back — $percent% of the way to ${pathway.occupation} in ${pathway.targetCountry}.";

    // Shows the actual seed-to-tree growth photo, not just an icon, so
    // "your pathway is growing" is something to see on login, not only
    // read about behind a "My growth" tap.
    showWelcomeBackBanner(context, message: message, growthPoints: growth?.growthPoints ?? 0);
  }

  void _showGrowthDialog() {
    final state = ref.read(growthProvider).value;
    if (state == null) return;
    showDialog<void>(context: context, builder: (_) => _GrowthDialog(state: state));
  }

  @override
  Widget build(BuildContext context) {
    final pathway = ref.watch(pathwayProvider);
    final growth = ref.watch(growthProvider);
    final hasSetup = pathway.hasCompletedSetup;

    // Growth/streak is only ever shown on request (via the "My growth" nav
    // item below) — not popped up automatically on every dashboard visit.
    ref.listen<AsyncValue<GrowthState>>(growthProvider, (previous, next) {
      final state = next.value;
      if (state != null && state.justReachedMajorStreak) {
        AppSounds.celebrate();
        showAppBanner(context, message: randomMilestoneMessage());
      }
    });

    final stageItems = buildStageRailItems(hasSetup ? '/gaps' : '/pathway/edit');

    return PageShell(
      builder: (context, isMobile) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMobile)
            // The full StageRail (4 stacked rows on a narrow screen) plus
            // JourneyPathHero further down the page was two "where am I"
            // indicators competing for the same space — a plain, elegant
            // label reads instantly and leaves the visual journey map as
            // the one real centerpiece.
            _MobileStageLabel(items: stageItems)
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Everything the rail doesn't cover stays reachable here —
                // placed left of the rail so the bar reads symmetrically
                // (a fixed-width anchor on each side isn't how it'd look
                // with the menu tacked onto just one end).
                QuickNavMenu(
                  items: [
                    QuickNavItem(
                      label: 'Exam prep',
                      icon: Icons.school_outlined,
                      color: AppColors.teal,
                      onTap: () => context.go('/exam-prep'),
                    ),
                    QuickNavItem(
                      label: 'My growth',
                      icon: Icons.eco_outlined,
                      color: AppColors.teal,
                      onTap: _showGrowthDialog,
                    ),
                    QuickNavItem(
                      label: 'About us',
                      icon: Icons.info_outline,
                      color: AppColors.textSecondary,
                      onTap: () => context.go('/about'),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                // The 4-stage journey — done/current/upcoming — is both the
                // primary navigation and an honest "you are here" indicator,
                // replacing the old flat quick-nav pills for these 4 stops.
                // Before setup, Diagnostic is genuinely the current stage —
                // there's no real gap analysis to point to yet.
                Expanded(child: StageRail(items: stageItems)),
              ],
            ),
          const SizedBox(height: 28),

          if (!hasSetup)
            const SetupRequiredCard(
              title: 'Let\'s map your pathway',
              message: 'Pick your occupation and destination country and we\'ll identify the specific '
                  'gaps between what you have and what\'s required. Nothing below is filled in yet — '
                  'this is where your journey actually starts.',
            )
          else if (isMobile)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _mobileTodayColumn(context, pathway, growth, stageItems),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 7, child: Column(children: _mainColumn(context))),
                const SizedBox(width: 24),
                Expanded(flex: 5, child: Column(children: _sideColumn(context, pathway, growth))),
              ],
            ),

          const SizedBox(height: 48),
          const SectionTitle(
            label: 'Soft landing hub',
            subtitle: 'For later — once the pathway above is on track',
            color: AppColors.gold,
          ),
          const SizedBox(height: 20),
          _LandingGrid(isMobile: isMobile),
        ],
      ),
    );
  }

  List<Widget> _mainColumn(BuildContext context) {
    final tasks = ref.watch(pathwayTasksProvider);
    final gaps = tasks.where((t) => t.status == TaskStatus.rejected).toList();

    return [
      if (gaps.isNotEmpty)
        GapAlertCard(task: gaps.first, onTap: () => context.go('/tasks/${gaps.first.step}'))
      else
        FloatingCard(
          accentColor: AppColors.teal,
          onTap: () => context.go('/gaps'),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_circle_outline, color: AppColors.teal, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('No gaps identified yet', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      'Upload your documents below and anything that needs attention will show up here.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      const SizedBox(height: 20),
      FloatingCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your blueprint', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              'Every document your pathway needs, in order — this is what "guided" actually means.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < tasks.length; i++)
              TaskRow(
                task: tasks[i],
                isLast: i == tasks.length - 1,
                onTap: () => context.go('/tasks/${tasks[i].step}'),
              ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _sideColumn(BuildContext context, PathwayData pathway, AsyncValue<GrowthState> growth) {
    final tasks = ref.watch(pathwayTasksProvider);
    final verifiedCount = tasks.where((t) => t.status == TaskStatus.verified).length;

    return [
      _CertificateTeaserCard(
        onTap: () => context.go('/certificate'),
        verifiedCount: verifiedCount,
        totalCount: tasks.length,
      ),
      const SizedBox(height: 20),
      _PathwaySummaryCard(pathway: pathway, onTap: () => context.go('/pathway/edit')),
      const SizedBox(height: 20),
      EtaEstimateCard(targetCountry: pathway.targetCountry, compact: true),
      const SizedBox(height: 20),
      _GrowthMiniCard(growth: growth.value, onTap: _showGrowthDialog),
    ];
  }

  /// The mobile "quick peek" home: the route hero first, one real task to
  /// act on right now, then everything else as tappable icon shortcuts
  /// rather than more stacked cards — deliberately not the desktop layout
  /// shrunk down, see journey_path_hero.dart and today_task_card.dart.
  List<Widget> _mobileTodayColumn(
    BuildContext context,
    PathwayData pathway,
    AsyncValue<GrowthState> growth,
    List<StageRailItem> stageItems,
  ) {
    final tasks = ref.watch(pathwayTasksProvider);
    if (tasks.isEmpty) return const [];

    final rejected = tasks.where((t) => t.status == TaskStatus.rejected);
    final pending = tasks.where((t) => t.status == TaskStatus.pending);
    final priorityTask = rejected.isNotEmpty ? rejected.first : (pending.isNotEmpty ? pending.first : tasks.first);
    final verifiedCount = tasks.where((t) => t.status == TaskStatus.verified).length;
    final streak = growth.value?.currentStreak ?? 0;
    final certPercent = tasks.isEmpty ? 0 : ((verifiedCount / tasks.length) * 100).round();

    return [
      JourneyPathHero(items: stageItems),
      const SizedBox(height: 20),
      TodayTaskCard(task: priorityTask),
      const SizedBox(height: 24),
      Row(
        children: [
          _QuickActionTile(
            icon: Icons.local_fire_department_rounded,
            color: AppColors.gold,
            label: 'Streak',
            badge: streak > 0 ? '$streak' : null,
            onTap: _showGrowthDialog,
          ),
          _QuickActionTile(
            icon: Icons.workspace_premium_outlined,
            color: AppColors.teal,
            label: 'Certificate',
            badge: '$certPercent%',
            onTap: () => context.go('/certificate'),
          ),
          _QuickActionTile(
            icon: Icons.school_outlined,
            color: AppColors.teal,
            label: 'Exam prep',
            onTap: () => context.go('/exam-prep'),
          ),
          _QuickActionTile(
            icon: Icons.info_outline_rounded,
            color: AppColors.textSecondary,
            label: 'About',
            onTap: () => context.go('/about'),
          ),
        ],
      ),
      const SizedBox(height: 20),
      Center(
        child: TextButton(
          onPressed: () => context.go('/tasks'),
          child: const Text('View full blueprint →', style: TextStyle(fontSize: 13)),
        ),
      ),
    ];
  }
}

/// Small, elegant "you are here" label — replaces the full StageRail on
/// mobile (see the note above where this is used) with plain typography
/// instead of another bordered card competing with the journey hero.
class _MobileStageLabel extends StatelessWidget {
  const _MobileStageLabel({required this.items});

  final List<StageRailItem> items;

  @override
  Widget build(BuildContext context) {
    final currentIndex = items.indexWhere((i) => i.status == StageStatus.current);
    final current = items[currentIndex == -1 ? 0 : currentIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'STAGE ${(currentIndex == -1 ? 0 : currentIndex) + 1} OF ${items.length}',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          current.title,
          style: const TextStyle(
            fontFamily: AppTheme.displayFontFamily,
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: AppColors.gold,
          ),
        ),
      ],
    );
  }
}

/// One tappable icon shortcut — the mobile substitute for a full
/// FloatingCard when all the moment needs is an icon, a number, and a
/// label. A small colored badge carries the one real number that matters
/// (streak length, verified percentage); everything else is just a label.
class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String? badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                      border: Border.all(color: color.withValues(alpha: 0.3)),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  if (badge != null)
                    Positioned(
                      top: -4,
                      right: -6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundElevated,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: color.withValues(alpha: 0.5)),
                        ),
                        child: Text(
                          badge!,
                          style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: color),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// New: a live preview of the shareable Pathway Certificate — pure output,
/// no extra work asked of the applicant, just a door into something they
/// can now hand to a recruiter or institution.
class _CertificateTeaserCard extends StatelessWidget {
  const _CertificateTeaserCard({required this.onTap, required this.verifiedCount, required this.totalCount});
  final VoidCallback onTap;
  final int verifiedCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final ratio = totalCount == 0 ? 0.0 : verifiedCount / totalCount;
    return FloatingCard(
      accentColor: AppColors.gold,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('Pathway Certificate', style: Theme.of(context).textTheme.titleLarge)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text('NEW', style: TextStyle(fontSize: 9.5, color: AppColors.gold, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'A shareable, verifiable snapshot of your progress.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 42,
                height: 42,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 42,
                      height: 42,
                      child: CircularProgressIndicator(
                        value: ratio,
                        strokeWidth: 4,
                        backgroundColor: AppColors.hairlineStrong,
                        valueColor: const AlwaysStoppedAnimation(AppColors.teal),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Text('${(ratio * 100).round()}%',
                        style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '$verifiedCount of $totalCount requirements verified',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'View certificate →',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                ),
          ),
        ],
      ),
    );
  }
}

class _PathwaySummaryCard extends StatelessWidget {
  const _PathwaySummaryCard({required this.pathway, required this.onTap});

  final PathwayData pathway;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FloatingCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your pathway', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 14),
          _kv(context, 'Occupation', pathway.occupation),
          const SizedBox(height: 8),
          _kv(context, 'Destination', pathway.targetCountry),
          const SizedBox(height: 16),
          ElegantProgressBar(value: pathway.progress, height: 6),
          const SizedBox(height: 8),
          Row(
            children: [
              Flexible(
                child: Text(
                  '${(pathway.progress * 100).round()}% mapped',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Edit pathway →',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _kv(BuildContext context, String k, String v) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          k.toUpperCase(),
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted, letterSpacing: 0.4),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            v,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 13),
          ),
        ),
      ],
    );
  }
}

class _GrowthMiniCard extends StatelessWidget {
  const _GrowthMiniCard({required this.growth, required this.onTap});

  final GrowthState? growth;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final state = growth;
    final points = state?.growthPoints ?? 0;
    final stage = growthStageFor(points);

    return FloatingCard(
      onTap: onTap,
      child: Row(
        children: [
          GrowthTrophy(growthPoints: points, size: 56),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${state?.currentStreak ?? 0}',
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    const SizedBox(width: 5),
                    Text('day streak', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  growthStageLabels[stage],
                  style: const TextStyle(color: AppColors.teal, fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Greets the applicant on login with the *whole* journey laid out at
/// once — every stage from seed to flourishing tree, in front of them,
/// with the one they've reached lit up — rather than just a single trophy
/// or an abstract chart.
class _GrowthDialog extends StatelessWidget {
  const _GrowthDialog({required this.state});

  final GrowthState state;

  @override
  Widget build(BuildContext context) {
    final stage = growthStageFor(state.growthPoints);

    return Dialog(
      backgroundColor: AppColors.surfaceCardHover,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.hairlineStrong),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                growthStageLabels[stage],
                style: const TextStyle(
                  fontFamily: AppTheme.displayFontFamily,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_fire_department, color: AppColors.gold, size: 16),
                  const SizedBox(width: 5),
                  Text(
                    '${state.currentStreak}-day streak',
                    style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  if (state.longestStreak > state.currentStreak) ...[
                    const SizedBox(width: 8),
                    Text(
                      '· best ${state.longestStreak}',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),
              _GrowthRoadmap(currentStage: stage),
              const SizedBox(height: 24),
              Text(
                growthPhraseFor(state.growthPoints),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
              const SizedBox(height: 8),
              Text(
                '${state.milestoneCount} milestone${state.milestoneCount == 1 ? '' : 's'} nourished so far',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.backgroundDeep,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Keep going', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Every stage, seed to flourishing tree, side by side — reached stages
/// full-colour, the current one enlarged and lit up in gold, the rest
/// dimmed so the applicant can see exactly what's still ahead.
///
/// Each tile is just [GrowthTrophy] fed that stage's own threshold value,
/// so swapping in real photography later (in [GrowthTrophy] alone) updates
/// every tile here automatically.
class _GrowthRoadmap extends StatelessWidget {
  const _GrowthRoadmap({required this.currentStage});

  final int currentStage;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < growthStageThresholds.length; i++) ...[
          if (i > 0)
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 22),
                height: 2,
                color: i <= currentStage ? AppColors.teal.withValues(alpha: 0.6) : AppColors.hairline,
              ),
            ),
          _RoadmapStageTile(
            stage: i,
            reached: i <= currentStage,
            current: i == currentStage,
          ),
        ],
      ],
    );
  }
}

class _RoadmapStageTile extends StatelessWidget {
  const _RoadmapStageTile({required this.stage, required this.reached, required this.current});

  final int stage;
  final bool reached;
  final bool current;

  @override
  Widget build(BuildContext context) {
    final size = current ? 76.0 : 56.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: current ? Border.all(color: AppColors.gold, width: 1.5) : null,
            boxShadow: current
                ? [BoxShadow(color: AppColors.gold.withValues(alpha: 0.4), blurRadius: 12, spreadRadius: 1)]
                : null,
          ),
          child: Opacity(
            opacity: reached ? 1.0 : 0.32,
            child: GrowthTrophy(growthPoints: growthStageThresholds[stage], size: size),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 78,
          child: Text(
            growthStageLabels[stage],
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: current ? FontWeight.w700 : FontWeight.w500,
              color: reached ? (current ? AppColors.gold : AppColors.textSecondary) : AppColors.textMuted,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}

class _LandingGrid extends StatelessWidget {
  const _LandingGrid({required this.isMobile});
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final entries = sampleLandingItems.asMap().entries.toList();

    if (isMobile) {
      return Column(
        children: entries
            .map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: LandingCard(
                    item: entry.value,
                    onTap: () => context.go('/landing/${entry.key}'),
                  ),
                ))
            .toList(),
      );
    }

    // Two cards per row on desktop/tablet, wrapping to further rows as the
    // hub grows rather than squeezing every card into a single row.
    final rows = <Widget>[];
    for (var i = 0; i < entries.length; i += 2) {
      final rowEntries = entries.skip(i).take(2).toList();
      rows.add(
        Padding(
          padding: EdgeInsets.only(bottom: i + 2 < entries.length ? 16 : 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var j = 0; j < rowEntries.length; j++) ...[
                if (j > 0) const SizedBox(width: 16),
                Expanded(
                  child: LandingCard(
                    item: rowEntries[j].value,
                    onTap: () => context.go('/landing/${rowEntries[j].key}'),
                  ),
                ),
              ],
              if (rowEntries.length == 1) const Spacer(),
            ],
          ),
        ),
      );
    }

    return Column(children: rows);
  }
}
