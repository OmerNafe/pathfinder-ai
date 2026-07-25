/// Single source of truth for "what version of each legal document is
/// currently in force." Bumping one of these is what triggers existing
/// users to be asked to re-accept (see LegalAcceptanceService) — a plain
/// date string is enough since these are compared for exact equality, not
/// ordered like semver.
class LegalVersions {
  LegalVersions._();

  static const terms = '2026-07-25';
  static const privacy = '2026-07-25';

  /// Separate from terms/privacy on purpose — GDPR's "specific consent"
  /// principle and Apple's 2026 App Store rules on third-party AI data
  /// sharing both expect AI processing to be its own, distinct consent,
  /// not bundled into a general "I agree to everything" checkbox.
  static const aiProcessing = '2026-07-25';
}
