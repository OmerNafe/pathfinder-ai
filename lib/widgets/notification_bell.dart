import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/sample_dashboard_data.dart';
import '../state/growth_state.dart';
import '../state/pathway_state.dart';
import '../state/pathway_tasks.dart';
import '../theme/app_colors.dart';

class _NotificationItem {
  const _NotificationItem({required this.dotColor, required this.lead, required this.rest});
  final Color dotColor;
  final String lead;
  final String rest;
}

/// Derived entirely from this applicant's own real state — a rejected
/// document review, documents still outstanding, an active streak — never
/// canned content. Empty until there's something real to say.
List<_NotificationItem> _buildNotifications(WidgetRef ref) {
  final pathway = ref.watch(pathwayProvider);
  if (!pathway.hasCompletedSetup) return const [];

  final tasks = ref.watch(pathwayTasksProvider);
  final growth = ref.watch(growthProvider).value;
  final items = <_NotificationItem>[];

  for (final task in tasks.where((t) => t.status == TaskStatus.rejected)) {
    items.add(_NotificationItem(
      dotColor: AppColors.danger,
      lead: task.title,
      rest: ' needs attention${task.statusNote != null ? ' — ${task.statusNote}' : '.'}',
    ));
  }

  final pendingCount = tasks.where((t) => t.status == TaskStatus.pending).length;
  if (pendingCount > 0) {
    items.add(_NotificationItem(
      dotColor: AppColors.amber,
      lead: '$pendingCount document${pendingCount == 1 ? '' : 's'}',
      rest: ' still needed to complete your checklist.',
    ));
  }

  if (growth != null && growth.currentStreak > 0) {
    items.add(_NotificationItem(
      dotColor: AppColors.gold,
      lead: '${growth.currentStreak}-day streak',
      rest: ' — one more action today keeps it going.',
    ));
  }

  return items;
}

/// Passive status updates surfaced next to the profile menu — built from
/// this applicant's real pathway/document/streak state (see
/// [_buildNotifications]), not illustrative placeholder content.
class NotificationBell extends ConsumerWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = _buildNotifications(ref);

    return PopupMenuButton<void>(
      tooltip: 'Notifications',
      offset: const Offset(0, 46),
      color: AppColors.surfaceCardHover,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.hairlineStrong),
      ),
      itemBuilder: (context) => [
        if (notifications.isEmpty)
          const PopupMenuItem<void>(
            enabled: false,
            child: SizedBox(
              width: 260,
              child: Text(
                "Nothing to report yet — you're all caught up.",
                style: TextStyle(fontSize: 12.5, color: AppColors.textMuted, height: 1.45),
              ),
            ),
          )
        else
          for (final n in notifications)
            PopupMenuItem<void>(
              enabled: false,
              child: SizedBox(
                width: 260,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(color: n.dotColor, shape: BoxShape.circle),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.45),
                          children: [
                            TextSpan(
                              text: n.lead,
                              style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                            ),
                            TextSpan(text: n.rest),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ],
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.hairline),
              ),
              child: const Icon(Icons.notifications_outlined, size: 17, color: AppColors.textSecondary),
            ),
            if (notifications.isNotEmpty)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: AppColors.amber,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.backgroundDeep, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
