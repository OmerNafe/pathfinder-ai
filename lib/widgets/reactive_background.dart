import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../theme/app_colors.dart';

/// Wraps the page in the deep-indigo brand gradient plus a faint dot-grid
/// texture that reveals itself — brighter, larger, gold/teal-tinted — in a
/// halo that trails the cursor, like a light passing over an etched
/// surface. Mouse-only; harmless no-op on touch.
class ReactiveBackground extends StatefulWidget {
  const ReactiveBackground({super.key, required this.child});

  final Widget child;

  @override
  State<ReactiveBackground> createState() => _ReactiveBackgroundState();
}

class _ReactiveBackgroundState extends State<ReactiveBackground>
    with SingleTickerProviderStateMixin {
  Offset? _target;
  Offset _current = Offset.zero;
  double _targetOpacity = 0;
  double _currentOpacity = 0;
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    final target = _target ?? _current;
    final nextPosition = Offset.lerp(_current, target, 0.35)!;
    final nextOpacity = lerpDouble(_currentOpacity, _targetOpacity, 0.2)!;

    final positionMoved = (nextPosition - _current).distance > 0.05;
    final opacityMoved = (nextOpacity - _currentOpacity).abs() > 0.0015;

    if (positionMoved || opacityMoved) {
      setState(() {
        _current = nextPosition;
        _currentOpacity = nextOpacity;
      });
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      opaque: false,
      onHover: (event) {
        _target = event.localPosition;
        _targetOpacity = 1;
      },
      onExit: (_) => _targetOpacity = 0,
      child: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _TexturedGridPainter(
                    position: _current,
                    opacity: _currentOpacity,
                  ),
                ),
              ),
            ),
            widget.child,
          ],
        ),
      ),
    );
  }
}

/// A faint gold-to-teal dot grid across the whole surface. Each dot is
/// dim and small by default; within [_revealRadius] of the cursor, dots
/// grow brighter and larger the closer they are — a spotlight sweeping
/// texture into view rather than a flat glow blob.
class _TexturedGridPainter extends CustomPainter {
  _TexturedGridPainter({required this.position, required this.opacity});

  final Offset position;
  final double opacity;

  static const double _spacing = 42;
  static const double _revealRadius = 340;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final cols = (size.width / _spacing).ceil();
    final rows = (size.height / _spacing).ceil();

    for (var i = 0; i <= cols; i++) {
      for (var j = 0; j <= rows; j++) {
        final point = Offset(i * _spacing, j * _spacing);

        final distance = opacity > 0.001 ? (point - position).distance : double.infinity;
        final proximity = distance < _revealRadius ? (1 - distance / _revealRadius) : 0.0;
        final reveal = proximity * opacity;

        final hueMix = ((point.dx / size.width) + (point.dy / size.height)) / 2;
        final baseColor = Color.lerp(AppColors.gold, AppColors.teal, hueMix.clamp(0.0, 1.0))!;

        final alpha = (0.08 + reveal * 0.75).clamp(0.0, 0.9);
        final radius = 1.3 + reveal * 2.6;

        paint.color = baseColor.withValues(alpha: alpha);
        canvas.drawCircle(point, radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TexturedGridPainter oldDelegate) =>
      oldDelegate.position != position || oldDelegate.opacity != opacity;
}
