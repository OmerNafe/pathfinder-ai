import 'package:flutter/material.dart';
import '../data/sample_dashboard_data.dart';
import '../state/pathway_tasks.dart';
import '../theme/app_colors.dart';
import 'floating_card.dart';
import 'ghost_button.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({super.key, required this.task, required this.onTap});

  final PathwayTask task;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (task.status) {
      TaskStatus.verified => (Icons.check_circle, AppColors.teal),
      TaskStatus.pending => (Icons.radio_button_unchecked, AppColors.textMuted),
      TaskStatus.rejected => (Icons.error_outline, AppColors.danger),
    };

    return FloatingCard(
      accentColor: task.status == TaskStatus.rejected ? AppColors.danger : null,
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STEP ${task.step}',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(fontSize: 11, color: AppColors.textMuted, letterSpacing: 1),
                ),
                const SizedBox(height: 4),
                Text(task.title, style: Theme.of(context).textTheme.titleMedium),
                if (task.statusNote != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    task.statusNote!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: color,
                          fontSize: 13,
                        ),
                  ),
                ],
                const SizedBox(height: 16),
                GhostButton(label: 'View details', color: color, onPressed: onTap),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
