import 'package:flutter/material.dart';
import '../data/sample_dashboard_data.dart';
import '../state/pathway_tasks.dart';
import '../theme/app_colors.dart';
import 'status_pill.dart';

/// One compact row in the dashboard's task list — an icon, a title, status
/// pills, and a short note, scannable in one line rather than a full card
/// per task. [TaskCard] (the fuller version, used on the tasks-overview
/// list) stays as-is; this is the dashboard-specific dense treatment.
class TaskRow extends StatelessWidget {
  const TaskRow({super.key, required this.task, required this.onTap, this.isLast = false});

  final PathwayTask task;
  final VoidCallback onTap;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final (icon, color, label) = switch (task.status) {
      TaskStatus.verified => (Icons.check, AppColors.teal, 'Verified'),
      TaskStatus.pending => (Icons.hourglass_bottom_rounded, AppColors.amber, 'Pending'),
      TaskStatus.rejected => (Icons.priority_high_rounded, AppColors.danger, 'Rejected'),
    };

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.hairline)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 26,
              height: 26,
              margin: const EdgeInsets.only(top: 1),
              alignment: Alignment.center,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.14), shape: BoxShape.circle),
              child: Icon(icon, size: 13, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          task.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 13),
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatusPill(label: label, color: color),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    task.statusNote ?? task.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                          color: task.status == TaskStatus.rejected ? AppColors.danger : AppColors.textMuted,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
