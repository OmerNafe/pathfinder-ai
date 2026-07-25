import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// The one snackbar treatment used app-wide — explicit white text, since
/// the default SnackBar text color read poorly against surfaceCardHover
/// (this was duplicated with no text color set across 9 screens; now it's
/// one place to get it right).
class AppSnackBar {
  AppSnackBar._();

  static void show(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: AppColors.textPrimary)),
        backgroundColor: AppColors.surfaceCardHover,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
