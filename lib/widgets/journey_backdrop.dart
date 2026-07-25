import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// The single fixed sky photo used on sign-in and any other screen in that
/// same "before you're inside the app" journey (e.g. the email confirmation
/// landing) — deliberately not [RotatingBackdrop]: those are screens the
/// applicant returns to daily and shouldn't feel static, this is a one-time
/// moment that should feel consistent every time it's seen.
class JourneyBackdrop extends StatelessWidget {
  const JourneyBackdrop({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/hero_journey_sky.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.centerRight,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    AppColors.backgroundDeep,
                    AppColors.backgroundDeep.withValues(alpha: 0.5),
                  ],
                  stops: const [0.05, 0.9],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.backgroundDeep.withValues(alpha: 0.7),
                    AppColors.backgroundDeep.withValues(alpha: 0.88),
                  ],
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
