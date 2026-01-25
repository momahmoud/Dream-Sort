import 'package:audioplayers/audioplayers.dart';
import 'package:dream_sort/features/game/repo/game_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:vibration/vibration.dart';
import 'dart:math';

class AudioController {
  final GameRepository _repo;
  final AudioPlayer _musicPlayer = AudioPlayer();
  final Random _rng = Random();

  // Pool of audio players for low-latency SFX
  final List<AudioPlayer> _sfxPool = [];
  int _currentPoolIndex = 0;
  static const int _poolSize = 4;

  final ValueNotifier<bool> isMutedNotifier = ValueNotifier(false);

  // Public getter is better than private _isMuted for external checks if needed
  bool get isMuted => isMutedNotifier.value;

  AudioController(this._repo);

  Future<void> init() async {
    _musicPlayer.setReleaseMode(ReleaseMode.loop);

    // Initialize SFX pool for low-latency playback
    for (int i = 0; i < _poolSize; i++) {
      final player = AudioPlayer();
      await player.setPlayerMode(PlayerMode.lowLatency);
      _sfxPool.add(player);
    }

    // Load Muted State
    final muted = _repo.isMuted;
    isMutedNotifier.value = muted;

    if (!muted) {
      // playMusic(); // Auto-start music if not muted
    }
  }

  AudioPlayer _getNextPoolPlayer() {
    final player = _sfxPool[_currentPoolIndex];
    _currentPoolIndex = (_currentPoolIndex + 1) % _poolSize;
    return player;
  }

  Future<void> playPop() async {
    // Vibrate even if muted (unless user disabled vibration in future settings)
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 15); // Light tick
    }

    if (isMuted) return;
    try {
      final player = _getNextPoolPlayer();
      await player
          .stop(); // Stop previous sound if any (crucial for rapid overlapping)

      // Random pitch variation: 0.95 - 1.05
      final pitch = 0.95 + (_rng.nextDouble() * 0.1);
      await player.setPlaybackRate(pitch);
      await player.setVolume(1.0);

      await player.play(
        AssetSource('audio/pop.wav'),
        mode: PlayerMode.lowLatency,
      );
    } catch (e) {
      // Ignore errors
    }
  }

  // called when ball moves physically
  Future<void> playMove() async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 30); // Slight thud
    }

    if (isMuted) return;
    try {
      final player = _getNextPoolPlayer();
      await player.stop(); // Stop previous

      // Move sound with slight variance: 0.9 - 1.1
      final pitch = 0.9 + (_rng.nextDouble() * 0.2);
      await player.setPlaybackRate(pitch);
      await player.setVolume(0.8); // Slightly softer

      await player.play(
        AssetSource('audio/move.wav'),
        mode: PlayerMode.lowLatency,
      );
    } catch (_) {}
  }

  // New: High pitch pop for selection
  Future<void> playSelect() async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 10); // Crisp click
    }

    if (isMuted) return;
    try {
      final player = _getNextPoolPlayer();
      await player.stop();
      await player.setPlaybackRate(1.5); // Higher pitch for selection
      await player.setVolume(1.0);
      await player.play(
        AssetSource('audio/pop.wav'),
        mode: PlayerMode.lowLatency,
      );
    } catch (_) {}
  }

  // New: Low pitch pop for deselect/cancel
  Future<void> playDeselect() async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 10); // Light tick
    }

    if (isMuted) return;
    try {
      final player = _getNextPoolPlayer();
      await player.stop();
      await player.setPlaybackRate(0.8); // Lower pitch
      await player.setVolume(0.7); // Softer
      await player.play(
        AssetSource('audio/pop.wav'),
        mode: PlayerMode.lowLatency,
      );
    } catch (_) {}
  }

  // New: Stone Impact (Heavy, dull thud)
  Future<void> playStoneImpact() async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 40); // Heavy thud
    }

    if (isMuted) return;
    try {
      final player = _getNextPoolPlayer();
      await player.stop();
      // Very low pitch and volume to simulate a rock thud
      await player.setPlaybackRate(0.6);
      await player.setVolume(0.8);
      await player.play(
        AssetSource('audio/pop.wav'),
        mode: PlayerMode.lowLatency,
      );
    } catch (_) {}
  }

  // New: Error buzz (reusing pop with very low pitch/fast repetition if possible, or just a distinct low thud)
  Future<void> playError() async {
    if (await Vibration.hasVibrator()) {
      // Double shake for error
      if (await Vibration.hasCustomVibrationsSupport()) {
        Vibration.vibrate(
          pattern: [0, 50, 50, 50],
          intensities: [0, 128, 0, 128],
        );
      } else {
        Vibration.vibrate(duration: 200);
      }
    }

    if (isMuted) return;
    try {
      final player = _getNextPoolPlayer();
      await player.stop();
      await player.setPlaybackRate(0.5); // Very low pitch "thud"
      await player.setVolume(1.0);
      await player.play(
        AssetSource('audio/pop.wav'),
        mode: PlayerMode.lowLatency,
      );
    } catch (_) {}
  }

  Future<void> playWin() async {
    if (await Vibration.hasVibrator()) {
      // Fun Win Pattern
      if (await Vibration.hasCustomVibrationsSupport()) {
        Vibration.vibrate(pattern: [0, 50, 50, 100, 50, 200]);
      } else {
        Vibration.vibrate(duration: 500);
      }
    }

    if (isMuted) return;
    try {
      final p = AudioPlayer();
      await p.play(AssetSource('audio/win.wav'));
      p.onPlayerComplete.listen((_) => p.dispose());
    } catch (_) {}
  }

  Future<void> playBuy() async {
    if (isMuted) return;
    try {
      // Cha-ching!
      final p = AudioPlayer();
      await p.play(AssetSource('audio/buy.wav'));
      p.onPlayerComplete.listen((_) => p.dispose());
    } catch (_) {}
  }

  Future<void> playEquip() async {
    if (isMuted) return;
    try {
      final p = AudioPlayer();
      await p.play(AssetSource('audio/equip.wav'));
      p.onPlayerComplete.listen((_) => p.dispose());
    } catch (_) {}
  }

  Future<void> playComplete() async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 100);
    }

    if (isMuted) return;
    try {
      final p = AudioPlayer();
      await p.setPlaybackRate(1.2); // Slightly higher pitch
      await p.play(AssetSource('audio/equip.wav'));
      p.onPlayerComplete.listen((_) => p.dispose());
    } catch (_) {}
  }

  Future<void> playMusic() async {
    // Disabled by user request
    return;
  }

  void toggleMute() {
    final newState = !isMutedNotifier.value;
    isMutedNotifier.value = newState;
    _repo.setMuted(newState);

    // No need to handle music pausing/playing anymore
  }

  void dispose() {
    for (final player in _sfxPool) {
      player.dispose();
    }
    _musicPlayer.dispose();
  }
}
