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

  group('PersistenceService Settings & Telemetry State', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test(
      'persists and restores audio volume settings and mute state',
      () async {
        final persistence = PersistenceService();
        await persistence.init();

        // Default values when uninitialized
        final defaults = persistence.getAudioSettings();
        expect(defaults.$1, equals(0.8));
        expect(defaults.$2, equals(0.7));
        expect(defaults.$3, equals(0.9));
        expect(defaults.$4, isFalse);

        // Persist custom values
        await persistence.saveAudioSettings(
          master: 0.5,
          music: 0.4,
          sfx: 0.6,
          muted: true,
        );

        final updated = persistence.getAudioSettings();
        expect(updated.$1, equals(0.5));
        expect(updated.$2, equals(0.4));
        expect(updated.$3, equals(0.6));
        expect(updated.$4, isTrue);
      },
    );

    test(
      'persists and restores haptic feedback and motion reduction preferences',
      () async {
        final persistence = PersistenceService();
        await persistence.init();

        expect(persistence.getHapticsEnabled(), isTrue);
        expect(persistence.getReduceMotion(), isFalse);

        await persistence.saveHapticsEnabled(false);
        await persistence.saveReduceMotion(true);

        expect(persistence.getHapticsEnabled(), isFalse);
        expect(persistence.getReduceMotion(), isTrue);
      },
    );
  });

  group('MilestoneService Tactical Badges & Progression', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test(
      'loads default 16 locked milestones and triggers first shift unlock',
      () async {
        final persistence = PersistenceService();
        await persistence.init();
        final milestoneService = MilestoneService(persistence: persistence);

        final milestones = await milestoneService.loadMilestones();
        expect(milestones.length, equals(16));
        expect(await milestoneService.getUnlockedCount(), equals(0));

        // Trigger first shift
        final unlocked = await milestoneService.triggerUnlock('first_shift');
        expect(unlocked, isNotNull);
        expect(unlocked!.id, equals('first_shift'));
        expect(unlocked.isUnlocked, isTrue);
        expect(await milestoneService.getUnlockedCount(), equals(1));
        expect(await milestoneService.isUnlocked('first_shift'), isTrue);

        // Repeated trigger returns null (already unlocked)
        final repeat = await milestoneService.triggerUnlock('first_shift');
        expect(repeat, isNull);
      },
    );

    test('evaluates chamber run progression and awards awakening and collector badges', () async {
      final persistence = PersistenceService();
      await persistence.init();
      final milestoneService = MilestoneService(persistence: persistence);

      const record = ChamberRecord(
        chamberId: 1,
        bestTimeMs: 12000,
        collectedShardsMask: 7, // 3 shards
        isUnlocked: true,
      );

      final unlocked = await milestoneService.evaluateAfterChamberRun(
        chamberId: 1,
        record: record,
        allRecords: [record],
        totalCampaignChambers: 50,
        isProcedural: false,
      );

      final unlockedIds = unlocked.map((m) => m.id).toSet();
      expect(unlockedIds.contains('first_chamber'), isTrue);
      expect(unlockedIds.contains('speed_demon'), isTrue);
    });

    test(
      'resetProgression clears progression telemetry and relocks milestones',
      () async {
        final persistence = PersistenceService();
        await persistence.init();
        final progressionService = ProgressionService(persistence: persistence);
        final milestoneService = MilestoneService(persistence: persistence);

        // Unlock a milestone
        await milestoneService.triggerUnlock('first_shift');
        expect(await milestoneService.getUnlockedCount(), equals(1));

        // Reset
        await progressionService.resetProgression();
        expect(await milestoneService.getUnlockedCount(), equals(0));
      },
    );
  });

  group('Quantum Ghost Run Serialization & Persistence', () {
    test(
      'GhostRun serializes and deserializes accurately with frame coordinates',
      () async {
        final frames = [
          const GhostFrame(x: 50.0, y: 100.0, isSolar: true),
          const GhostFrame(x: 55.0, y: 100.0, isSolar: true, squishX: 1.2),
          const GhostFrame(x: 62.0, y: 95.0, isSolar: false, squishY: 0.8),
        ];
        final ghostRun = GhostRun(
          chamberId: 1,
          clearTimeMs: 100,
          frames: frames,
        );

        final json = ghostRun.toJson();
        final revived = GhostRun.fromJson(json);

        expect(revived.chamberId, equals(1));
        expect(revived.clearTimeMs, equals(100));
        expect(revived.frames.length, equals(3));
        expect(revived.frames[2].isSolar, isFalse);
        expect(revived.frames[2].x, equals(62.0));

        // Test persistence saving and retrieval
        SharedPreferences.setMockInitialValues({});
        final persistence = PersistenceService();
        await persistence.init();

        expect(persistence.getGhostEnabled(), isTrue);
        await persistence.saveGhostEnabled(false);
        expect(persistence.getGhostEnabled(), isFalse);

        await persistence.saveGhostRun(ghostRun);
        final loadedGhost = persistence.getGhostRun(1);
        expect(loadedGhost, isNotNull);
        expect(loadedGhost!.chamberId, equals(1));
        expect(loadedGhost.frames.length, equals(3));
      },
    );
  });
}
