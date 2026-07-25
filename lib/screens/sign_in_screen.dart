import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/sample_dashboard_data.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/floating_card.dart';
import '../widgets/route_diagram.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _joinEmailController = TextEditingController();
  final _joinPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureJoinPassword = true;
  int _activeTab = 0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _joinEmailController.dispose();
    _joinPasswordController.dispose();
    super.dispose();
  }

  InputDecoration _decoration(String label, {Widget? prefixIcon, Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
      filled: true,
      fillColor: AppColors.backgroundElevated,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.hairline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.hairline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.gold, width: 1.4),
      ),
    );
  }

  void _showSnack(String message) => AppSnackBar.show(context, message);

  Future<void> _signIn() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      _showSnack('Please enter your email and password.');
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      await AuthService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      context.go('/');
    } on AppAuthException catch (e) {
      if (!mounted) return;
      _showSnack(e.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _startJourney() async {
    if (_nameController.text.trim().isEmpty ||
        _joinEmailController.text.trim().isEmpty ||
        _joinPasswordController.text.isEmpty) {
      _showSnack('Please fill in your name, email, and password.');
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      final hasSession = await AuthService.signUp(
        email: _joinEmailController.text.trim(),
        password: _joinPasswordController.text,
        fullName: _nameController.text.trim(),
      );
      if (!mounted) return;
      if (hasSession) {
        // Occupation and destination aren't asked at signup — the applicant
        // picks those on the dedicated pathway screen right after, where a
        // full searchable list actually fits (see pathway_state.dart).
        context.go('/pathway/edit');
      } else {
        _showSnack('Account created — check your email to confirm it, then sign in.');
        setState(() => _activeTab = 0);
      }
    } on AppAuthException catch (e) {
      if (!mounted) return;
      _showSnack(e.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _JourneyBackdrop(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 980;

              final panel = _AuthPanel(
                activeTab: _activeTab,
                onTabChanged: (index) => setState(() => _activeTab = index),
                isSubmitting: _isSubmitting,
                decoration: _decoration,
                emailController: _emailController,
                passwordController: _passwordController,
                obscurePassword: _obscurePassword,
                onToggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
                onSignIn: _signIn,
                nameController: _nameController,
                joinEmailController: _joinEmailController,
                joinPasswordController: _joinPasswordController,
                obscureJoinPassword: _obscureJoinPassword,
                onToggleJoinObscure: () => setState(() => _obscureJoinPassword = !_obscureJoinPassword),
                onStartJourney: _startJourney,
              );

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isWide ? 64 : 20,
                  vertical: isWide ? 40 : 28,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1280),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _TopBar(isWide: isWide),
                        SizedBox(height: isWide ? 8 : 28),
                        if (isWide)
                          _WideHero(stops: _wideStops(), curve: _wideCurve)
                        else
                          _NarrowHero(stops: _narrowStops()),
                        SizedBox(height: isWide ? 56 : 40),
                        _LowerSection(isWide: isWide, panel: panel),
                        const SizedBox(height: 32),
                        const _FooterNote(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Route content — same vocabulary as the dashboard's real gaps/tasks/
// registration data (sample_dashboard_data.dart, registration_bodies.dart)
// rather than invented marketing copy.
// ---------------------------------------------------------------------

class _StopContent {
  const _StopContent({
    required this.kind,
    required this.tag,
    required this.title,
    required this.description,
    this.sourceNote,
  });

  final RouteStopKind kind;
  final String tag;
  final String title;
  final String description;
  final String? sourceNote;
}

const _stopContents = [
  _StopContent(
    kind: RouteStopKind.origin,
    tag: 'You are here',
    title: 'Medical Doctor, trained abroad',
    description: 'Primary degree and clinical transcripts ready for verification.',
  ),
  _StopContent(
    kind: RouteStopKind.waypoint,
    tag: 'Verified',
    title: 'Primary-source document check',
    description:
        'Degree transcript processed via the DataFlow portal — confirmed genuine by the issuing institution.',
  ),
  _StopContent(
    kind: RouteStopKind.waypoint,
    tag: 'Gap closing',
    title: 'English proficiency',
    description:
        'Academic IELTS Band 7.0 required — 6.0 uploaded, deficit flagged in Writing. Acceleration module assigned.',
  ),
  _StopContent(
    kind: RouteStopKind.waypoint,
    tag: 'Confirmed',
    title: 'College of Physicians & Surgeons',
    description: 'Registration steps mapped: MCCQE at Prometric → LMCC → provincial licence.',
    sourceNote: 'source verified · jul 2026',
  ),
  _StopContent(
    kind: RouteStopKind.arrival,
    tag: 'Arrival',
    title: 'Licensed to practise in Canada',
    description: 'Registered, credentialed, and cleared to work.',
  ),
];

const _wideDots = [
  Offset(0.04, 0.80),
  Offset(0.30, 0.56),
  Offset(0.55, 0.34),
  Offset(0.76, 0.19),
  Offset(0.95, 0.03),
];

const _wideAnchors = [
  Offset(0.0, 0.70),
  Offset(0.18, 0.46),
  Offset(0.38, 0.24),
  Offset(0.54, 0.08),
  Offset(0.68, -0.05),
];

const _wideCurve = [
  Offset(0.04, 0.80),
  Offset(0.26, 0.714),
  Offset(0.42, 0.429),
  Offset(0.62, 0.271),
  Offset(0.76, 0.171),
  Offset(0.88, 0.086),
  Offset(0.95, 0.029),
];

List<RouteStop> _wideStops() => [
      for (var i = 0; i < _stopContents.length; i++)
        RouteStop(
          kind: _stopContents[i].kind,
          tag: _stopContents[i].tag,
          title: _stopContents[i].title,
          description: _stopContents[i].description,
          sourceNote: _stopContents[i].sourceNote,
          dot: _wideDots[i],
          anchor: _wideAnchors[i],
        ),
    ];

List<RouteStop> _narrowStops() => [
      for (final c in _stopContents)
        RouteStop(
          kind: c.kind,
          tag: c.tag,
          title: c.title,
          description: c.description,
          sourceNote: c.sourceNote,
          dot: Offset.zero,
          anchor: Offset.zero,
        ),
    ];

// ---------------------------------------------------------------------
// Layout
// ---------------------------------------------------------------------

/// The entry screen's own backdrop — the applicant's journey, literally:
/// a window seat mid-flight, dimmed toward the left where the headline and
/// form sit so the photo reads as atmosphere rather than competing with
/// the text.
class _JourneyBackdrop extends StatelessWidget {
  const _JourneyBackdrop({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/hero_journey_sky.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.centerRight,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    AppColors.backgroundDeep,
                    AppColors.backgroundDeep.withValues(alpha: 0.5),
                  ],
                  stops: const [0.05, 0.9],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.backgroundDeep.withValues(alpha: 0.7),
                    AppColors.backgroundDeep.withValues(alpha: 0.88),
                  ],
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.isWide});
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    if (isWide) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [_BrandMark(size: 44), _RotatingTagline()],
      );
    }
    return const Column(
      children: [
        _BrandMark(size: 40),
        SizedBox(height: 18),
        _RotatingTagline(),
      ],
    );
  }
}

class _WideHero extends StatelessWidget {
  const _WideHero({required this.stops, required this.curve});
  final List<RouteStop> stops;
  final List<Offset> curve;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: const _HeroCopy(large: true),
        ),
        const SizedBox(width: 56),
        Expanded(
          child: RouteDiagram(stops: stops, curve: curve),
        ),
      ],
    );
  }
}

class _NarrowHero extends StatelessWidget {
  const _NarrowHero({required this.stops});
  final List<RouteStop> stops;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _HeroCopy(large: false),
        const SizedBox(height: 36),
        RouteTimeline(stops: stops),
      ],
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({required this.large});
  final bool large;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 16, height: 1, color: AppColors.gold),
              const SizedBox(width: 8),
              Text(
                'PATHFINDER AI',
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: large ? 2.2 : 1.8,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text.rich(
          TextSpan(
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: large ? 48 : 30,
                  height: 1.06,
                  letterSpacing: -0.5,
                ),
            children: const [
              TextSpan(text: 'From qualified\nhere, to '),
              TextSpan(text: 'licensed', style: TextStyle(color: AppColors.gold)),
              TextSpan(text: '\nthere.'),
            ],
          ),
        ),
        SizedBox(height: large ? 22 : 16),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: large ? 460 : 520),
          child: Text(
            'We map the real registration requirements between the credentials you '
            'hold and the ones your destination country demands — checked against '
            'official sources, not forum threads — and turn the distance into a '
            'route you can actually walk, one verified step at a time.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: large ? 16 : 14.5,
                  height: 1.6,
                ),
          ),
        ),
        SizedBox(height: large ? 32 : 26),
        const _StatsRow(),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 32,
      runSpacing: 14,
      children: [
        _Stat(value: '${targetCountryOptions.length}', label: 'destination countries'),
        _Stat(value: '${occupationOptions.length}', label: 'in-demand occupations'),
        const _Stat(value: '4-stage', label: 'guided pathway'),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            fontFamily: 'monospace',
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5, letterSpacing: 0.02),
        ),
      ],
    );
  }
}

class _LowerSection extends StatelessWidget {
  const _LowerSection({required this.isWide, required this.panel});
  final bool isWide;
  final Widget panel;

  @override
  Widget build(BuildContext context) {
    final recap = const _RecapSection();
    final divider = Container(
      margin: EdgeInsets.only(bottom: isWide ? 40 : 28),
      height: 1,
      color: AppColors.hairline,
    );

    if (isWide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          divider,
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 6, child: recap),
                const SizedBox(width: 48),
                Expanded(flex: 5, child: panel),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        divider,
        recap,
        const SizedBox(height: 32),
        panel,
      ],
    );
  }
}

class _RecapSection extends StatelessWidget {
  const _RecapSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Every requirement has a source.\nEvery step has an order.',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 24, height: 1.25),
        ),
        const SizedBox(height: 14),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Text(
            'The route above isn’t illustrative filler — it’s the same gap-to-task '
            'structure that drives the dashboard: a document gets verified, a shortfall '
            'gets flagged with the exact number that’s missing, and a regulator confirms '
            'the rest. Nothing is marked confirmed unless it was actually checked against '
            'the regulator’s own source.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.65),
          ),
        ),
        const SizedBox(height: 22),
        Container(
          constraints: const BoxConstraints(maxWidth: 480),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.tealSoft,
            border: Border.all(color: AppColors.teal.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12.5, height: 1.55),
              children: const [
                TextSpan(text: 'Verified vs. directional.  ', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                TextSpan(
                  text: 'Entries checked against an official source this cycle are marked '
                      'distinctly from ones still resting on general research — so you always '
                      'know how much to trust a given step.',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FooterNote extends StatelessWidget {
  const _FooterNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 20),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.hairline)),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        runSpacing: 8,
        children: [
          Text('PathFinder AI', style: TextStyle(color: AppColors.textMuted, fontSize: 11.5)),
          Text(
            'Organizational and informational — not a substitute for a licensed migration agent.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 11.5),
          ),
        ],
      ),
    );
  }
}

/// The "PathFinder AI" logo lockup — a gold/teal gradient mark plus the
/// wordmark, sized by [size].
class _BrandMark extends StatelessWidget {
  const _BrandMark({this.size = 32});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size * 0.28),
            gradient: const LinearGradient(
              colors: [AppColors.gold, AppColors.teal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Icon(Icons.explore_outlined, size: size * 0.56, color: AppColors.backgroundDeep),
        ),
        SizedBox(width: size * 0.32),
        Text(
          'PathFinder AI',
          style: TextStyle(
            fontFamily: AppTheme.displayFontFamily,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: size * 0.48,
          ),
        ),
      ],
    );
  }
}

/// Small pill cycling through short motivating phrases with a fade
/// transition — a quiet bit of movement above the fold rather than a
/// wall of static text.
class _RotatingTagline extends StatefulWidget {
  const _RotatingTagline();

  @override
  State<_RotatingTagline> createState() => _RotatingTaglineState();
}

class _RotatingTaglineState extends State<_RotatingTagline> {
  static const _phrases = [
    'Clarity over confusion.',
    'One step closer, every day.',
    'Your qualifications, recognized.',
    'From paperwork to possibility.',
  ];

  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 3400), (_) {
      if (!mounted) return;
      setState(() => _index = (_index + 1) % _phrases.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.goldSoft,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 450),
        transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
        child: Text(
          _phrases[_index],
          key: ValueKey(_index),
          style: const TextStyle(color: AppColors.gold, fontSize: 12.5, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Auth panel — Sign in / Start your journey
// ---------------------------------------------------------------------

class _AuthPanel extends StatelessWidget {
  const _AuthPanel({
    required this.activeTab,
    required this.onTabChanged,
    required this.isSubmitting,
    required this.decoration,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onToggleObscure,
    required this.onSignIn,
    required this.nameController,
    required this.joinEmailController,
    required this.joinPasswordController,
    required this.obscureJoinPassword,
    required this.onToggleJoinObscure,
    required this.onStartJourney,
  });

  final int activeTab;
  final ValueChanged<int> onTabChanged;
  final bool isSubmitting;
  final InputDecoration Function(String label, {Widget? prefixIcon, Widget? suffixIcon}) decoration;

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onToggleObscure;
  final VoidCallback onSignIn;

  final TextEditingController nameController;
  final TextEditingController joinEmailController;
  final TextEditingController joinPasswordController;
  final bool obscureJoinPassword;
  final VoidCallback onToggleJoinObscure;
  final VoidCallback onStartJourney;

  @override
  Widget build(BuildContext context) {
    return FloatingCard(
      accentColor: activeTab == 0 ? AppColors.gold : AppColors.teal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _AuthTabs(activeTab: activeTab, onChanged: onTabChanged),
          const SizedBox(height: 24),
          if (activeTab == 0)
            _SignInPane(
              decoration: decoration,
              emailController: emailController,
              passwordController: passwordController,
              obscurePassword: obscurePassword,
              onToggleObscure: onToggleObscure,
              onSignIn: onSignIn,
              isSubmitting: isSubmitting,
            )
          else
            _StartJourneyPane(
              decoration: decoration,
              nameController: nameController,
              emailController: joinEmailController,
              passwordController: joinPasswordController,
              obscurePassword: obscureJoinPassword,
              onToggleObscure: onToggleJoinObscure,
              onStartJourney: onStartJourney,
              isSubmitting: isSubmitting,
            ),
        ],
      ),
    );
  }
}

class _AuthTabs extends StatelessWidget {
  const _AuthTabs({required this.activeTab, required this.onChanged});
  final int activeTab;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.backgroundElevated,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            alignment: activeTab == 0 ? Alignment.centerLeft : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Container(
                decoration: BoxDecoration(
                  color: activeTab == 0 ? AppColors.gold : AppColors.teal,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(child: _tabButton(context, 'Sign in', 0)),
              Expanded(child: _tabButton(context, 'Start your journey', 1)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tabButton(BuildContext context, String label, int index) {
    final selected = activeTab == index;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(index),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? AppColors.backgroundDeep : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

class _SignInPane extends StatelessWidget {
  const _SignInPane({
    required this.decoration,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onToggleObscure,
    required this.onSignIn,
    required this.isSubmitting,
  });

  final InputDecoration Function(String label, {Widget? prefixIcon, Widget? suffixIcon}) decoration;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onToggleObscure;
  final VoidCallback onSignIn;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: AppColors.goldSoft, borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.lock_outline, color: AppColors.gold, size: 20),
        ),
        const SizedBox(height: 20),
        Text('Welcome back', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 6),
        Text('Sign in to continue your pathway.', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 28),
        TextField(
          controller: emailController,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          decoration: decoration('Email', prefixIcon: const Icon(Icons.mail_outline, color: AppColors.textMuted, size: 18)),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: passwordController,
          obscureText: obscurePassword,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          decoration: decoration(
            'Password',
            prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textMuted, size: 18),
            suffixIcon: IconButton(
              icon: Icon(
                obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: AppColors.textMuted,
                size: 18,
              ),
              onPressed: onToggleObscure,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => context.go('/forgot-password'),
            style: TextButton.styleFrom(foregroundColor: AppColors.gold, padding: EdgeInsets.zero),
            child: const Text('Forgot password?', style: TextStyle(fontSize: 12.5)),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: isSubmitting ? null : onSignIn,
            icon: isSubmitting
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.backgroundDeep),
                  )
                : const Icon(Icons.arrow_forward, size: 16),
            label: Text(
              isSubmitting ? 'Signing in…' : 'Sign in',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.backgroundDeep,
              disabledBackgroundColor: AppColors.gold.withValues(alpha: 0.5),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }
}

class _StartJourneyPane extends StatelessWidget {
  const _StartJourneyPane({
    required this.decoration,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onToggleObscure,
    required this.onStartJourney,
    required this.isSubmitting,
  });

  final InputDecoration Function(String label, {Widget? prefixIcon, Widget? suffixIcon}) decoration;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onToggleObscure;
  final VoidCallback onStartJourney;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.hairlineStrong),
            image: const DecorationImage(
              image: AssetImage('assets/images/growth_stage_0_seed.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text('Begin your pathway', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 6),
        Text(
          'Create your account — you’ll map your occupation and destination right after.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 28),
        TextField(
          controller: nameController,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          decoration: decoration('Full name', prefixIcon: const Icon(Icons.person_outline, color: AppColors.textMuted, size: 18)),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: emailController,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          decoration: decoration('Email', prefixIcon: const Icon(Icons.mail_outline, color: AppColors.textMuted, size: 18)),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: passwordController,
          obscureText: obscurePassword,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          decoration: decoration(
            'Password',
            prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textMuted, size: 18),
            suffixIcon: IconButton(
              icon: Icon(
                obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: AppColors.textMuted,
                size: 18,
              ),
              onPressed: onToggleObscure,
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: isSubmitting ? null : onStartJourney,
            icon: isSubmitting
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textPrimary),
                  )
                : const Icon(Icons.arrow_forward, size: 16),
            label: Text(
              isSubmitting ? 'Creating account…' : 'Start your journey',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.teal,
              foregroundColor: AppColors.textPrimary,
              disabledBackgroundColor: AppColors.teal.withValues(alpha: 0.5),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Pathway setup comes right after — check your email to confirm your account first.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11.5, color: AppColors.textMuted),
        ),
      ],
    );
  }
}
