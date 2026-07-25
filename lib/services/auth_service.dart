import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

/// Wraps every possible failure — Supabase not configured yet, a real auth
/// API error — behind one message the UI can just show, instead of the
/// screen needing to know which case it's handling.
class AppAuthException implements Exception {
  const AppAuthException(this.message);
  final String message;
  @override
  String toString() => message;
}

class AuthService {
  AuthService._();

  static GoTrueClient get _auth => SupabaseService.client.auth;

  static User? get currentUser => SupabaseService.isReady ? _auth.currentUser : null;

  static Stream<AuthState> get onAuthStateChange =>
      SupabaseService.isReady ? _auth.onAuthStateChange : const Stream.empty();

  static Future<void> signIn({required String email, required String password}) async {
    if (!SupabaseService.isReady) {
      throw const AppAuthException(
        'The backend isn\'t connected yet — ask whoever is setting up Supabase to finish that step.',
      );
    }
    try {
      await _auth.signInWithPassword(email: email, password: password);
    } on AuthApiException catch (e) {
      throw AppAuthException(e.message);
    }
  }

  /// Returns true if signup produced an immediate active session — false
  /// means Supabase is requiring email confirmation first, so the caller
  /// shouldn't navigate into an authenticated area yet.
  static Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    if (!SupabaseService.isReady) {
      throw const AppAuthException(
        'The backend isn\'t connected yet — ask whoever is setting up Supabase to finish that step.',
      );
    }
    try {
      final response = await _auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
        // Explicit rather than relying on Supabase's implicit fallback to
        // the request origin — that happened to work for local dev, but
        // shouldn't be left to chance once this runs somewhere else too.
        emailRedirectTo: Uri.base.origin,
      );
      return response.session != null;
    } on AuthApiException catch (e) {
      throw AppAuthException(e.message);
    }
  }

  static Future<void> signOut() async {
    if (!SupabaseService.isReady) return;
    await _auth.signOut();
  }

  /// Starts a real email change — Supabase sends a confirmation link to
  /// the new address (and, depending on project settings, the old one
  /// too) before the change actually takes effect. There is no column on
  /// `profiles` for email; auth.users' own email is the one source of
  /// truth, so this is the only honest way to let someone change it.
  static Future<void> updateEmail(String newEmail) async {
    if (!SupabaseService.isReady) {
      throw const AppAuthException(
        'The backend isn\'t connected yet — ask whoever is setting up Supabase to finish that step.',
      );
    }
    try {
      await _auth.updateUser(UserAttributes(email: newEmail));
    } on AuthApiException catch (e) {
      throw AppAuthException(e.message);
    }
  }

  /// Permanently deletes the signed-in applicant's account — the
  /// delete-account Edge Function derives who to delete from this same
  /// session's own token, removes their Storage files, then deletes the
  /// auth user, which cascades through every table via "on delete
  /// cascade". Irreversible; the caller is expected to have already
  /// confirmed with the applicant before calling this.
  static Future<void> deleteAccount() async {
    if (!SupabaseService.isReady) {
      throw const AppAuthException(
        'The backend isn\'t connected yet — ask whoever is setting up Supabase to finish that step.',
      );
    }
    try {
      final response = await SupabaseService.client.functions.invoke('delete-account');
      if (response.status != 200) {
        final data = response.data;
        final message =
            (data is Map && data['error'] is String) ? data['error'] as String : 'Could not delete your account right now.';
        throw AppAuthException(message);
      }
      await _auth.signOut();
    } on AppAuthException {
      rethrow;
    } catch (_) {
      throw const AppAuthException('Could not delete your account right now — try again.');
    }
  }

  /// Whether an account exists for [email] — see check-email-exists Edge
  /// Function for the security tradeoff this makes (most auth systems
  /// deliberately don't reveal this, to prevent email enumeration).
  static Future<bool> checkEmailExists(String email) async {
    if (!SupabaseService.isReady) {
      throw const AppAuthException(
        'The backend isn\'t connected yet — ask whoever is setting up Supabase to finish that step.',
      );
    }
    try {
      final response = await SupabaseService.client.functions.invoke(
        'check-email-exists',
        body: {'email': email},
      );
      final data = response.data;
      if (data is Map && data['exists'] is bool) return data['exists'] as bool;
      throw const AppAuthException('Could not check that email right now — try again.');
    } on AppAuthException {
      rethrow;
    } catch (_) {
      throw const AppAuthException('Could not check that email right now — try again.');
    }
  }

  /// Only call after [checkEmailExists] confirms the account is real —
  /// this is what actually sends the reset email.
  static Future<void> sendPasswordReset(String email) async {
    if (!SupabaseService.isReady) {
      throw const AppAuthException(
        'The backend isn\'t connected yet — ask whoever is setting up Supabase to finish that step.',
      );
    }
    try {
      await _auth.resetPasswordForEmail(email, redirectTo: Uri.base.origin);
    } on AuthApiException catch (e) {
      throw AppAuthException(e.message);
    }
  }

  /// Completes an email-confirmation (or password-recovery) link — the
  /// `?code=` query param Supabase appends when redirecting back to the
  /// app. Establishes a real session on success, matching what the
  /// confirmation-landing screen expects.
  static Future<void> exchangeCodeForSession(String code) async {
    if (!SupabaseService.isReady) {
      throw const AppAuthException(
        'The backend isn\'t connected yet — ask whoever is setting up Supabase to finish that step.',
      );
    }
    try {
      await _auth.exchangeCodeForSession(code);
    } on AuthApiException catch (e) {
      throw AppAuthException(e.message);
    }
  }
}
