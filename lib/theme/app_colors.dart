import 'package:flutter/material.dart';

/// Private-bank premium palette: deep charcoal-indigo darks with
/// restrained gold and teal accents. No bright/saturated fills —
/// luxury reads through restraint, not vibrancy.
class AppColors {
  AppColors._();

  static const Color backgroundDeep = Color(0xFF0B0A1F);
  static const Color backgroundElevated = Color(0xFF14122B);
  static const Color surfaceCard = Color(0xFF1A1836);
  static const Color surfaceCardHover = Color(0xFF211E42);

  static const Color hairline = Color(0x1FFFFFFF); // 12% white
  static const Color hairlineStrong = Color(0x33FFFFFF); // 20% white

  static const Color textPrimary = Color(0xFFF4F1EA); // warm off-white
  static const Color textSecondary = Color(0xFFA7A2C4); // muted lavender-grey
  static const Color textMuted = Color(0xFF6E6A8F);

  static const Color gold = Color(0xFFC9A227); // premium accent
  static const Color goldSoft = Color(0x33C9A227);

  static const Color teal = Color(0xFF0D9488); // verified / success / progress
  static const Color tealSoft = Color(0x260D9488);

  static const Color amber = Color(0xFFD97706); // alerts / gaps
  static const Color amberSoft = Color(0x26D97706);

  static const Color danger = Color(0xFFB3453A);
  static const Color dangerSoft = Color(0x26B3453A);

  static const LinearGradient progressGradient = LinearGradient(
    colors: [teal, gold],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF0B0A1F), Color(0xFF120F2A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
