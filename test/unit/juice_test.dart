import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phasedrift/core/services/services.dart';
import 'package:phasedrift/game/fx/fx.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ScreenShake Trauma Mechanics', () {
    test('trauma clamps between 0.0 and 1.0', () {
      final shake = ScreenShake();
      expect(shake.trauma, equals(0.0));

      shake.addTrauma(0.5);
      expect(shake.trauma, equals(0.5));

      shake.addTrauma(0.8);
      expect(shake.trauma, equals(1.0)); // Clamped at 1.0
    });

    test('trauma decays linearly over time', () {
      final shake = ScreenShake(decayRate: 2.0);
      shake.addTrauma(1.0);

      shake.update(0.25); // 1.0 - (2.0 * 0.25) = 0.5
      expect(shake.trauma, closeTo(0.5, 0.001));

      shake.update(0.30); // 0.5 - (2.0 * 0.3) = -0.1 -> 0.0
      expect(shake.trauma, equals(0.0));
    });

    test('reduceMotion completely bypasses camera trauma and shake', () {
      final shake = ScreenShake(reduceMotion: true);
      shake.addTrauma(1.0);
      expect(shake.trauma, equals(0.0));

      final (offset, angle) = shake.update(0.1);
      expect(offset.x, equals(0.0));
      expect(offset.y, equals(0.0));
      expect(angle, equals(0.0));
    });
  });

  group('ParticleFactory Geometry and Lifecycles', () {
    test('createShockwave initializes with correct colors and speed', () {
      final shockwave = ParticleFactory.createShockwave(
        center: Vector2(100.0, 200.0),
        primaryColor: Colors.amber,
        accentColor: Colors.cyan,
      );

      expect(shockwave.position, equals(Vector2(100.0, 200.0)));
      expect(shockwave.primaryColor, equals(Colors.amber));
      expect(shockwave.accentColor, equals(Colors.cyan));
      expect(shockwave.lifetime, equals(0.15));
    });

    test('createLandingBurst generates specified particle count', () {
      final burst = ParticleFactory.createLandingBurst(
        position: Vector2(50.0, 50.0),
        color: Colors.amber,
        count: 10,
      );

      expect(burst.length, equals(10));
      for (final p in burst) {
        expect(p.color, equals(Colors.amber));
        expect(p.lifetime, greaterThan(0.0));
      }
    });

    test('createDeathBurst generates vaporization particles with gravity', () {
      final burst = ParticleFactory.createDeathBurst(
        position: Vector2(120.0, 150.0),
        count: 16,
      );

      expect(burst.length, equals(16));
      for (final p in burst) {
        expect(p.gravity, greaterThan(0.0));
      }
    });
  });

  group('HapticsService State and Toggles', () {
    test('enables and disables haptics feedback cleanly', () {
      final haptics = HapticsService();
      expect(haptics.isEnabled, isTrue);

      haptics.isEnabled = false;
      expect(haptics.isEnabled, isFalse);

      // Invocations while disabled should return safely without error
      expect(haptics.triggerJump(), completes);
      expect(haptics.triggerShift(), completes);
      expect(haptics.triggerDeath(), completes);
    });
  });
}
