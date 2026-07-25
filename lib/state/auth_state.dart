import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthState;
import '../services/auth_service.dart';

/// Streams Supabase's own auth state — empty (never emits) until the
/// backend is actually configured, so screens can watch this instead of
/// each reaching into AuthService directly.
final authStateProvider = StreamProvider<AuthState>((ref) {
  return AuthService.onAuthStateChange;
});

/// True once there's a signed-in session — false both when signed out and
/// when the backend isn't configured yet, which is the correct behavior
/// for gating routes either way.
final isSignedInProvider = Provider<bool>((ref) {
  final live = ref.watch(authStateProvider).value;
  if (live != null) return live.session != null;
  return AuthService.currentUser != null;
});
