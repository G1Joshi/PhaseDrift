import 'package:flutter_test/flutter_test.dart';
import 'package:phasedrift/core/domain/domain.dart';
import 'package:phasedrift/core/services/services.dart';
import 'package:phasedrift/game/levels/levels.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ChamberRegistry & Structural Integrity', () {
    test('registry contains all 50 valid campaign chambers across 5 difficulty sectors (10 per sector)', () {
      expect(ChamberRegistry.totalChambers, equals(50));
      final chambers = ChamberRegistry.allChambers;
      expect(chambers.length, equals(50));

      for (var i = 0; i < chambers.length; i++) {
        final chamber = chambers[i];
        expect(chamber.chamberId, equals(i + 1));
        expect(
          chamber.isValid,
          isTrue,
          reason:
              'Chamber ${chamber.chamberId} (${chamber.name}) must pass validation',
        );
        expect(chamber.shards.length, equals(3));
        expect(chamber.parTimeMs, greaterThan(0));
        expect(chamber.width, greaterThanOrEqualTo(480.0));
        expect(chamber.height, greaterThanOrEqualTo(260.0));
      }

      // Check Sector distribution (10 chambers per sector)
      final veryEasyChambers = chambers
          .where((c) => c.tier == ChamberTier.veryEasy)
          .toList();
      expect(veryEasyChambers.length, equals(10));
      expect(veryEasyChambers.first.chamberId, equals(1));
      expect(veryEasyChambers.last.chamberId, equals(10));

      final easyChambers = chambers
          .where((c) => c.tier == ChamberTier.easy)
          .toList();
      expect(easyChambers.length, equals(10));
      expect(easyChambers.first.chamberId, equals(11));
      expect(easyChambers.last.chamberId, equals(20));

      final mediumChambers = chambers
          .where((c) => c.tier == ChamberTier.medium)
          .toList();
      expect(mediumChambers.length, equals(10));
      expect(mediumChambers.first.chamberId, equals(21));
      expect(mediumChambers.last.chamberId, equals(30));

      final hardChambers = chambers
          .where((c) => c.tier == ChamberTier.hard)
          .toList();
      expect(hardChambers.length, equals(10));
      expect(hardChambers.first.chamberId, equals(31));
      expect(hardChambers.last.chamberId, equals(40));

      final veryHardChambers = chambers
          .where((c) => c.tier == ChamberTier.veryHard)
          .toList();
      expect(veryHardChambers.length, equals(10));
      expect(veryHardChambers.first.chamberId, equals(41));
      expect(veryHardChambers.last.chamberId, equals(50));
    });

    test('getNextChamber advances sequentially and terminates at apex 50', () {
      expect(ChamberRegistry.getNextChamber(1)?.chamberId, equals(2));
      expect(ChamberRegistry.getNextChamber(49)?.chamberId, equals(50));
      expect(ChamberRegistry.getNextChamber(50), isNull);
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

    test('unlocks first chamber of each sector by default and locks internal chambers until cleared', () async {
      final progression = ProgressionService();

      // First chamber of each sector (1, 11, 21, 31, 41) is unlocked by default
      expect(await progression.isChamberUnlocked(1), isTrue);
      expect(await progression.isChamberUnlocked(11), isTrue);
      expect(await progression.isChamberUnlocked(21), isTrue);
      expect(await progression.isChamberUnlocked(31), isTrue);
      expect(await progression.isChamberUnlocked(41), isTrue);

      // Internal subsequent chambers are locked until previous is cleared
      expect(await progression.isChamberUnlocked(2), isFalse);
      expect(await progression.isChamberUnlocked(12), isFalse);
      expect(await progression.isChamberUnlocked(22), isFalse);
    });

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
