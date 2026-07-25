import 'package:flutter/material.dart';
import '../state/pathway_tasks.dart';
import '../theme/app_colors.dart';
import 'floating_card.dart';
import 'status_pill.dart';

/// A real gap — a document requirement whose AI review actually came back
/// rejected, not a fixed illustrative example. There's exactly one gap
/// signal in this app right now: a reviewed document that didn't check
/// out. Once verification is failing for other reasons too, this is where
/// those would surface as well.
class GapAlertCard extends StatelessWidget {
  const GapAlertCard({super.key, required this.task, required this.onTap});

  final PathwayTask task;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FloatingCard(
      accentColor: AppColors.danger,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  task.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.danger),
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
          const SizedBox(height: 10),
          if (task.statusNote != null) StatusPill(label: task.statusNote!, color: AppColors.danger),
          const SizedBox(height: 12),
          Text(
            'Go fix this →',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 12,
                  color: AppColors.danger,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}
