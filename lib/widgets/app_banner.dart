import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// A brief, self-dismissing top-of-screen banner — used both for the
/// "you're on the right path" milestone message and the welcome-back
/// progress recap on login. Deliberately not a Scaffold SnackBar: this
/// reads as a small celebratory moment rather than a generic status
/// message, and doesn't require (or compete with) a Scaffold ancestor.
void showAppBanner(
  BuildContext context, {
  required String message,
  IconData icon = Icons.auto_awesome,
  Color accentColor = AppColors.gold,
}) {
  final overlay = Overlay.of(context, rootOverlay: true);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => _AppBannerContent(
      message: message,
      icon: icon,
      accentColor: accentColor,
      onDone: () => entry.remove(),
    ),
  );
  overlay.insert(entry);
}

class _AppBannerContent extends StatefulWidget {
  const _AppBannerContent({
    required this.message,
    required this.icon,
    required this.accentColor,
    required this.onDone,
  });

  final String message;
  final IconData icon;
  final Color accentColor;
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
    _dismissTimer = Timer(const Duration(milliseconds: 2800), _dismiss);
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
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
                          Icon(widget.icon, size: 16, color: widget.accentColor),
                          const SizedBox(width: 10),
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
