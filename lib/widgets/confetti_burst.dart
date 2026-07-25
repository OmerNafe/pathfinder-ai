import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A brief celebratory confetti burst, shown as a transient full-screen
/// overlay that removes itself once the animation finishes. Call
/// [ConfettiBurst.play] right where something worth celebrating just
/// happened (a submitted checklist, a new streak milestone).
class ConfettiBurst {
  ConfettiBurst._();

  static void play(BuildContext context) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _ConfettiOverlay(onComplete: () => entry.remove()),
    );
    overlay.insert(entry);
  }
}

class _ConfettiPiece {
  _ConfettiPiece(math.Random rnd)
      : angle = rnd.nextDouble() * math.pi - math.pi * 1.5,
        speed = 260 + rnd.nextDouble() * 260,
        size = 5 + rnd.nextDouble() * 6,
        spin = (rnd.nextDouble() - 0.5) * 10,
        isCircle = rnd.nextBool(),
        startX = rnd.nextDouble(),
        color = _palette[rnd.nextInt(_palette.length)];

  final double angle;
  final double speed;
  final double size;
  final double spin;
  final bool isCircle;
  final double startX;
  final Color color;

  static const _palette = [
    AppColors.gold,
    AppColors.teal,
    AppColors.amber,
    Color(0xFFE8D7A8),
    Color(0xFF7FD8CC),
  ];
}

class _ConfettiOverlay extends StatefulWidget {
  const _ConfettiOverlay({required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<_ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<_ConfettiOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_ConfettiPiece> _pieces;

  @override
  void initState() {
    super.initState();
    final rnd = math.Random();
    _pieces = List.generate(64, (_) => _ConfettiPiece(rnd));
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))
      ..forward().whenComplete(widget.onComplete);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          size: Size.infinite,
          painter: _ConfettiPainter(pieces: _pieces, progress: _controller.value),
        ),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.pieces, required this.progress});

  final List<_ConfettiPiece> pieces;
  final double progress;

  static const double _gravity = 700;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final originY = size.height * 0.22;
    final t = progress;
    final fade = t < 0.7 ? 1.0 : (1 - (t - 0.7) / 0.3).clamp(0.0, 1.0);

    for (final piece in pieces) {
      final originX = size.width * piece.startX;
      final vx = math.cos(piece.angle) * piece.speed;
      final vy = math.sin(piece.angle) * piece.speed;

      final x = originX + vx * t;
      final y = originY + vy * t + 0.5 * _gravity * t * t;

      if (y > size.height + 20 || y < -20) continue;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(piece.spin * t * math.pi);
      paint.color = piece.color.withValues(alpha: fade);

      if (piece.isCircle) {
        canvas.drawCircle(Offset.zero, piece.size / 2, paint);
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: piece.size, height: piece.size * 0.55),
            const Radius.circular(1.5),
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => oldDelegate.progress != progress;
}
