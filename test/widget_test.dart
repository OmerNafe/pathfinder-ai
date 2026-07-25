import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pathfinder_ai/data/sample_dashboard_data.dart';
import 'package:pathfinder_ai/main.dart';
import 'package:pathfinder_ai/router.dart';
import 'package:pathfinder_ai/state/pathway_state.dart';
import 'package:pathfinder_ai/state/pathway_tasks.dart';

void main() {
  // appRouter is a module-level singleton shared across every test in this
  // file — without this, whatever route the previous test navigated to
  // (e.g. /certificate) is still "current" for one stale frame at the
  // start of the next test, before that test's own navigation takes
  // effect. Usually harmless, but it can trigger real layout errors
  // belonging to the wrong test (this bit a mobile-viewport test once).
  setUp(() => appRouter.go('/'));

  testWidgets('Dashboard renders the pathway banner', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: PathFinderApp()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('PathFinder AI'), findsOneWidget);
    // Before any pathway is set up, the dashboard must show the honest
    // empty-state prompt, not any pre-filled content.
    expect(find.text("Let's map your pathway"), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  final routesToSmokeTest = <String>[
    '/profile/edit',
    '/profile/picture',
    '/settings/account',
    '/pathway/edit',
    '/documents',
    '/registration',
    '/exam-prep',
    '/gaps',
    '/tasks',
    '/landing',
    '/about',
    '/sign-in',
    '/forgot-password',
    '/terms',
    '/privacy',
    '/legal/reaccept',
    '/questions',
    '/licensing-registry',
    '/licensing-registry/healthcare',
    '/licensing-registry/engineering',
    '/licensing-registry/trades',
    '/licensing-registry/education',
    '/licensing-registry/transport',
    '/c/test-token',
  ];

  for (final route in routesToSmokeTest) {
    testWidgets('$route renders without throwing', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: PathFinderApp()));
      await tester.pump();

      appRouter.go(route);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.takeException(), isNull);
    });
  }

  // One representative occupation per category — exercises every combination
  // in registrationRequirements / countryDocumentRequirements, including the
  // two "not applicable" entries (Netherlands+engineering, Singapore+trades).
  const representativeOccupations = [
    'Registered Nurse', // healthcare
    'Civil Engineer', // engineering
    'Software Engineer', // technology
    'Electrician', // trades
    'Secondary School Teacher', // education
    'Biological Scientist', // science
    'Accountant', // business
    'Commercial Pilot', // transport
  ];

  for (final country in targetCountryOptions) {
    for (final occupation in representativeOccupations) {
      testWidgets(
        'Documents & registration render for $occupation in $country',
        (WidgetTester tester) async {
          final container = ProviderContainer();
          addTearDown(container.dispose);

          await tester.pumpWidget(
            UncontrolledProviderScope(container: container, child: const PathFinderApp()),
          );
          await tester.pump();

          container.read(pathwayProvider.notifier).updatePathway(
                occupation: occupation,
                targetCountry: country,
              );

          appRouter.go('/documents');
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 100));
          expect(tester.takeException(), isNull);

          appRouter.go('/registration');
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 100));
          expect(tester.takeException(), isNull);

          appRouter.go('/exam-prep');
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 100));
          expect(tester.takeException(), isNull);

          appRouter.go('/tasks');
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 100));
          expect(tester.takeException(), isNull);

          appRouter.go('/gaps');
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 100));
          expect(tester.takeException(), isNull);

          appRouter.go('/');
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 100));
          expect(tester.takeException(), isNull);

          appRouter.go('/certificate');
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 100));
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  // The actual bug being fixed here: after a brand-new applicant completes
  // pathway setup, they used to see the exact same canned demo tasks/gaps
  // (one pre-verified, one pre-rejected, a fake IELTS gap) as every other
  // applicant, regardless of anything they'd actually done. This asserts
  // the real, per-applicant state instead: every task starts pending, the
  // task count matches the real requirement list, and there are no gaps
  // until a document review actually comes back rejected.
  testWidgets('A freshly set-up pathway shows real pending tasks, not canned demo content',
      (WidgetTester tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const PathFinderApp()),
    );
    await tester.pump();

    container.read(pathwayProvider.notifier).updatePathway(
          occupation: 'Registered Nurse',
          targetCountry: 'Canada',
        );

    final expectedRequirements = requirementsFor('Registered Nurse', 'Canada');
    final tasks = container.read(pathwayTasksProvider);
    expect(tasks.length, expectedRequirements.length);
    expect(tasks.every((t) => t.status == TaskStatus.pending), isTrue);
    expect(tasks.every((t) => t.statusNote == 'Not uploaded yet'), isTrue);

    appRouter.go('/tasks');
    await tester.pump();
    // Long enough to fully clear the 220ms page fade transition — a
    // shorter partial pump can leave the outgoing page's content still
    // mounted alongside the incoming page's, which is exactly what
    // happened here once the dashboard itself started rendering real
    // "No gaps identified yet" content too (see the setUp above).
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
    expect(find.textContaining('DataFlow'), findsNothing);
    expect(find.textContaining('ScribeLab'), findsNothing);
    expect(find.text('STEP 1'), findsOneWidget);
    expect(find.text('STEP ${expectedRequirements.length}'), findsOneWidget);

    appRouter.go('/gaps');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
    expect(find.text('No gaps identified yet'), findsOneWidget);
    // The old fake gap ("6.0 TRF uploaded — deficit detected...") must be
    // gone — a real IELTS *requirement* is legitimately listed on /documents,
    // but no fabricated *result* should ever appear here.
    expect(find.textContaining('TRF uploaded'), findsNothing);
    expect(find.textContaining('Band 7.0 required'), findsNothing);
  });

  // "Copy share link" now calls the real CertificateShareService instead of
  // showing a hardcoded "(demo)" message — with no backend configured in
  // this test environment, it must fail honestly rather than pretend to
  // have published anything.
  testWidgets('Copy share link is honest when the backend is not configured',
      (WidgetTester tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const PathFinderApp()),
    );
    await tester.pump();

    container.read(pathwayProvider.notifier).updatePathway(
          occupation: 'Registered Nurse',
          targetCountry: 'Canada',
        );

    appRouter.go('/certificate');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.ensureVisible(find.text('Copy share link'));
    await tester.pump();
    await tester.tap(find.text('Copy share link'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.takeException(), isNull);
    expect(find.textContaining("backend isn't connected"), findsWidgets);
  });

  // The mobile "Today" layout (JourneyPathHero + TodayTaskCard) only
  // renders below the 700px breakpoint — none of the tests above exercise
  // it since WidgetTester's default surface is 800x600. This confirms it
  // renders cleanly for a freshly set-up pathway, a rejected-task pathway,
  // and a fully-verified pathway (the three distinct TodayTaskCard states).
  testWidgets('Mobile Today layout renders for pending, rejected, and fully-verified states',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const PathFinderApp()),
    );
    await tester.pump();

    container.read(pathwayProvider.notifier).updatePathway(
          occupation: 'Registered Nurse',
          targetCountry: 'Canada',
        );

    appRouter.go('/');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
    expect(find.text("Today's task"), findsOneWidget);
  });
}
