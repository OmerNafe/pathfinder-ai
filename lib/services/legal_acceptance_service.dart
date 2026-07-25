import '../legal/legal_versions.dart';
import 'auth_service.dart';
import 'supabase_service.dart';

enum LegalDocument { terms, privacy, aiProcessing }

extension on LegalDocument {
  String get column => switch (this) {
        LegalDocument.terms => 'terms',
        LegalDocument.privacy => 'privacy',
        LegalDocument.aiProcessing => 'ai_processing',
      };

  String get currentVersion => switch (this) {
        LegalDocument.terms => LegalVersions.terms,
        LegalDocument.privacy => LegalVersions.privacy,
        LegalDocument.aiProcessing => LegalVersions.aiProcessing,
      };
}

/// Records and checks real consent — an in-memory checkbox tick is only
/// evidence anything happened if it's actually written down. Every write
/// here is an append-only audit row (see the legal_acceptances migration);
/// nothing about consent history is ever edited or deleted client-side.
class LegalAcceptanceService {
  LegalAcceptanceService._();

  /// Call right after a real session exists and the applicant has just
  /// agreed (ticked the signup checkbox, or confirmed their email after
  /// signing up before a session existed yet). Silently no-ops if the
  /// backend isn't configured or no one is signed in -- consent recording
  /// is best-effort audit trail, never something that should block the
  /// signup flow it's documenting.
  static Future<void> recordAcceptance(LegalDocument document) async {
    if (!SupabaseService.isReady) return;
    final userId = AuthService.currentUser?.id;
    if (userId == null) return;
    try {
      await SupabaseService.client.from('legal_acceptances').insert({
        'user_id': userId,
        'document': document.column,
        'version': document.currentVersion,
      });
    } catch (_) {
      // Best-effort — a logging failure must never block the applicant's
      // actual signup or upload.
    }
  }

  /// True if the signed-in user needs to re-accept Terms and/or Privacy —
  /// i.e. their most recent acceptance predates the current version. False
  /// (never blocks) when signed out or the backend isn't configured; this
  /// gate only matters once someone is actually inside the app.
  static Future<bool> needsReacceptance() async {
    if (!SupabaseService.isReady || AuthService.currentUser == null) return false;
    final termsOk = await hasAcceptedCurrentVersion(LegalDocument.terms);
    final privacyOk = await hasAcceptedCurrentVersion(LegalDocument.privacy);
    return !termsOk || !privacyOk;
  }

  /// True once the signed-in user has an acceptance row for [document] at
  /// exactly the current version — a version bump means everyone is asked
  /// again, on the theory that re-consent should be the default whenever
  /// what someone agreed to has actually changed.
  static Future<bool> hasAcceptedCurrentVersion(LegalDocument document) async {
    if (!SupabaseService.isReady) return false;
    final userId = AuthService.currentUser?.id;
    if (userId == null) return false;
    try {
      final rows = await SupabaseService.client
          .from('legal_acceptances')
          .select('id')
          .eq('user_id', userId)
          .eq('document', document.column)
          .eq('version', document.currentVersion)
          .limit(1);
      return (rows as List).isNotEmpty;
    } catch (_) {
      // Fail closed for consent checks -- if we can't confirm consent was
      // recorded, treat it as not yet given rather than assuming it was.
      return false;
    }
  }
}
