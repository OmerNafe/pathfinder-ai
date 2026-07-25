/// Real social/contact links, once they exist. Every value starts null on
/// purpose — [SocialLinksRow] hides an icon entirely rather than pointing
/// it at a placeholder or a dead link. Fill in a value here (a full URL
/// for the social platforms, a bare address for [email]) and it appears
/// everywhere the row is used, with no other code changes needed.
class SocialLinks {
  SocialLinks._();

  static const String? linkedIn = null;
  static const String? instagram = null;
  static const String? x = null;

  /// Bare address, no "mailto:" prefix — SocialLinksRow adds it.
  static const String? email = null;
}
