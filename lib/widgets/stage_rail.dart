import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

enum StageStatus { done, current, upcoming }

class StageRailItem {
  const StageRailItem({required this.label, required this.title, required this.status, required this.route});
  final String label;
  final String title;
  final StageStatus status;
  final String route;
}

const _stages = [
  ('Diagnostic', '/pathway/edit'),
  ('Gap Analysis', '/gaps'),
  ('Guided Tasks', '/tasks'),
  ('Soft Landing', '/landing'),
];

/// Builds the 4 stage items with done/current/upcoming derived from
/// [currentRoute] — the same rail shown on the dashboard, reused wherever
/// one of the 4 stages has its own screen, so "you are here" stays
/// consistent across the whole pathway rather than only on the dashboard.
List<StageRailItem> buildStageRailItems(String currentRoute) {
  final currentIndex = _stages.indexWhere((s) => s.$2 == currentRoute);
  return [
    for (var i = 0; i < _stages.length; i++)
      StageRailItem(
        label: i == currentIndex ? 'You are here' : 'Stage ${i + 1}',
        title: _stages[i].$1,
        status: i < currentIndex
            ? StageStatus.done
            : (i == currentIndex ? StageStatus.current : StageStatus.upcoming),
        route: _stages[i].$2,
      ),
  ];
}

/// Replaces the dashboard's old quick-nav pill row with one device that is
/// both real navigation and an honest "you are here" indicator — the same
/// 4-stage story told on the About screen, made visible everywhere instead
/// of living on a page nobody revisits.
class StageRail extends StatelessWidget {
  const StageRail({super.key, required this.items});

  final List<StageRailItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border.all(color: AppColors.hairline),
        borderRadius: BorderRadius.circular(16),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 640;
          if (isNarrow) {
            return Column(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0) const Divider(height: 1, color: AppColors.hairline),
                  _StageSegment(item: items[i], showTrailingDivider: false),
                ],
              ],
            );
          }
          return Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(child: _StageSegment(item: items[i], showTrailingDivider: i != items.length - 1)),
            ],
          );
        },
      ),
    );
  }
}

class _StageSegment extends StatefulWidget {
  const _StageSegment({required this.item, required this.showTrailingDivider});

  final StageRailItem item;
  final bool showTrailingDivider;

  @override
  State<_StageSegment> createState() => _StageSegmentState();
}

class _StageSegmentState extends State<_StageSegment> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isCurrent = item.status == StageStatus.current;
    final isDone = item.status == StageStatus.done;
    final accent = isDone ? AppColors.teal : AppColors.gold;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: () => context.go(item.route),
        child: Container(
          decoration: BoxDecoration(
            color: isCurrent
                ? AppColors.gold.withValues(alpha: 0.08)
                : (_hovering ? AppColors.surfaceCardHover : Colors.transparent),
            borderRadius: BorderRadius.circular(12),
            border: Border(
              right: widget.showTrailingDivider
                  ? BorderSide(color: AppColors.hairline)
                  : BorderSide.none,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone || isCurrent ? accent : Colors.transparent,
                  border: isDone || isCurrent ? null : Border.all(color: AppColors.textMuted, width: 1.5),
                ),
                child: isDone
                    ? const Icon(Icons.check, size: 13, color: AppColors.backgroundDeep)
                    : Text(
                        item.label.replaceAll(RegExp('[^0-9]'), ''),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isCurrent ? AppColors.backgroundDeep : AppColors.textMuted,
                        ),
                      ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: isCurrent ? AppColors.gold : (isDone ? AppColors.teal : AppColors.textMuted),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      item.title,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
