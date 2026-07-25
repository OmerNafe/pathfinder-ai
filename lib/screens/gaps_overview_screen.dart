import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/sample_dashboard_data.dart';
import '../state/pathway_state.dart';
import '../state/pathway_tasks.dart';
import '../theme/app_colors.dart';
import '../widgets/floating_card.dart';
import '../widgets/gap_alert_card.dart';
import '../widgets/page_shell.dart';
import '../widgets/setup_required_card.dart';
import '../widgets/stage_rail.dart';

class GapsOverviewScreen extends ConsumerWidget {
  const GapsOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasSetup = ref.watch(pathwayProvider).hasCompletedSetup;
    final gaps = ref.watch(pathwayTasksProvider).where((t) => t.status == TaskStatus.rejected).toList();

    return PageShell(
      pageTitle: 'Eligibility gaps',
      builder: (context, isMobile) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StageRail(items: buildStageRailItems(hasSetup ? '/gaps' : '/pathway/edit')),
          const SizedBox(height: 28),
          Text('Eligibility gaps', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Every discrepancy identified between your documents and your target '
            "country's requirements.",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
          if (!hasSetup)
            const SetupRequiredCard(
              title: 'No gaps yet',
              message: 'Gaps show up here once your pathway is set up and we know what '
                  'to actually check your documents against.',
            )
          else if (gaps.isEmpty)
            FloatingCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_outline, color: AppColors.teal, size: 22),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('No gaps identified yet', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 6),
                        Text(
                          'Upload your documents on the document checklist — anything that doesn\'t '
                          'check out during review will show up here as soon as it\'s been assessed.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else
            ...gaps.map((task) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: GapAlertCard(
                    task: task,
                    onTap: () => context.go('/tasks/${task.step}'),
                  ),
                )),
        ],
      ),
    );
  }
}
