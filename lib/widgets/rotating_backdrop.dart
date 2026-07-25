import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// The photo set used everywhere [RotatingBackdrop] appears — passports, a
/// family settling in, the destination skyline, in-flight — chosen to read
/// as freedom/new-beginning/settlement rather than generic stock travel
/// shots. Shared across every authenticated screen so the atmosphere never
/// jars when navigating from the dashboard into a subpage.
const kAppBackdropImages = [
  'assets/images/bg_passport_hold.jpg',
  'assets/images/bg_family_garden.jpg',
  'assets/images/hero_destination_city.jpg',
  'assets/images/bg_plane_golden_hour.jpg',
];

/// A full-bleed photo backdrop that slowly crossfades between [images] —
/// the dashboard's signature atmosphere, distinct from the sign-in screen's
/// single fixed photo since this is a screen the applicant returns to daily
/// and shouldn't feel static.
///
/// Faint (never above [_activeOpacity]) and scrimmed so the data-dense
/// foreground stays legible regardless of which photo is showing.
class RotatingBackdrop extends StatefulWidget {
  const RotatingBackdrop({
    super.key,
    required this.images,
    required this.child,
    this.interval = const Duration(seconds: 30),
  });

  final List<String> images;
  final Widget child;
  final Duration interval;

  static const double _activeOpacity = 0.52;

  @override
  State<RotatingBackdrop> createState() => _RotatingBackdropState();
}

class _RotatingBackdropState extends State<RotatingBackdrop> {
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final reduceMotion = WidgetsBinding.instance.platformDispatcher.accessibilityFeatures.disableAnimations;
    if (!reduceMotion && widget.images.length > 1) {
      _timer = Timer.periodic(widget.interval, (_) {
        if (!mounted) return;
        setState(() => _index = (_index + 1) % widget.images.length);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: Stack(
        children: [
          for (var i = 0; i < widget.images.length; i++)
            Positioned.fill(
              child: AnimatedOpacity(
                opacity: i == _index ? RotatingBackdrop._activeOpacity : 0,
                duration: const Duration(milliseconds: 2500),
                curve: Curves.easeInOut,
                child: Image.asset(widget.images[i], fit: BoxFit.cover),
              ),
            ),
          // Deliberately close together (0.55–0.68, not the old 0.48–0.85)
          // so the photo reads consistently across the whole viewport —
          // the old wide spread made short pages (little foreground content
          // to sit on the dark end) look like half the image had vanished.
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.backgroundDeep.withValues(alpha: 0.55),
                    AppColors.backgroundDeep.withValues(alpha: 0.6),
                    AppColors.backgroundDeep.withValues(alpha: 0.68),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          widget.child,
        ],
      ),
    );
  }
}
