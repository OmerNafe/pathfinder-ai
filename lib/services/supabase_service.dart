import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

/// Thin accessor so the rest of the app never touches Supabase.instance
/// directly — every repository checks [isReady] first and shows a real
/// "not connected" state rather than letting an uninitialized client throw.
class SupabaseService {
  SupabaseService._();

  static bool _initialized = false;

  static bool get isReady => _initialized;

  static Future<void> init() async {
    if (!SupabaseConfig.isConfigured) return;
    await Supabase.initialize(url: SupabaseConfig.url, publishableKey: SupabaseConfig.anonKey);
    _initialized = true;
  }

  static SupabaseClient get client => Supabase.instance.client;
}
