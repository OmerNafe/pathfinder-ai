import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../state/pathway_state.dart';
import '../state/pathway_tasks.dart';
import '../widgets/page_shell.dart';
import '../widgets/setup_required_card.dart';
import '../widgets/stage_rail.dart';
import '../widgets/task_card.dart';

class TasksOverviewScreen extends ConsumerWidget {
  const TasksOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasSetup = ref.watch(pathwayProvider).hasCompletedSetup;
    final tasks = ref.watch(pathwayTasksProvider);

    return PageShell(
      pageTitle: 'Daily action blueprint',
      builder: (context, isMobile) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StageRail(items: buildStageRailItems(hasSetup ? '/tasks' : '/pathway/edit')),
          const SizedBox(height: 28),
          Text('Daily action blueprint', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Your full interactive milestone timeline, in order.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
          if (!hasSetup)
            const SetupRequiredCard(
              title: 'No tasks yet',
              message: 'Your task list is generated from your actual gaps, once your '
                  'pathway is set up — there\'s nothing to guide you through until then.',
            )
          else
            ...tasks.map((t) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TaskCard(
                    task: t,
                    onTap: () => context.go('/tasks/${t.step}'),
                  ),
                )),
        ],
      ),
    );
  }
}
