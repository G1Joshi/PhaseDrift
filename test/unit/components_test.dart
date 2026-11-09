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
}
