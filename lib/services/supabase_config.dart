import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Reads the two client-safe values from .env (see .env.example for why
/// only these two — never the service role or AI provider keys — belong
/// in a file the Flutter app bundles).
class SupabaseConfig {
  SupabaseConfig._();

  static String get url => dotenv.env['SUPABASE_URL'] ?? '';
  static String get anonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  /// False until both values are actually filled in. Lets the app boot and
  /// show a clear "backend not configured" state instead of crashing on an
  /// empty Supabase URL during setup.
  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
