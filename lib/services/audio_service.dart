import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Audio service responsible for playing The Index Prescript sounds:
/// - index_message_1.wav: Plays while the prescript text is decoding/scrambling
/// - index_message_2.wav: Plays when the animation completes and the text is fully readable
class PrescriptAudioService {
  static final PrescriptAudioService _instance = PrescriptAudioService._internal();
  factory PrescriptAudioService() => _instance;
  PrescriptAudioService._internal();

  final AudioPlayer _scramblePlayer = AudioPlayer();
  final AudioPlayer _resolvedPlayer = AudioPlayer();

  bool _isPlayingScramble = false;

  /// Play the typing / decoding transmission sound (message 1)
  Future<void> playScramble() async {
    try {
      _isPlayingScramble = true;
      await _scramblePlayer.stop();
      await _scramblePlayer.setReleaseMode(ReleaseMode.loop);
      await _scramblePlayer.play(AssetSource('index_message_1.wav'));
    } catch (e) {
      debugPrint('AudioService playScramble error: $e');
    }
  }

  /// Stop message 1 immediately and cut it off completely
  Future<void> stopScramble() async {
    try {
      _isPlayingScramble = false;
      await _scramblePlayer.stop();
    } catch (e) {
      debugPrint('AudioService stopScramble error: $e');
    }
  }

  /// Stop message 1 immediately and play the completion sound (message 2)
  Future<void> playResolved() async {
    try {
      // Unconditionally cut off message 1 immediately
      _isPlayingScramble = false;
      await _scramblePlayer.stop();

      // Play message 2 (completion sound)
      await _resolvedPlayer.stop();
      await _resolvedPlayer.setReleaseMode(ReleaseMode.release);
      await _resolvedPlayer.play(AssetSource('index_message_2.wav'));
    } catch (e) {
      debugPrint('AudioService playResolved error: $e');
    }
  }

  /// Stop all playing sounds (e.g. when switching tab/app or leaving the screen)
  Future<void> stopAll() async {
    try {
      _isPlayingScramble = false;
      await _scramblePlayer.stop();
      await _resolvedPlayer.stop();
    } catch (e) {
      debugPrint('AudioService stopAll error: $e');
    }
  }

  /// Dispose audio players
  void dispose() {
    _scramblePlayer.dispose();
    _resolvedPlayer.dispose();
  }
}
