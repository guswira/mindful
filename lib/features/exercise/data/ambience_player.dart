import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/breathing_preferences.dart';

part 'ambience_player.g.dart';

/// Loops one [AmbienceTrack] behind a breathing session.
///
/// Best-effort like [BreathingVoice]: an audio failure is logged and the
/// session carries on in silence.
class AmbiencePlayer {
  AmbiencePlayer({AudioPlayer Function()? createPlayer})
    : _createPlayer = createPlayer ?? AudioPlayer.new;

  final AudioPlayer Function() _createPlayer;
  AudioPlayer? _player;
  AmbienceTrack _track = AmbienceTrack.none;
  Future<void> _queue = Future.value();

  /// Starts looping [track] at [volume], or stops for
  /// [AmbienceTrack.none]. Replaying the current track only changes the
  /// volume (or resumes it after [pause]), so it doesn't restart from the
  /// top.
  Future<void> play(AmbienceTrack track, double volume) {
    final assetPath = track.assetPath;
    if (assetPath == null) {
      return stop();
    }
    return _guard(() async {
      final player = _player ??= await _newPlayer();
      await player.setVolume(volume);
      if (track == _track && player.state == PlayerState.paused) {
        await player.resume();
      } else if (track != _track || player.state != PlayerState.playing) {
        _track = track;
        await player.play(AssetSource(assetPath), volume: volume);
      }
    });
  }

  Future<void> setVolume(double volume) =>
      _guard(() async => _player?.setVolume(volume));

  Future<void> pause() => _guard(() async => _player?.pause());

  Future<void> stop() => _guard(() async {
    _track = AmbienceTrack.none;
    await _player?.stop();
  });

  Future<void> dispose() => _guard(() async {
    final player = _player;
    _player = null;
    _track = AmbienceTrack.none;
    await player?.dispose();
  });

  /// Mixes with other audio (the TTS voice, the user's own music) instead
  /// of taking exclusive focus and pausing it.
  Future<AudioPlayer> _newPlayer() async {
    final player = _createPlayer();
    await player.setAudioContext(
      AudioContextConfig(focus: AudioContextConfigFocus.mixWithOthers).build(),
    );
    await player.setReleaseMode(ReleaseMode.loop);
    return player;
  }

  /// Runs [action] after every earlier one finishes — volume slider drags
  /// fire many calls back to back, and overlapping ones could otherwise
  /// race to create two players.
  Future<void> _guard(Future<void> Function() action) {
    final next = _queue
        .then((_) => action())
        .catchError(
          (Object error) => debugPrint('Ambience playback failed: $error'),
        );
    _queue = next;
    return next;
  }
}

/// The app-wide [AmbiencePlayer] — only one session plays at a time, and
/// each one stops it when it ends.
@Riverpod(keepAlive: true)
AmbiencePlayer ambiencePlayer(Ref ref) {
  final player = AmbiencePlayer();
  ref.onDispose(player.dispose);
  return player;
}
