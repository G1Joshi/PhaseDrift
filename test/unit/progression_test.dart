import 'package:flutter_test/flutter_test.dart';
import 'package:phasedrift/core/domain/domain.dart';
import 'package:phasedrift/core/services/services.dart';
import 'package:phasedrift/game/levels/levels.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ChamberRegistry & Structural Integrity', () {
    test('registry contains all 8 valid campaign chambers', () {
      expect(ChamberRegistry.totalChambers, equals(8));
      final chambers = ChamberRegistry.allChambers;
      expect(chambers.length, equals(8));

      for (var i = 0; i < chambers.length; i++) {
        final chamber = chambers[i];
        expect(chamber.chamberId, equals(i + 1));
        expect(
          chamber.isValid,
          isTrue,
          reason: 'Chamber ${chamber.chamberId} must pass validation',
        );
        expect(chamber.shards.length, equals(3));
        expect(chamber.parTimeMs, greaterThan(0));
        expect(chamber.width, greaterThanOrEqualTo(560.0));
        expect(chamber.height, greaterThanOrEqualTo(320.0));
      }
    });

    test('getNextChamber advances sequentially and terminates at apex', () {
      expect(ChamberRegistry.getNextChamber(1)?.chamberId, equals(2));
      expect(ChamberRegistry.getNextChamber(7)?.chamberId, equals(8));
      expect(ChamberRegistry.getNextChamber(8), isNull);
    });
  });

  group('ChamberRank Evaluation Logic', () {
    const parTime = 20000; // 20.00s par

    test('awards S Rank only when under par time with all 3 shards', () {
      final rank = ChamberRank.calculate(
        completionTimeMs: 18500,
        parTimeMs: parTime,
        shardCount: 3,
      );
      expect(rank, equals(ChamberRank.s));
    });

    test('awards A Rank when under par but missing shards', () {
      final rank = ChamberRank.calculate(
        completionTimeMs: 18500,
        parTimeMs: parTime,
        shardCount: 2,
      );
      expect(rank, equals(ChamberRank.a));
    });

    test('awards A Rank when slightly over par (within 25%)', () {
      final rank = ChamberRank.calculate(
        completionTimeMs: 24000,
        parTimeMs: parTime,
        shardCount: 3,
      );
      expect(rank, equals(ChamberRank.a));
    });

    test('awards B Rank when within 60% of par or holding 2 shards', () {
      final rank = ChamberRank.calculate(
        completionTimeMs: 30000,
        parTimeMs: parTime,
        shardCount: 2,
      );
      expect(rank, equals(ChamberRank.b));
    });

    test('awards C Rank for slow completion with fewer shards', () {
      final rank = ChamberRank.calculate(
        completionTimeMs: 45000,
        parTimeMs: parTime,
        shardCount: 1,
      );
      expect(rank, equals(ChamberRank.c));
    });
  });

  group('ProgressionService Unlock Chain', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test(
      'unlocks Chamber 1 by default and locks Chamber 2 until cleared',
      () async {
        final progression = ProgressionService();

        expect(await progression.isChamberUnlocked(1), isTrue);
        expect(await progression.isChamberUnlocked(2), isFalse);
      },
    );

    test(
      'completing chamber records run and unlocks subsequent sector',
      () async {
        final progression = ProgressionService();

        await progression.completeChamber(
          chamberId: 1,
          completionTimeMs: 14200,
          shardsMask: 7, // 3 shards bitmask
        );

        final record = await progression.loadRecord(1);
        expect(record.isCleared, isTrue);
        expect(record.bestTimeMs, equals(14200));
        expect(record.shardCount, equals(3));

        // Chamber 2 should now be unlocked
        expect(await progression.isChamberUnlocked(2), isTrue);
      },
    );
  });
}
