import 'package:flutter_test/flutter_test.dart';
import 'package:phasedrift/core/domain/domain.dart';
import 'package:phasedrift/core/services/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('GamePhase Logic', () {
    test('toggle switches between Solar and Void realities', () {
      const solar = SolarPhase();
      final toggledToVoid = solar.toggle();
      expect(toggledToVoid, isA<VoidPhase>());
      expect(toggledToVoid.gravityMultiplier, equals(-1.0));

      final toggledBackToSolar = toggledToVoid.toggle();
      expect(toggledBackToSolar, isA<SolarPhase>());
      expect(toggledBackToSolar.gravityMultiplier, equals(1.0));
    });

    test('platform permeability filters solid contact by phase', () {
      const solar = SolarPhase();
      const voidPhase = VoidPhase();

      expect(solar.isPlatformSolid(PhaseType.solar), isTrue);
      expect(solar.isPlatformSolid(PhaseType.voidPhase), isFalse);
      expect(solar.isPlatformSolid(PhaseType.universal), isTrue);

      expect(voidPhase.isPlatformSolid(PhaseType.voidPhase), isTrue);
      expect(voidPhase.isPlatformSolid(PhaseType.solar), isFalse);
      expect(voidPhase.isPlatformSolid(PhaseType.universal), isTrue);
    });
  });

  group('ChamberRecord Logic', () {
    test('recordRun retains best time and accumulates shard bitmask', () {
      final initial = ChamberRecord.initial(1, isUnlocked: true);

      final firstRun = initial.recordRun(
        completionTimeMs: 14500,
        newShardsMask: 0x01, // 001: shard 0
      );
      expect(firstRun.bestTimeMs, equals(14500));
      expect(firstRun.shardCount, equals(1));
      expect(firstRun.hasShard(0), isTrue);
      expect(firstRun.hasShard(1), isFalse);

      final slowerRun = firstRun.recordRun(
        completionTimeMs: 16200,
        newShardsMask: 0x02, // 010: shard 1
      );
      expect(slowerRun.bestTimeMs, equals(14500)); // Retains faster time
      expect(slowerRun.shardCount, equals(2)); // Accumulates shards
      expect(slowerRun.hasShard(0), isTrue);
      expect(slowerRun.hasShard(1), isTrue);

      final fasterRun = slowerRun.recordRun(
        completionTimeMs: 12800,
        newShardsMask: 0x04, // 100: shard 2
      );
      expect(fasterRun.bestTimeMs, equals(12800)); // Replaces with faster time
      expect(fasterRun.shardCount, equals(3));
    });

    test('countShards calculates correct bit population count', () {
      expect(ChamberRecord.countShards(0), equals(0));
      expect(ChamberRecord.countShards(1), equals(1));
      expect(ChamberRecord.countShards(3), equals(2));
      expect(ChamberRecord.countShards(7), equals(3));
      expect(ChamberRecord.countShards(15), equals(4));
    });
  });

  group('PersistenceService Logic', () {
    late PersistenceService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      service = PersistenceService(prefs);
    });

    test('saves and retrieves chamber record with fallback', () async {
      final defaultRecord = service.getChamberRecord(2);
      expect(defaultRecord.chamberId, equals(2));
      expect(defaultRecord.isUnlocked, isFalse);
      expect(defaultRecord.isCleared, isFalse);

      final updated = defaultRecord.recordRun(
        completionTimeMs: 22000,
        newShardsMask: 0x03,
      );
      await service.saveChamberRecord(updated);

      final loaded = service.getChamberRecord(2);
      expect(loaded.bestTimeMs, equals(22000));
      expect(loaded.shardCount, equals(2));
      expect(loaded.isUnlocked, isTrue);
    });

    test('saves and increments player stats across sessions', () async {
      expect(service.getPlayerStats().totalShifts, equals(0));

      final stats = const PlayerStats.initial()
          .registerShift()
          .registerShift()
          .registerDeath();

      await service.savePlayerStats(stats);

      final loaded = service.getPlayerStats();
      expect(loaded.totalShifts, equals(2));
      expect(loaded.totalDeaths, equals(1));
    });
  });
}
