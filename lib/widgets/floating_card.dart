import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// An elevated "floating" card with a soft ambient shadow and a subtle
/// lift-on-hover interaction (web/desktop pointer only — harmless no-op
/// on touch devices since MouseRegion simply never fires there).
class FloatingCard extends StatefulWidget {
  const FloatingCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.accentColor,
    this.onTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color? accentColor;
  final VoidCallback? onTap;

  @override
  State<FloatingCard> createState() => _FloatingCardState();
}

class _FloatingCardState extends State<FloatingCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final accent = widget.accentColor;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, _hovering ? -4 : 0, 0),
          padding: widget.padding,
          decoration: BoxDecoration(
            color: _hovering ? AppColors.surfaceCardHover : AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: accent != null ? accent.withValues(alpha: 0.35) : AppColors.hairline,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _hovering ? 0.45 : 0.32),
                blurRadius: _hovering ? 32 : 20,
                offset: Offset(0, _hovering ? 16 : 10),
              ),
              if (accent != null)
                BoxShadow(
                  color: accent.withValues(alpha: _hovering ? 0.18 : 0.08),
                  blurRadius: 40,
                  offset: const Offset(0, 8),
                ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
