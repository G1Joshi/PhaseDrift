import 'dart:io';

import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phasedrift/core/domain/domain.dart';
import 'package:phasedrift/game/game.dart';

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
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async => Directory.systemTemp.path,
        );
  });

  group('PhaseBlock Logic', () {
    test('permeability toggles solidity dynamically based on active phase', () {
      final solarBlock = PhaseBlock(
        position: Vector2.zero(),
        size: Vector2.all(16.0),
        phaseType: PhaseType.solar,
      );

      final voidBlock = PhaseBlock(
        position: Vector2.zero(),
        size: Vector2.all(16.0),
        phaseType: PhaseType.voidPhase,
      );

      const solarPhase = SolarPhase();
      const voidPhase = VoidPhase();

      expect(solarBlock.isSolid(solarPhase), isTrue);
      expect(solarBlock.isSolid(voidPhase), isFalse);

      expect(voidBlock.isSolid(voidPhase), isTrue);
      expect(voidBlock.isSolid(solarPhase), isFalse);
    });
  });

  group('ChronoShard Logic', () {
    test(
      'collect triggers state transition once and rejects repeated collections',
      () {
        final shard = ChronoShard(
          position: Vector2(100.0, 100.0),
          shardIndex: 0,
        );

        expect(shard.isCollected, isFalse);

        final firstCollect = shard.collect();
        expect(firstCollect, isTrue);
        expect(shard.isCollected, isTrue);

        final secondCollect = shard.collect();
        expect(secondCollect, isFalse);
      },
    );
  });

  group('ChamberDefinition Logic', () {
    test('chamber 01 passes structural validation', () {
      final chamber = ChamberRegistry.getChamber(1);
      expect(chamber.isValid, isTrue);
      expect(chamber.chamberId, equals(1));
      expect(chamber.shards.length, equals(3));
      expect(chamber.universalBlocks, isNotEmpty);
      expect(chamber.phaseBlocks, isNotEmpty);
    });

    test('invalid shard count fails structural validation', () {
      final invalidChamber = ChamberDefinition(
        chamberId: 99,
        name: 'Invalid',
        spawnPoint: Vector2(50.0, 50.0),
        portalPosition: Vector2(200.0, 200.0),
        shards: [ChronoShardData(position: Vector2(10.0, 10.0), shardIndex: 0)],
      );

      expect(invalidChamber.isValid, isFalse);
    });
  });

  group('PhaseDriftGame Timer Flow', () {
    test(
      'timer begins on isTimerStarted activation and clears on restart',
      () async {
        final game = PhaseDriftGame();
        await game.onLoad();
        expect(game.isTimerStarted, isFalse);
        expect(game.elapsedMs, equals(0));

        // Updating without active timer does not advance elapsed time
        game.update(0.1);
        expect(game.elapsedMs, equals(0));

        game.isTimerStarted = true;
        game.update(0.1);
        expect(game.elapsedMs, equals(100));

        game.restartChamber();
        expect(game.isTimerStarted, isFalse);
        expect(game.elapsedMs, equals(0));
      },
    );
  });

  group('PhaseGate Kinetic Barrier Logic', () {
    test('gate defines phase property and advances pulse animation time', () {
      final gate = PhaseGate(
        position: Vector2(100, 100),
        size: Vector2(16, 48),
        phase: const SolarPhase(),
      );

      expect(gate.phase, isA<SolarPhase>());
      expect(gate.size.y, greaterThan(gate.size.x));

      // Update pulse animation
      gate.update(0.05);
      expect(gate.position.x, equals(100));
    });
  });

  group('TachyonPad Accelerator Logic', () {
    test(
      'boost velocity applies and cooldown timer throttles re-triggering',
      () {
        final pad = TachyonPad(
          position: Vector2(200, 200),
          size: Vector2(32, 8),
          boostVelocity: Vector2(340, 0),
        );

        expect(pad.boostVelocity.x, equals(340));
        expect(pad.canTrigger, isTrue);

        // Triggering sets cooldown
        final triggered = pad.trigger();
        expect(triggered, isTrue);
        expect(pad.canTrigger, isFalse);

        // Immediate second trigger is rejected
        expect(pad.trigger(), isFalse);

        // Advance time by 0.2s (half cooldown)
        pad.update(0.2);
        expect(pad.canTrigger, isFalse);

        // Advance remaining 0.25s (cooldown expires)
        pad.update(0.25);
        expect(pad.canTrigger, isTrue);
        expect(pad.trigger(), isTrue);
      },
    );
  });

  group('ChamberDirective Hologram Logic', () {
    test('directive initializes with title, subtitle, and size', () {
      final directive = ChamberDirective(
        position: Vector2(100, 200),
        title: '[SHIFT] DRIFT',
        subtitle: 'INVERT REALITY',
      );

      expect(directive.title, equals('[SHIFT] DRIFT'));
      expect(directive.subtitle, equals('INVERT REALITY'));
      expect(directive.size.x, equals(76.0));
      expect(directive.size.y, equals(22.0));

      directive.update(0.1);
      expect(directive.position.x, equals(100.0));
    });
  });

  group('FloatingCallout Feedback Logic', () {
    test('callout floats upward and expires after max lifetime', () {
      final callout = FloatingCallout(
        position: Vector2(100, 100),
        text: 'SLINGSHOT!',
      );

      expect(callout.position.y, equals(100.0));
      callout.update(0.2);
      expect(callout.position.y, lessThan(100.0));
    });
  });

  group('MovingPlatform Dynamic Carrier Logic', () {
    test(
      'moving platform oscillates between endpoints and computes velocity',
      () {
        final mover = MovingPlatform(
          startPosition: Vector2(100, 100),
          endPosition: Vector2(200, 100),
          size: Vector2(48, 14),
          speed: 100.0,
        );

        expect(mover.position.x, equals(100.0));
        expect(mover.isSolid(const SolarPhase()), isTrue);

        // Advance time by 0.5s
        mover.update(0.5);
        expect(mover.position.x, greaterThan(100.0));
        expect(mover.velocity.x, greaterThan(0.0));
      },
    );
  });

  group('PhaseLadder Conduit Logic', () {
    test('phase ladder activates according to active phase type', () {
      final universalLadder = PhaseLadder(
        position: Vector2(100, 100),
        size: Vector2(20, 80),
      );
      expect(universalLadder.isActive(const SolarPhase()), isTrue);
      expect(universalLadder.isActive(const VoidPhase()), isTrue);

      final voidLadder = PhaseLadder(
        position: Vector2(100, 100),
        size: Vector2(20, 80),
        phaseType: PhaseType.voidPhase,
      );
      expect(voidLadder.isActive(const SolarPhase()), isFalse);
      expect(voidLadder.isActive(const VoidPhase()), isTrue);
    });
  });
}
