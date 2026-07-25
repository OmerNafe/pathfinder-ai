import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'growth_trophy.dart';

/// A brief, self-dismissing top-of-screen banner — used for the
/// "you're on the right path" milestone message. Deliberately not a
/// Scaffold SnackBar: this reads as a small celebratory moment rather
/// than a generic status message, and doesn't require (or compete with)
/// a Scaffold ancestor.
void showAppBanner(
  BuildContext context, {
  required String message,
  IconData icon = Icons.auto_awesome,
  Color accentColor = AppColors.gold,
}) {
  _insertBanner(
    context,
    leading: Icon(icon, size: 16, color: accentColor),
    message: message,
    accentColor: accentColor,
  );
}

/// The richer login moment — shows the actual seed-to-tree growth photo
/// (see growth_trophy.dart) alongside the progress recap, not just an
/// icon, so "your pathway is growing" is something to actually see, not
/// only read.
void showWelcomeBackBanner(
  BuildContext context, {
  required String message,
  required int growthPoints,
}) {
  _insertBanner(
    context,
    leading: GrowthTrophy(growthPoints: growthPoints, size: 40),
    message: message,
    accentColor: AppColors.teal,
    duration: const Duration(milliseconds: 3400),
  );
}

void _insertBanner(
  BuildContext context, {
  required Widget leading,
  required String message,
  required Color accentColor,
  Duration duration = const Duration(milliseconds: 2800),
}) {
  final overlay = Overlay.of(context, rootOverlay: true);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => _AppBannerContent(
      leading: leading,
      message: message,
      accentColor: accentColor,
      duration: duration,
      onDone: () => entry.remove(),
    ),
  );
  overlay.insert(entry);
}

class _AppBannerContent extends StatefulWidget {
  const _AppBannerContent({
    required this.leading,
    required this.message,
    required this.accentColor,
    required this.duration,
    required this.onDone,
  });

  final Widget leading;
  final String message;
  final Color accentColor;
  final Duration duration;
  final VoidCallback onDone;

  @override
  State<_AppBannerContent> createState() => _AppBannerContentState();
}

class _AppBannerContentState extends State<_AppBannerContent> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 320));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, -0.4), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
    _dismissTimer = Timer(widget.duration, _dismiss);
  }

  Future<void> _dismiss() async {
    if (!mounted) return;
    await _controller.reverse();
    widget.onDone();
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 24,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: Material(
                  color: Colors.transparent,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCardHover,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: widget.accentColor.withValues(alpha: 0.4)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          widget.leading,
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              widget.message,
                              style: const TextStyle(
                                fontFamily: AppTheme.displayFontFamily,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
