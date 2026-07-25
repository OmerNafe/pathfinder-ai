import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum RouteStopKind { origin, waypoint, arrival }

/// One stop along the applicant's route — content is deliberately pulled
/// from the same gap/task/registration vocabulary used on the dashboard
/// (see sample_dashboard_data.dart, registration_bodies.dart) rather than
/// invented marketing copy, so the hero and the product tell one story.
class RouteStop {
  const RouteStop({
    required this.kind,
    required this.tag,
    required this.title,
    required this.description,
    this.sourceNote,
    required this.dot,
    required this.anchor,
  });

  final RouteStopKind kind;
  final String tag;
  final String title;
  final String description;
  final String? sourceNote;

  /// Fractional (0..1) position of the dot on the drawn curve.
  final Offset dot;

  /// Fractional (0..1) position of the card's top-left corner.
  final Offset anchor;

  Color get accent => kind == RouteStopKind.waypoint ? AppColors.teal : AppColors.gold;
}

/// The signature "route" visual for the entry screen: a single drawn line
/// from the applicant's current qualifications to their licensed
/// destination, threading through real milestones instead of decorative
/// icons or stock photography — the wide-viewport counterpart to
/// [RouteTimeline].
class RouteDiagram extends StatefulWidget {
  const RouteDiagram({
    super.key,
    required this.stops,
    required this.curve,
    this.aspectRatio = 10 / 7,
  });

  final List<RouteStop> stops;

  /// Fractional (0..1) cubic-bezier control points describing the drawn
  /// line: [p0, cp1, cp2, p1, cp3, cp4, p2] — two cubic segments.
  final List<Offset> curve;
  final double aspectRatio;

  @override
  State<RouteDiagram> createState() => _RouteDiagramState();
}

class _RouteDiagramState extends State<RouteDiagram> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    final reduceMotion = WidgetsBinding.instance.platformDispatcher.accessibilityFeatures.disableAnimations;
    if (reduceMotion) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: Padding(
        padding: const EdgeInsets.only(top: 28),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(constraints.maxWidth, constraints.maxHeight);
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final progress = Curves.easeOutCubic.transform(_controller.value);
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _RoutePainter(
                          curve: widget.curve,
                          dots: widget.stops.map((s) => s.dot).toList(),
                          dotColors: widget.stops.map((s) => s.accent).toList(),
                          progress: progress,
                        ),
                      ),
                    ),
                    for (var i = 0; i < widget.stops.length; i++)
                      _buildCard(widget.stops[i], i, size),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildCard(RouteStop stop, int index, Size size) {
    final revealAt = (index / widget.stops.length) * 0.75;
    final localT = ((_controller.value - revealAt) / 0.25).clamp(0.0, 1.0);
    return Positioned(
      left: stop.anchor.dx * size.width,
      top: stop.anchor.dy * size.height,
      width: 214,
      child: Opacity(
        opacity: localT,
        child: Transform.translate(
          offset: Offset(0, (1 - localT) * 10),
          child: _RouteCard(stop: stop),
        ),
      ),
    );
  }
}

class _RoutePainter extends CustomPainter {
  _RoutePainter({required this.curve, required this.dots, required this.dotColors, required this.progress});

  final List<Offset> curve;
  final List<Offset> dots;
  final List<Color> dotColors;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    Offset p(Offset f) => Offset(f.dx * size.width, f.dy * size.height);

    final path = Path()..moveTo(p(curve[0]).dx, p(curve[0]).dy);
    for (var i = 1; i + 2 < curve.length; i += 3) {
      final cp1 = p(curve[i]);
      final cp2 = p(curve[i + 1]);
      final end = p(curve[i + 2]);
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, end.dx, end.dy);
    }

    final drawn = Path();
    for (final metric in path.computeMetrics()) {
      drawn.addPath(metric.extractPath(0, metric.length * progress), Offset.zero);
    }

    final dashed = _dashPath(drawn, dashLength: 7, gapLength: 8);

    canvas.drawPath(
      dashed,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round
        ..color = AppColors.gold.withValues(alpha: 0.85),
    );

    for (var i = 0; i < dots.length; i++) {
      final dotProgress = dots.length == 1 ? 0 : i / (dots.length - 1);
      if (progress < dotProgress - 0.02) continue;
      final center = p(dots[i]);
      final isFinal = i == dots.length - 1;
      final radius = isFinal ? 7.5 : 6.0;
      canvas.drawCircle(center, radius, Paint()..color = isFinal ? dotColors[i] : AppColors.backgroundDeep);
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2
          ..color = dotColors[i],
      );
    }
  }

  Path _dashPath(Path source, {required double dashLength, required double gapLength}) {
    final dashed = Path();
    for (final metric in source.computeMetrics()) {
      var distance = 0.0;
      var draw = true;
      while (distance < metric.length) {
        final next = distance + (draw ? dashLength : gapLength);
        if (draw) {
          dashed.addPath(metric.extractPath(distance, next.clamp(0, metric.length)), Offset.zero);
        }
        distance = next;
        draw = !draw;
      }
    }
    return dashed;
  }

  @override
  bool shouldRepaint(covariant _RoutePainter oldDelegate) => oldDelegate.progress != progress;
}

class _RouteCard extends StatefulWidget {
  const _RouteCard({required this.stop});
  final RouteStop stop;

  @override
  State<_RouteCard> createState() => _RouteCardState();
}

class _RouteCardState extends State<_RouteCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 13),
        transform: Matrix4.translationValues(0, _hovering ? -2 : 0, 0),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _hovering ? AppColors.hairlineStrong : AppColors.hairline),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _hovering ? 0.45 : 0.32),
              blurRadius: _hovering ? 32 : 22,
              offset: Offset(0, _hovering ? 14 : 10),
            ),
          ],
        ),
        child: RouteCardContent(stop: widget.stop),
      ),
    );
  }
}

/// The tag/title/description/source-note block shared by [RouteDiagram]'s
/// hover cards and [RouteTimeline]'s stacked rows.
class RouteCardContent extends StatelessWidget {
  const RouteCardContent({super.key, required this.stop});
  final RouteStop stop;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 5, height: 5, decoration: BoxDecoration(color: stop.accent, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(
              stop.tag.toUpperCase(),
              style: TextStyle(color: stop.accent, fontSize: 10.5, fontWeight: FontWeight.w600, letterSpacing: 0.6),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          stop.title,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13.5, fontWeight: FontWeight.w600, height: 1.3),
        ),
        const SizedBox(height: 4),
        Text(
          stop.description,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.45),
        ),
        if (stop.sourceNote != null) ...[
          const SizedBox(height: 6),
          Text(
            stop.sourceNote!,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 10, fontFamily: 'monospace'),
          ),
        ],
      ],
    );
  }
}

/// Narrow-viewport counterpart to [RouteDiagram] — the same stops laid out
/// as a plain vertical timeline instead of a positioned diagram, since
/// fractional-fraction placement stops being legible on phone-width screens.
class RouteTimeline extends StatelessWidget {
  const RouteTimeline({super.key, required this.stops});
  final List<RouteStop> stops;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < stops.length; i++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 26,
                  child: Column(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        margin: const EdgeInsets.only(top: 3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i == stops.length - 1 ? stops[i].accent : AppColors.backgroundDeep,
                          border: Border.all(color: stops[i].accent, width: 2),
                        ),
                      ),
                      if (i != stops.length - 1)
                        Expanded(
                          child: Container(
                            width: 2,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            color: AppColors.gold.withValues(alpha: 0.32),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: i == stops.length - 1 ? 0 : 22),
                    child: RouteCardContent(stop: stops[i]),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
