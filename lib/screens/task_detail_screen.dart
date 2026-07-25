import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/sample_dashboard_data.dart';
import '../state/pathway_tasks.dart';
import '../theme/app_colors.dart';
import '../widgets/floating_card.dart';
import '../widgets/ghost_button.dart';
import '../widgets/page_shell.dart';
import '../widgets/status_pill.dart';

class TaskDetailScreen extends ConsumerWidget {
  const TaskDetailScreen({super.key, required this.step});

  final int step;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(pathwayTasksProvider);
    final matches = tasks.where((t) => t.step == step);
    final task = matches.isEmpty ? null : matches.first;

    if (task == null) {
      return PageShell(
        pageTitle: 'Step $step',
        builder: (context, isMobile) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton.icon(
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.arrow_back, size: 16),
              label: const Text('Back to dashboard'),
              style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            Text("This step isn't part of your current pathway.", style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      );
    }

    final (icon, color, label) = switch (task.status) {
      TaskStatus.verified => (Icons.check_circle, AppColors.teal, 'Verified'),
      TaskStatus.pending => (Icons.radio_button_unchecked, AppColors.textMuted, 'Pending'),
      TaskStatus.rejected => (Icons.error_outline, AppColors.danger, 'Needs attention'),
    };

    return PageShell(
      pageTitle: 'Step $step',
      builder: (context, isMobile) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton.icon(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.arrow_back, size: 16),
            label: const Text('Back to dashboard'),
            style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          Text(
            'STEP $step',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  letterSpacing: 1,
                ),
          ),
          const SizedBox(height: 6),
          Text(task.title, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          StatusPill(label: label, color: color, icon: icon),
          const SizedBox(height: 32),
          FloatingCard(
            accentColor: task.status == TaskStatus.rejected ? AppColors.danger : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Overview', style: _label(context)),
                const SizedBox(height: 8),
                Text(
                  task.description,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
                ),
                if (task.statusNote != null) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: color.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(icon, color: color, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            task.statusNote!,
                            style: TextStyle(color: color, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (task.status != TaskStatus.verified) ...[
                  const SizedBox(height: 24),
                  GhostButton(
                    label: task.status == TaskStatus.rejected ? 'Re-upload this document' : 'Upload this document',
                    color: color,
                    onPressed: () => context.go('/documents'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _label(BuildContext context) => Theme.of(context)
      .textTheme
      .labelLarge!
      .copyWith(fontSize: 11, color: AppColors.textMuted, letterSpacing: 0.6);
}
