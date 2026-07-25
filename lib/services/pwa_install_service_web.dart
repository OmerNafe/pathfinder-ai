import 'dart:js_interop';

@JS('__pwaInstallEvent')
external JSAny? get _installEvent;

@JS('matchMedia')
external _MediaQueryList _matchMedia(String query);

extension type _MediaQueryList(JSObject _) implements JSObject {
  external bool get matches;
}

@JS('navigator.userAgent')
external String get _userAgent;

extension type _BeforeInstallPromptEvent(JSObject _) implements JSObject {
  external JSPromise<JSAny?> prompt();
}

/// Wraps the browser's native "install this web app" flow — captured in
/// web/index.html's beforeinstallprompt listener, triggered from here on a
/// real user tap (browsers require prompt() to run inside a user gesture,
/// so this can't just fire on its own). Chrome/Edge/Android support this;
/// iOS Safari has no install-prompt API at all, so [isIOSSafari] exists to
/// show manual "Add to Home Screen" instructions there instead — that's a
/// real platform gap this service works around, not something it can hide.
///
/// Only ever imported on web (see pwa_install_service.dart's conditional
/// export) — raw dart:js_interop externals like these have no VM
/// implementation, so this file can't be loaded when running `flutter
/// test`, which executes on the Dart VM, not through the web compiler.
class PwaInstallService {
  PwaInstallService._();

  /// True once the browser has actually fired beforeinstallprompt for this
  /// page load. False (not "not supported yet") is also the honest answer
  /// when the app is already installed, or the browser doesn't support it.
  static bool get isPromptAvailable {
    try {
      return _installEvent != null;
    } catch (_) {
      return false;
    }
  }

  /// True if already running as an installed PWA — nothing to prompt for.
  static bool get isStandalone {
    try {
      return _matchMedia('(display-mode: standalone)').matches;
    } catch (_) {
      return false;
    }
  }

  /// iOS Safari never fires beforeinstallprompt (no such API exists there)
  /// -- this is how the UI knows to show manual instructions instead of a
  /// button that would otherwise silently do nothing.
  static bool get isIOSSafari {
    try {
      final ua = _userAgent.toLowerCase();
      final isIOSDevice = ua.contains('iphone') || ua.contains('ipad');
      final isOtherIOSBrowser = ua.contains('crios') || ua.contains('fxios') || ua.contains('edgios');
      return isIOSDevice && !isOtherIOSBrowser;
    } catch (_) {
      return false;
    }
  }

  /// Shows the real native install prompt. Returns true if the browser
  /// says the user accepted it. The captured event can only be used once,
  /// so isPromptAvailable correctly goes false again after this.
  static Future<bool> promptInstall() async {
    final event = _installEvent;
    if (event == null) return false;
    try {
      final outcome = await (event as _BeforeInstallPromptEvent).prompt().toDart;
      return outcome != null;
    } catch (_) {
      return false;
    }
  }
}
