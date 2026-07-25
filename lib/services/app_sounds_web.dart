import 'dart:js_interop';

@JS('AudioContext')
extension type _JSAudioContext._(JSObject _) implements JSObject {
  external _JSAudioContext();
  external _JSOscillator createOscillator();
  external _JSGain createGain();
  external JSObject get destination;
  external double get currentTime;
  external String get state;
  external JSPromise<JSAny?> resume();
}

extension type _JSOscillator._(JSObject _) implements JSObject {
  external set type(String value);
  external _JSAudioParam get frequency;
  external void connect(JSObject destination);
  external void start([num when]);
  external void stop([num when]);
}

extension type _JSGain._(JSObject _) implements JSObject {
  external _JSAudioParam get gain;
  external void connect(JSObject destination);
}

extension type _JSAudioParam._(JSObject _) implements JSObject {
  external void setValueAtTime(num value, num time);
  external void exponentialRampToValueAtTime(num value, num time);
}

/// Real synthesized tones via the Web Audio API instead of a recorded WAV
/// file — this is the actual "different from a generic sample library
/// sound" fix: full control over pitch, timbre, and decay rather than
/// tweaking playback speed on the same source clip. Only ever imported on
/// web (see app_sounds.dart's conditional export) — a raw dart:js_interop
/// AudioContext has no meaning on the Dart VM `flutter test` runs on.
class AppSounds {
  AppSounds._();

  static _JSAudioContext? _ctx;

  static _JSAudioContext get _context => _ctx ??= _JSAudioContext();

  static void _tone({
    required double frequency,
    required double startTime,
    required double duration,
    required double peakGain,
    String type = 'sine',
  }) {
    final ctx = _context;
    final osc = ctx.createOscillator();
    final gain = ctx.createGain();
    final now = ctx.currentTime;

    osc.type = type;
    osc.frequency.setValueAtTime(frequency, now + startTime);

    // Fast soft attack, exponential decay -- a bell-like envelope rather
    // than a flat on/off beep. exponentialRamp can't target exactly 0, so
    // it ramps to a value low enough to be inaudible instead.
    gain.gain.setValueAtTime(0.0001, now + startTime);
    gain.gain.exponentialRampToValueAtTime(peakGain, now + startTime + 0.012);
    gain.gain.exponentialRampToValueAtTime(0.0001, now + startTime + duration);

    osc.connect(gain);
    gain.connect(ctx.destination);
    osc.start(now + startTime);
    osc.stop(now + startTime + duration + 0.05);
  }

  /// A single short, soft high tick — closer to a light finger-tap on
  /// glass than a synthesizer "boop."
  static Future<void> click() async {
    try {
      final ctx = _context;
      if (ctx.state == 'suspended') await ctx.resume().toDart;
      _tone(frequency: 1108.73, startTime: 0, duration: 0.045, peakGain: 0.09);
    } catch (_) {
      // Sound is polish, not a requirement.
    }
  }

  /// A gentle rising major-triad arpeggio (C6 -> E6 -> G6) instead of a
  /// single flat "ding" -- reads as a small, tasteful chime rather than a
  /// generic notification sound.
  static Future<void> celebrate() async {
    try {
      final ctx = _context;
      if (ctx.state == 'suspended') await ctx.resume().toDart;
      _tone(frequency: 1046.50, startTime: 0.00, duration: 0.20, peakGain: 0.16);
      _tone(frequency: 1318.51, startTime: 0.09, duration: 0.20, peakGain: 0.16);
      _tone(frequency: 1567.98, startTime: 0.18, duration: 0.30, peakGain: 0.17);
    } catch (_) {
      // Sound is polish, not a requirement.
    }
  }
}
