import 'package:flutter/material.dart';
import '../state/growth_state.dart';
import '../theme/app_colors.dart';

/// The real photograph for each growth stage, seed to flourishing tree —
/// index matches [growthStageThresholds]/[growthStageLabels].
const List<String> growthStageImages = [
  'assets/images/growth_stage_0_seed.jpg',
  'assets/images/growth_stage_1_sprout.jpg',
  'assets/images/growth_stage_2_small_plant.jpg',
  'assets/images/growth_stage_3_budding.jpg',
  'assets/images/growth_stage_4_sapling.jpg',
  'assets/images/growth_stage_5_flourishing.jpg',
];

/// A small seed photo that grows into a flourishing tree as [growthPoints]
/// rises — streaks and completed milestones both "nourish" it. Used both as
/// a single hero image and, at small sizes, as one tile in [_GrowthRoadmap]
/// — swap [growthStageImages] to restyle every use at once.
class GrowthTrophy extends StatelessWidget {
  const GrowthTrophy({super.key, required this.growthPoints, this.size = 120});

  final int growthPoints;
  final double size;

  int get _stage => growthStageFor(growthPoints);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 450),
        transitionBuilder: (child, animation) => ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: animation, child: child),
        ),
        child: KeyedSubtree(
          key: ValueKey(_stage),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.hairlineStrong),
              boxShadow: [
                BoxShadow(
                  color: AppColors.teal.withValues(alpha: 0.25),
                  blurRadius: size * 0.2,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(growthStageImages[_stage], fit: BoxFit.cover),
            ),
          ),
        ),
      ),
    );
  }
}
