import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'data/document_requirements.dart';
import 'screens/about_screen.dart';
import 'screens/account_settings_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/document_upload_screen.dart';
import 'screens/email_confirmed_screen.dart';
import 'screens/exam_prep_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/gaps_overview_screen.dart';
import 'screens/landing_item_detail_screen.dart';
import 'screens/landing_overview_screen.dart';
import 'screens/licensing_registry_screen.dart';
import 'screens/pathway_certificate_screen.dart';
import 'screens/pathway_edit_screen.dart';
import 'screens/profile_edit_screen.dart';
import 'screens/profile_picture_screen.dart';
import 'screens/public_certificate_screen.dart';
import 'screens/registration_tracker_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/task_detail_screen.dart';
import 'screens/tasks_overview_screen.dart';

/// A plain fade instead of go_router's default platform transition — with
/// the rotating backdrop now living once above the router (see main.dart),
/// the default transition let the outgoing/incoming pages visibly flash
/// against it; a short, simple cross-fade reads as smooth instead.
CustomTransitionPage<void> _fadePage({required GoRouterState state, required Widget child}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 220),
    reverseTransitionDuration: const Duration(milliseconds: 180),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      );
    },
  );
}

/// Supabase's confirmation/recovery emails redirect to the app's bare
/// origin with a `?code=` query param — not a hash route — so that param
/// sits in Uri.base rather than anywhere go_router itself parses. If it's
/// there at boot, land on the screen that actually handles it instead of
/// the normal '/' default.
String get _initialLocation =>
    Uri.base.queryParameters.containsKey('code') ? '/auth/confirmed' : '/';

final appRouter = GoRouter(
  initialLocation: _initialLocation,
  routes: [
    GoRoute(path: '/', pageBuilder: (context, state) => _fadePage(state: state, child: const DashboardScreen())),
    GoRoute(
      path: '/auth/confirmed',
      pageBuilder: (context, state) => _fadePage(state: state, child: const EmailConfirmedScreen()),
    ),
    GoRoute(
      path: '/pathway/edit',
      pageBuilder: (context, state) => _fadePage(state: state, child: const PathwayEditScreen()),
    ),
    GoRoute(
      path: '/certificate',
      pageBuilder: (context, state) => _fadePage(state: state, child: const PathwayCertificateScreen()),
    ),
    GoRoute(
      path: '/c/:token',
      pageBuilder: (context, state) => _fadePage(
        state: state,
        child: PublicCertificateScreen(token: state.pathParameters['token']!),
      ),
    ),
    GoRoute(
      path: '/documents',
      pageBuilder: (context, state) => _fadePage(state: state, child: const DocumentUploadScreen()),
    ),
    GoRoute(
      path: '/registration',
      pageBuilder: (context, state) => _fadePage(state: state, child: const RegistrationTrackerScreen()),
    ),
    GoRoute(
      path: '/exam-prep',
      pageBuilder: (context, state) => _fadePage(state: state, child: const ExamPrepScreen()),
    ),
    GoRoute(
      path: '/gaps',
      pageBuilder: (context, state) => _fadePage(state: state, child: const GapsOverviewScreen()),
    ),
    GoRoute(
      path: '/tasks',
      pageBuilder: (context, state) => _fadePage(state: state, child: const TasksOverviewScreen()),
    ),
    GoRoute(
      path: '/tasks/:step',
      pageBuilder: (context, state) => _fadePage(
        state: state,
        child: TaskDetailScreen(step: int.parse(state.pathParameters['step']!)),
      ),
    ),
    GoRoute(
      path: '/landing',
      pageBuilder: (context, state) => _fadePage(state: state, child: const LandingOverviewScreen()),
    ),
    GoRoute(
      path: '/landing/:index',
      pageBuilder: (context, state) => _fadePage(
        state: state,
        child: LandingItemDetailScreen(index: int.parse(state.pathParameters['index']!)),
      ),
    ),
    GoRoute(
      path: '/about',
      pageBuilder: (context, state) => _fadePage(state: state, child: const AboutScreen()),
    ),
    GoRoute(
      path: '/licensing-registry',
      pageBuilder: (context, state) => _fadePage(state: state, child: const LicensingRegistryScreen()),
    ),
    GoRoute(
      path: '/licensing-registry/:category',
      pageBuilder: (context, state) {
        final categoryParam = state.pathParameters['category'];
        final category = OccupationCategory.values.firstWhere(
          (c) => c.name == categoryParam,
          orElse: () => OccupationCategory.healthcare,
        );
        return _fadePage(state: state, child: LicensingRegistryScreen(initialCategory: category));
      },
    ),
    GoRoute(
      path: '/profile/edit',
      pageBuilder: (context, state) => _fadePage(state: state, child: const ProfileEditScreen()),
    ),
    GoRoute(
      path: '/profile/picture',
      pageBuilder: (context, state) => _fadePage(state: state, child: const ProfilePictureScreen()),
    ),
    GoRoute(
      path: '/settings/account',
      pageBuilder: (context, state) => _fadePage(state: state, child: const AccountSettingsScreen()),
    ),
    GoRoute(
      path: '/sign-in',
      pageBuilder: (context, state) => _fadePage(state: state, child: const SignInScreen()),
    ),
    GoRoute(
      path: '/forgot-password',
      pageBuilder: (context, state) => _fadePage(state: state, child: const ForgotPasswordScreen()),
    ),
  ],
);
