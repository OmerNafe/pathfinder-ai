import 'package:flutter/material.dart';

/// Hand-drawn vector glyphs for the 4 journey stages — deliberately not
/// Material Symbols and not a raster/AI-generated image set. Each is a
/// single geometric motif at a consistent stroke weight so the set reads
/// as one family: a lens for diagnosing, two points with the gap between
/// them for the gap analysis, a checklist for guided tasks, a landing
/// trajectory for the soft landing. Resolution-independent (vector,
/// painted at whatever size is requested) rather than a fixed-resolution
/// image.
enum JourneyStageGlyph { diagnostic, gapAnalysis, guidedTasks, softLanding }

class JourneyIcon extends StatelessWidget {
  const JourneyIcon({super.key, required this.glyph, required this.color, this.size = 24});

  final JourneyStageGlyph glyph;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: switch (glyph) {
        JourneyStageGlyph.diagnostic => _DiagnosticPainter(color),
        JourneyStageGlyph.gapAnalysis => _GapAnalysisPainter(color),
        JourneyStageGlyph.guidedTasks => _GuidedTasksPainter(color),
        JourneyStageGlyph.softLanding => _SoftLandingPainter(color),
      },
    );
  }
}

void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint,
    {required double dashLength, required double gapLength}) {
  final total = (end - start).distance;
  if (total == 0) return;
  final direction = (end - start) / total;
  double distance = 0;
  while (distance < total) {
    final segStart = start + direction * distance;
    final segEndDist = (distance + dashLength) > total ? total : (distance + dashLength);
    final segEnd = start + direction * segEndDist;
    canvas.drawLine(segStart, segEnd, paint);
    distance += dashLength + gapLength;
  }
}

void _drawDashedPath(Canvas canvas, Path path, Paint paint,
    {required double dashLength, required double gapLength}) {
  for (final metric in path.computeMetrics()) {
    double distance = 0;
    while (distance < metric.length) {
      final next = (distance + dashLength) > metric.length ? metric.length : (distance + dashLength);
      canvas.drawPath(metric.extractPath(distance, next), paint);
      distance += dashLength + gapLength;
    }
  }
}

/// A lens with a checkmark inside — diagnosing and confirming in one motif.
class _DiagnosticPainter extends CustomPainter {
  _DiagnosticPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final ringPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.085
      ..strokeCap = StrokeCap.round;

    final center = Offset(w * 0.42, size.height * 0.42);
    final radius = w * 0.27;
    canvas.drawCircle(center, radius, ringPaint);
    canvas.drawLine(
      center + Offset(radius * 0.72, radius * 0.72),
      Offset(w * 0.85, size.height * 0.85),
      ringPaint,
    );

    final checkPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.075
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final check = Path()
      ..moveTo(center.dx - radius * 0.45, center.dy)
      ..lineTo(center.dx - radius * 0.08, center.dy + radius * 0.38)
      ..lineTo(center.dx + radius * 0.55, center.dy - radius * 0.35);
    canvas.drawPath(check, checkPaint);
  }

  @override
  bool shouldRepaint(covariant _DiagnosticPainter oldDelegate) => oldDelegate.color != color;
}

/// A target with a marker on its way in, dashed trail behind it — reads
/// immediately as "not there yet, this is the distance left to close"
/// rather than needing the viewer to decode an abstract connector.
class _GapAnalysisPainter extends CustomPainter {
  _GapAnalysisPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final center = Offset(w * 0.58, h * 0.45);

    final ringPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.07;
    canvas.drawCircle(center, w * 0.32, ringPaint);
    canvas.drawCircle(center, w * 0.16, ringPaint);

    final centerDot = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, w * 0.05, centerDot);

    // The marker closing in on the target, with a dashed trail showing
    // where it came from.
    final markerStart = Offset(w * 0.12, h * 0.88);
    final markerEnd = Offset(w * 0.32, h * 0.64);
    final trailPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.065
      ..strokeCap = StrokeCap.round;
    _drawDashedLine(canvas, markerStart, markerEnd, trailPaint, dashLength: w * 0.05, gapLength: w * 0.045);

    final markerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(markerStart, w * 0.075, markerPaint);
  }

  @override
  bool shouldRepaint(covariant _GapAnalysisPainter oldDelegate) => oldDelegate.color != color;
}

/// A vertical run of checkpoints with short "label" strokes — a checklist
/// read as a path rather than a literal clipboard.
class _GuidedTasksPainter extends CustomPainter {
  _GuidedTasksPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final x = w * 0.32;
    final ys = [h * 0.2, h * 0.5, h * 0.8];

    final linePaint = Paint()
      ..color = color.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.06;
    canvas.drawLine(Offset(x, ys[0]), Offset(x, ys[2]), linePaint);

    final dotFill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(x, ys[0]), w * 0.1, dotFill);

    final checkPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.045
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final r = w * 0.1;
    final check = Path()
      ..moveTo(x - r * 0.45, ys[0])
      ..lineTo(x - r * 0.1, ys[0] + r * 0.35)
      ..lineTo(x + r * 0.5, ys[0] - r * 0.3);
    canvas.drawPath(check, checkPaint);

    final ringPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.075;
    canvas.drawCircle(Offset(x, ys[1]), w * 0.1, ringPaint);
    canvas.drawCircle(Offset(x, ys[2]), w * 0.1, ringPaint);

    final labelPaint = Paint()
      ..color = color.withValues(alpha: 0.65)
      ..strokeWidth = w * 0.06
      ..strokeCap = StrokeCap.round;
    for (final y in ys) {
      canvas.drawLine(Offset(x + w * 0.2, y), Offset(x + w * 0.5, y), labelPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GuidedTasksPainter oldDelegate) => oldDelegate.color != color;
}

/// A dashed descent trajectory meeting a ground line, with a small
/// wing-shaped mark at the touchdown point — arrival, not a literal jet.
class _SoftLandingPainter extends CustomPainter {
  _SoftLandingPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;

    final groundPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.075
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.14, h * 0.82), Offset(w * 0.86, h * 0.82), groundPaint);

    final path = Path()
      ..moveTo(w * 0.18, h * 0.2)
      ..quadraticBezierTo(w * 0.58, h * 0.26, w * 0.7, h * 0.68);
    final dashedPaint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.055
      ..strokeCap = StrokeCap.round;
    _drawDashedPath(canvas, path, dashedPaint, dashLength: w * 0.055, gapLength: w * 0.05);

    final tip = Offset(w * 0.72, h * 0.74);
    final planePath = Path()
      ..moveTo(tip.dx + w * 0.1, tip.dy - h * 0.02)
      ..lineTo(tip.dx - w * 0.14, tip.dy - h * 0.08)
      ..lineTo(tip.dx - w * 0.06, tip.dy + h * 0.1)
      ..close();
    final planeFill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(planePath, planeFill);
  }

  @override
  bool shouldRepaint(covariant _SoftLandingPainter oldDelegate) => oldDelegate.color != color;
}
