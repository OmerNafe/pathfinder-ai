import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import 'journey_icons.dart';
import 'stage_rail.dart';

const _stageGlyphs = [
  JourneyStageGlyph.diagnostic,
  JourneyStageGlyph.gapAnalysis,
  JourneyStageGlyph.guidedTasks,
  JourneyStageGlyph.softLanding,
];

/// The signature "route" visual, built for a glance rather than a read —
/// connected nodes on a path rather than [StageRail]'s list-style rows.
/// This is the mobile "quick peek at the journey" moment: four stops,
/// done ones filled solid, the current one pulsing gold, the rest hollow.
class JourneyPathHero extends StatelessWidget {
  const JourneyPathHero({super.key, required this.items});

  final List<StageRailItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Column(
        children: [
          Row(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                _PathNode(item: items[i], glyph: _stageGlyphs[i]),
                if (i != items.length - 1)
                  Expanded(
                    child: _PathConnector(
                      filled: items[i].status == StageStatus.done,
                    ),
                  ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final item in items)
                SizedBox(
                  width: 60,
                  child: Text(
                    item.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: item.status == StageStatus.current ? FontWeight.w700 : FontWeight.w500,
                      color: switch (item.status) {
                        StageStatus.current => AppColors.gold,
                        StageStatus.done => AppColors.teal,
                        StageStatus.upcoming => AppColors.textMuted,
                      },
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PathNode extends StatelessWidget {
  const _PathNode({required this.item, required this.glyph});
  final StageRailItem item;
  final JourneyStageGlyph glyph;

  @override
  Widget build(BuildContext context) {
    final isCurrent = item.status == StageStatus.current;
    final isDone = item.status == StageStatus.done;
    final color = isDone ? AppColors.teal : (isCurrent ? AppColors.gold : AppColors.textMuted);
    final diameter = isCurrent ? 46.0 : 36.0;

    return GestureDetector(
      onTap: () => context.go(item.route),
      child: Container(
        width: diameter,
        height: diameter,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: (isDone || isCurrent) ? color.withValues(alpha: 0.16) : Colors.transparent,
          border: Border.all(color: color, width: isCurrent ? 2 : 1.4),
          boxShadow: isCurrent
              ? [BoxShadow(color: AppColors.gold.withValues(alpha: 0.35), blurRadius: 14, spreadRadius: 1)]
              : null,
        ),
        child: isDone
            ? Icon(Icons.check, size: 17, color: color)
            : JourneyIcon(glyph: glyph, color: color, size: isCurrent ? 22 : 17),
      ),
    );
  }
}

class _PathConnector extends StatelessWidget {
  const _PathConnector({required this.filled});
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: filled ? AppColors.teal : AppColors.hairlineStrong,
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}
