import 'package:audioplayers/audioplayers.dart';
import 'package:dream_sort/features/game/repo/game_repository.dart';
import 'package:flutter/foundation.dart';

class AudioController {
  final GameRepository _repo;
  final AudioPlayer _musicPlayer = AudioPlayer();

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
    if (isMuted) return;
    try {
      final player = _getNextPoolPlayer();
      await player.play(
        AssetSource('audio/pop.wav'),
        mode: PlayerMode.lowLatency,
      );
    } catch (e) {
      // Ignore errors
    }
  }

  // Called when ball moves physically
  Future<void> playMove() async {
    if (isMuted) return;
    try {
      final player = _getNextPoolPlayer();
      await player.play(
        AssetSource('audio/move.wav'),
        mode: PlayerMode.lowLatency,
      );
    } catch (_) {}
  }

  Future<void> playWin() async {
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
