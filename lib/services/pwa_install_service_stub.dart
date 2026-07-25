/// Non-web fallback (native tests, Windows/Android/iOS builds) — same API
/// as pwa_install_service_web.dart, always answering "nothing to do here"
/// since there's no browser install prompt outside a web context.
class PwaInstallService {
  PwaInstallService._();

  static bool get isPromptAvailable => false;
  static bool get isStandalone => false;
  static bool get isIOSSafari => false;
  static Future<bool> promptInstall() async => false;
}
