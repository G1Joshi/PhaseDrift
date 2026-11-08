import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phasedrift/core/audio/audio.dart';
import 'package:phasedrift/core/domain/domain.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('xyz.luan/audioplayers.global'),
          (MethodCall methodCall) async => 1,
        );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('xyz.luan/audioplayers'),
          (MethodCall methodCall) async => 1,
        );
  });

  group('AudioEngine Crossfade Math', () {
    test('calculateActiveStemVolume follows quadratic curve and clamps', () {
      expect(AudioEngine.calculateActiveStemVolume(0.0), closeTo(0.0, 0.001));
      expect(AudioEngine.calculateActiveStemVolume(0.5), closeTo(0.25, 0.001));
      expect(AudioEngine.calculateActiveStemVolume(1.0), closeTo(1.0, 0.001));
      expect(AudioEngine.calculateActiveStemVolume(-0.5), closeTo(0.0, 0.001));
      expect(AudioEngine.calculateActiveStemVolume(1.5), closeTo(1.0, 0.001));
    });

    test(
      'calculateInactiveStemVolume follows inverse quadratic curve and clamps',
      () {
        expect(
          AudioEngine.calculateInactiveStemVolume(0.0),
          closeTo(1.0, 0.001),
        );
        expect(
          AudioEngine.calculateInactiveStemVolume(0.5),
          closeTo(0.25, 0.001),
        );
        expect(
          AudioEngine.calculateInactiveStemVolume(1.0),
          closeTo(0.0, 0.001),
        );
        expect(
          AudioEngine.calculateInactiveStemVolume(-0.2),
          closeTo(1.0, 0.001),
        );
        expect(
          AudioEngine.calculateInactiveStemVolume(1.4),
          closeTo(0.0, 0.001),
        );
      },
    );

    test('calculateStemVolumes routes volumes based on target phase', () {
      // Shifting into Solar reality: Solar ascends, Void descends
      final (solarVol, voidVol) = AudioEngine.calculateStemVolumes(
        isSolarTarget: true,
        progress: 0.5,
        baseVolume: 0.8,
      );
      expect(solarVol, closeTo(0.20, 0.001)); // 0.25 * 0.8
      expect(voidVol, closeTo(0.20, 0.001)); // 0.25 * 0.8

      // Complete transition into Solar
      final (solarComplete, voidComplete) = AudioEngine.calculateStemVolumes(
        isSolarTarget: true,
        progress: 1.0,
        baseVolume: 1.0,
      );
      expect(solarComplete, closeTo(1.0, 0.001));
      expect(voidComplete, closeTo(0.0, 0.001));

      // Complete transition into Void
      final (solarVoid, voidVoid) = AudioEngine.calculateStemVolumes(
        isSolarTarget: false,
        progress: 1.0,
        baseVolume: 1.0,
      );
      expect(solarVoid, closeTo(0.0, 0.001));
      expect(voidVoid, closeTo(1.0, 0.001));
    });
  });

  group('AudioEngine Volume and Mute Controls', () {
    late AudioEngine engine;

    setUp(() {
      engine = AudioEngine();
    });

    tearDown(() {
      engine.dispose();
    });

    test('calculates effective music and sfx volumes accurately', () {
      engine.setMasterVolume(1.0);
      engine.setMusicVolume(0.80);
      engine.setSfxVolume(0.50);

      expect(engine.effectiveMusicVolume, closeTo(0.80, 0.001));
      expect(engine.effectiveSfxVolume, closeTo(0.50, 0.001));

      engine.setMasterVolume(0.50);
      expect(engine.effectiveMusicVolume, closeTo(0.40, 0.001));
      expect(engine.effectiveSfxVolume, closeTo(0.25, 0.001));
    });

    test('mute silences effective outputs and unmute restores levels', () {
      engine.setMasterVolume(1.0);
      engine.setMusicVolume(0.80);

      expect(engine.isMuted, isFalse);
      expect(engine.effectiveMusicVolume, closeTo(0.80, 0.001));

      engine.toggleMute();
      expect(engine.isMuted, isTrue);
      expect(engine.effectiveMusicVolume, equals(0.0));
      expect(engine.effectiveSfxVolume, equals(0.0));

      engine.toggleMute();
      expect(engine.isMuted, isFalse);
      expect(engine.effectiveMusicVolume, closeTo(0.80, 0.001));
    });

    test('crossfadeToPhase updates target reality phase', () {
      expect(engine.currentPhase is SolarPhase, isTrue);

      engine.crossfadeToPhase(const VoidPhase());
      expect(engine.currentPhase is VoidPhase, isTrue);

      engine.crossfadeToPhase(const SolarPhase());
      expect(engine.currentPhase is SolarPhase, isTrue);
    });
  });
}
