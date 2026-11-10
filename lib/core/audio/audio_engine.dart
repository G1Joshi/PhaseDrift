import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../domain/domain.dart';
import 'audio_constants.dart';

class AudioEngine {
  AudioEngine({
    AudioPlayer? solarPlayer,
    AudioPlayer? voidPlayer,
    AudioPlayer? sfxPlayer,
  }) : _solarPlayer = solarPlayer ?? AudioPlayer(),
       _voidPlayer = voidPlayer ?? AudioPlayer(),
       _sfxPlayer = sfxPlayer ?? AudioPlayer();

  static AudioEngine? _instance;
  static AudioEngine get instance => _instance ??= AudioEngine();

  final AudioPlayer _solarPlayer;
  final AudioPlayer _voidPlayer;
  final AudioPlayer _sfxPlayer;

  double _masterVolume = AudioConstants.defaultMasterVolume;
  double _musicVolume = AudioConstants.defaultMusicVolume;
  double _sfxVolume = AudioConstants.defaultSfxVolume;
  bool _isMuted = false;

  bool _isInitialized = false;
  bool _isPlaying = false;
  GamePhase _currentPhase = const SolarPhase();
  Timer? _crossfadeTimer;

  double get masterVolume => _masterVolume;
  double get musicVolume => _musicVolume;
  double get sfxVolume => _sfxVolume;
  bool get isMuted => _isMuted;
  bool get isPlaying => _isPlaying;
  GamePhase get currentPhase => _currentPhase;

  double get effectiveMusicVolume =>
      _isMuted ? 0.0 : (_masterVolume * _musicVolume).clamp(0.0, 1.0);

  double get effectiveSfxVolume =>
      _isMuted ? 0.0 : (_masterVolume * _sfxVolume).clamp(0.0, 1.0);

  static double calculateActiveStemVolume(double progress) {
    final p = progress.clamp(0.0, 1.0);
    return math.pow(p, 2.0).toDouble();
  }

  static double calculateInactiveStemVolume(double progress) {
    final p = progress.clamp(0.0, 1.0);
    return math.pow(1.0 - p, 2.0).toDouble();
  }

  static (double solarVolume, double voidVolume) calculateStemVolumes({
    required bool isSolarTarget,
    required double progress,
    required double baseVolume,
  }) {
    final active = calculateActiveStemVolume(progress);
    final inactive = calculateInactiveStemVolume(progress);

    if (isSolarTarget) {
      return (active * baseVolume, inactive * baseVolume);
    } else {
      return (inactive * baseVolume, active * baseVolume);
    }
  }

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      await _solarPlayer.setReleaseMode(ReleaseMode.loop);
      await _voidPlayer.setReleaseMode(ReleaseMode.loop);
      await _sfxPlayer.setReleaseMode(ReleaseMode.stop);

      await _solarPlayer.setSource(AssetSource(AudioConstants.stemSolar));
      await _voidPlayer.setSource(AssetSource(AudioConstants.stemVoid));

      _isInitialized = true;
    } catch (e) {
      debugPrint(
        'AudioEngine: Audio hardware unavailable in current runtime: $e',
      );
    }
  }

  Future<void> startMusic() async {
    if (!_isInitialized) await initialize();
    _isPlaying = true;

    final targetIsSolar = _currentPhase is SolarPhase;
    final solarVol = targetIsSolar ? effectiveMusicVolume : 0.0;
    final voidVol = targetIsSolar ? 0.0 : effectiveMusicVolume;

    try {
      await _solarPlayer.setVolume(solarVol);
      await _voidPlayer.setVolume(voidVol);

      await _solarPlayer.resume();
      await _voidPlayer.resume();
    } catch (e) {
      debugPrint('AudioEngine.startMusic error: $e');
    }
  }

  Future<void> pauseMusic() async {
    _isPlaying = false;
    _crossfadeTimer?.cancel();
    try {
      await _solarPlayer.pause();
      await _voidPlayer.pause();
    } catch (e) {
      debugPrint('AudioEngine.pauseMusic error: $e');
    }
  }

  Future<void> resumeMusic() async {
    if (_isPlaying) return;
    await startMusic();
  }

  Future<void> stopMusic() async {
    _isPlaying = false;
    _crossfadeTimer?.cancel();
    try {
      await _solarPlayer.stop();
      await _voidPlayer.stop();
    } catch (e) {
      debugPrint('AudioEngine.stopMusic error: $e');
    }
  }

  void crossfadeToPhase(GamePhase phase) {
    if (_currentPhase.runtimeType == phase.runtimeType &&
        _crossfadeTimer == null) {
      return;
    }
    _currentPhase = phase;
    final isSolarTarget = phase is SolarPhase;

    _crossfadeTimer?.cancel();
    const durationMs = AudioConstants.crossfadeDurationMs;
    const intervalMs = 15;
    const totalSteps = durationMs ~/ intervalMs;
    var step = 0;

    _crossfadeTimer = Timer.periodic(const Duration(milliseconds: intervalMs), (
      timer,
    ) {
      step++;
      final progress = (step / totalSteps).clamp(0.0, 1.0);
      final (solarVol, voidVol) = calculateStemVolumes(
        isSolarTarget: isSolarTarget,
        progress: progress,
        baseVolume: effectiveMusicVolume,
      );

      try {
        _solarPlayer.setVolume(solarVol);
        _voidPlayer.setVolume(voidVol);
      } catch (_) {}

      if (step >= totalSteps) {
        timer.cancel();
        _crossfadeTimer = null;
      }
    });
  }

  Future<void> playSfx(String assetPath) async {
    if (_isMuted || effectiveSfxVolume <= 0.0) return;
    try {
      await _sfxPlayer.setVolume(effectiveSfxVolume);
      await _sfxPlayer.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint('AudioEngine.playSfx error: $e');
    }
  }

  Future<void> playJump() => playSfx(AudioConstants.sfxJump);
  Future<void> playShift() => playSfx(AudioConstants.sfxShift);
  Future<void> playLand() => playSfx(AudioConstants.sfxLand);
  Future<void> playShard() => playSfx(AudioConstants.sfxShard);
  Future<void> playDeath() => playSfx(AudioConstants.sfxDeath);

  void setMasterVolume(double volume) {
    _masterVolume = volume.clamp(0.0, 1.0);
    _applyVolumeUpdates();
  }

  void setMusicVolume(double volume) {
    _musicVolume = volume.clamp(0.0, 1.0);
    _applyVolumeUpdates();
  }

  void setSfxVolume(double volume) {
    _sfxVolume = volume.clamp(0.0, 1.0);
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    _applyVolumeUpdates();
  }

  void _applyVolumeUpdates() {
    final targetIsSolar = _currentPhase is SolarPhase;
    final solarVol = targetIsSolar ? effectiveMusicVolume : 0.0;
    final voidVol = targetIsSolar ? 0.0 : effectiveMusicVolume;
    try {
      _solarPlayer.setVolume(solarVol);
      _voidPlayer.setVolume(voidVol);
    } catch (_) {}
  }

  void dispose() {
    _crossfadeTimer?.cancel();
    _solarPlayer.dispose();
    _voidPlayer.dispose();
    _sfxPlayer.dispose();
    if (_instance == this) {
      _instance = null;
    }
  }
}
