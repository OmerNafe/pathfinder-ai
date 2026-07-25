import 'package:flutter/material.dart';
import '../services/app_sounds.dart';
import 'app_colors.dart';

/// Plays the click sound at the exact moment any Material button/InkWell
/// actually reacts to a press (its ink splash is created) — not on every
/// touch anywhere on screen (that was the old app-wide PointerDown
/// listener, which fired for scrolling and background taps too). Setting
/// this once here covers every button across the app without threading a
/// sound call through each of their onPressed handlers individually.
class _SoundSplashFactory extends InteractiveInkFeatureFactory {
  const _SoundSplashFactory();

  @override
  InteractiveInkFeature create({
    required MaterialInkController controller,
    required RenderBox referenceBox,
    required Offset position,
    required Color color,
    required TextDirection textDirection,
    bool containedInkWell = false,
    RectCallback? rectCallback,
    BorderRadius? borderRadius,
    ShapeBorder? customBorder,
    double? radius,
    VoidCallback? onRemoved,
  }) {
    AppSounds.click();
    return InkRipple.splashFactory.create(
      controller: controller,
      referenceBox: referenceBox,
      position: position,
      color: color,
      textDirection: textDirection,
      containedInkWell: containedInkWell,
      rectCallback: rectCallback,
      borderRadius: borderRadius,
      customBorder: customBorder,
      radius: radius,
      onRemoved: onRemoved,
    );
  }
}

class AppTheme {
  AppTheme._();

  static const displayFontFamily = 'PlayfairDisplay';
  static const bodyFontFamily = 'Inter';

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    // Every role defaults to Inter; specific roles are overridden to the
    // display serif below. Without this base pass, unlisted roles (e.g.
    // bodySmall, titleSmall) would silently fall back to the platform font.
    final interThemed = base.textTheme.apply(fontFamily: bodyFontFamily);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.backgroundDeep,
      splashFactory: const _SoundSplashFactory(),
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.gold,
        secondary: AppColors.teal,
        error: AppColors.danger,
        surface: AppColors.surfaceCard,
      ),
      textTheme: interThemed.copyWith(
            displayLarge: TextStyle(
              fontFamily: displayFontFamily,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
              fontSize: base.textTheme.displayLarge?.fontSize,
            ),
            displayMedium: TextStyle(
              fontFamily: displayFontFamily,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: base.textTheme.displayMedium?.fontSize,
            ),
            headlineMedium: TextStyle(
              fontFamily: displayFontFamily,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
              fontSize: base.textTheme.headlineMedium?.fontSize,
            ),
            headlineSmall: TextStyle(
              fontFamily: displayFontFamily,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: base.textTheme.headlineSmall?.fontSize,
            ),
            titleLarge: TextStyle(
              fontFamily: bodyFontFamily,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: base.textTheme.titleLarge?.fontSize,
            ),
            titleMedium: TextStyle(
              fontFamily: bodyFontFamily,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
              fontSize: base.textTheme.titleMedium?.fontSize,
            ),
            bodyLarge: TextStyle(
              fontFamily: bodyFontFamily,
              color: AppColors.textSecondary,
              height: 1.5,
              fontSize: base.textTheme.bodyLarge?.fontSize,
            ),
            bodyMedium: TextStyle(
              fontFamily: bodyFontFamily,
              color: AppColors.textSecondary,
              height: 1.5,
              fontSize: base.textTheme.bodyMedium?.fontSize,
            ),
            labelLarge: TextStyle(
              fontFamily: bodyFontFamily,
              color: AppColors.textPrimary,
              letterSpacing: 0.2,
              fontSize: base.textTheme.labelLarge?.fontSize,
            ),
          ),
      dividerColor: AppColors.hairline,
      scrollbarTheme: ScrollbarThemeData(
        thickness: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.dragged) || states.contains(WidgetState.hovered)) {
            return 6.0;
          }
          return 3.5;
        }),
        radius: const Radius.circular(8),
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.dragged)) {
            return AppColors.gold.withValues(alpha: 0.6);
          }
          if (states.contains(WidgetState.hovered)) {
            return AppColors.gold.withValues(alpha: 0.45);
          }
          return AppColors.textMuted.withValues(alpha: 0.3);
        }),
        trackColor: const WidgetStatePropertyAll(Colors.transparent),
        trackBorderColor: const WidgetStatePropertyAll(Colors.transparent),
        crossAxisMargin: 4,
        mainAxisMargin: 8,
        minThumbLength: 48,
        interactive: true,
      ),
    );
  }
}
