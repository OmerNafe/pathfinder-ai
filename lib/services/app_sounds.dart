import 'package:audioplayers/audioplayers.dart';

/// Short UI sounds, each on its own player instance so a celebration chime
/// firing right after a click doesn't cut itself off.
class AppSounds {
  AppSounds._();

  static final AudioPlayer _clickPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _celebratePlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  /// A soft, short pitched tick — a fast attack with an exponential decay,
  /// not a flat static-pitch beep — kept quiet enough to sit in the
  /// background rather than announce itself.
  static Future<void> click() => _play(_clickPlayer, 'audio/click.wav', volume: 0.35);

  /// A brighter ascending chime for completing something — a submitted
  /// checklist, a new streak milestone.
  static Future<void> celebrate() => _play(_celebratePlayer, 'audio/celebrate.wav', volume: 0.6);

  static Future<void> _play(AudioPlayer player, String asset, {required double volume}) async {
    try {
      await player.stop();
      await player.play(AssetSource(asset), volume: volume);
    } catch (_) {
      // Sound is polish, not a requirement — never let playback failure
      // (e.g. an unsupported browser codec) break the actual interaction.
    }
  }
}
