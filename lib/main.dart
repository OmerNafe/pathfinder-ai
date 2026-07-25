import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';
import 'services/app_sounds.dart';
import 'services/supabase_service.dart';
import 'theme/app_scroll_behavior.dart';
import 'theme/app_theme.dart';
import 'widgets/rotating_backdrop.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Neither of these may ever prevent the app from rendering — a missing
  // .env or an unreachable Supabase project should degrade to the "not
  // configured" state every screen already handles, not blank-screen the
  // whole app before runApp() is even called.
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Could not load .env — continuing without it: $e');
  }
  try {
    await SupabaseService.init();
  } catch (e) {
    debugPrint('Supabase did not initialize — continuing in local-only mode: $e');
  }

  runApp(const ProviderScope(child: PathFinderApp()));
}

class PathFinderApp extends ConsumerWidget {
  const PathFinderApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'PathFinder AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      scrollBehavior: AppScrollBehavior(),
      routerConfig: appRouter,
      builder: (context, child) => RotatingBackdrop(
        images: kAppBackdropImages,
        // Lives above the router, not inside any one screen, so it's a
        // single continuous instance that survives navigation instead of
        // resetting to the first photo every time a new page mounts.
        //
        // A soft click on every tap, app-wide — one listener here beats
        // wiring a sound call into every button on every screen.
        child: Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (_) => AppSounds.click(),
          child: child!,
        ),
      ),
    );
  }
}
