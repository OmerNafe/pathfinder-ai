import 'package:audioplayers/audioplayers.dart';

/// Non-web fallback (native mobile/desktop, and the Dart VM under `flutter
/// test`) — plays the original recorded WAV assets via audioplayers. Web
/// uses app_sounds_web.dart's synthesized tones instead (see
/// app_sounds.dart's conditional export); this file has no dart:js_interop
/// in it specifically so it stays safe to compile on the VM.
class AppSounds {
  AppSounds._();

  static final AudioPlayer _clickPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _celebratePlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  static Future<void> click() =>
      _play(_clickPlayer, 'audio/click.wav', volume: 0.28, playbackRate: 1.12);

  static Future<void> celebrate() => _play(_celebratePlayer, 'audio/celebrate.wav', volume: 0.6);

  static Future<void> _play(
    AudioPlayer player,
    String asset, {
    required double volume,
    double playbackRate = 1.0,
  }) async {
    try {
      await player.stop();
      await player.setPlaybackRate(playbackRate);
      await player.play(AssetSource(asset), volume: volume);
    } catch (_) {
      // Sound is polish, not a requirement — never let playback failure
      // break the actual interaction.
    }
  }
}
