import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A custom-drawn abstract "journey" motif — orbiting waypoints around a
/// compass mark — used in place of a stock photo on the sign-in page.
/// Keeps the illustration on-brand and self-contained (no external assets).
class AuroraCompassIllustration extends StatelessWidget {
  const AuroraCompassIllustration({super.key, this.size = 320});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.gold.withValues(alpha: 0.16),
                  AppColors.teal.withValues(alpha: 0.08),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
            ),
          ),
          Container(
            width: size * 0.7,
            height: size * 0.7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.hairlineStrong, width: 1),
            ),
          ),
          Container(
            width: size * 0.46,
            height: size * 0.46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.hairline, width: 1),
            ),
          ),
          for (final waypoint in _waypoints(size))
            Positioned(
              left: waypoint.dx,
              top: waypoint.dy,
              child: Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.teal,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.teal.withValues(alpha: 0.6),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          Container(
            width: size * 0.32,
            height: size * 0.32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(size * 0.09),
              gradient: const LinearGradient(
                colors: [AppColors.gold, AppColors.teal],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.35),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Icon(Icons.explore_outlined, size: size * 0.16, color: AppColors.backgroundDeep),
          ),
        ],
      ),
    );
  }

  List<Offset> _waypoints(double size) {
    const angles = [-40.0, 65.0, 190.0, 250.0];
    final radius = size * 0.35;
    final center = size / 2;
    return angles.map((deg) {
      final rad = deg * math.pi / 180;
      return Offset(
        center + radius * math.cos(rad) - 4.5,
        center + radius * math.sin(rad) - 4.5,
      );
    }).toList();
  }
}
