import 'package:flutter/material.dart';

/// Removes the stock Android-style glow/stretch overscroll flash — it reads
/// as a jarring flash of color against the dark premium background. The
/// scrollbar's own look is themed separately via [ThemeData.scrollbarTheme].
class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}
