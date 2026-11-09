import '../domain/domain.dart';
import 'milestone_service.dart';
import 'persistence_service.dart';

class ProgressionService {
  ProgressionService({PersistenceService? persistence})
    : _persistence = persistence ?? PersistenceService.instance;

  final PersistenceService _persistence;

  static ProgressionService? _instance;
  static ProgressionService get instance => _instance ??= ProgressionService();

  Future<void> _ensureInitialized() async {
    await _persistence.init();
  }

  static bool isFirstChamberOfSector(int chamberId) {
    return chamberId == 1 ||
        chamberId == 11 ||
        chamberId == 21 ||
        chamberId == 31 ||
        chamberId == 41;
  }

  Future<bool> isChamberUnlocked(int chamberId) async {
    if (chamberId <= 1 || isFirstChamberOfSector(chamberId)) return true;
    await _ensureInitialized();
    final currentRecord = _persistence.getChamberRecord(chamberId);
    if (currentRecord.isUnlocked) return true;
    final previousRecord = _persistence.getChamberRecord(chamberId - 1);
    return previousRecord.isCleared;
  }

  Future<ChamberRecord> loadRecord(int chamberId) async {
    await _ensureInitialized();
    final record = _persistence.getChamberRecord(chamberId);
    final unlocked = await isChamberUnlocked(chamberId);
    if (!record.isUnlocked && unlocked) {
      return ChamberRecord(
        chamberId: record.chamberId,
        bestTimeMs: record.bestTimeMs,
        collectedShardsMask: record.collectedShardsMask,
        isUnlocked: true,
        clearedAtEpochMs: record.clearedAtEpochMs,
      );
    }
    return record;
  }

  Future<List<ChamberRecord>> loadAllRecords(int totalChambers) async {
    await _ensureInitialized();
    final list = <ChamberRecord>[];
    for (var id = 1; id <= totalChambers; id++) {
      final rec = await loadRecord(id);
      list.add(rec);
    }
    return list;
  }

  Future<ChamberRecord> completeChamber({
    required int chamberId,
    required int completionTimeMs,
    required int shardsMask,
  }) async {
    await _ensureInitialized();
    final currentRecord = _persistence.getChamberRecord(chamberId);
    final updated = currentRecord.recordRun(
      completionTimeMs: completionTimeMs,
      newShardsMask: shardsMask,
    );
    await _persistence.saveChamberRecord(updated);

    // Auto-unlock next chamber
    final nextId = chamberId + 1;
    final nextRecord = _persistence.getChamberRecord(nextId);
    if (!nextRecord.isUnlocked) {
      final unlockedNext = ChamberRecord(
        chamberId: nextId,
        bestTimeMs: nextRecord.bestTimeMs,
        collectedShardsMask: nextRecord.collectedShardsMask,
        isUnlocked: true,
      );
      await _persistence.saveChamberRecord(unlockedNext);
    }

    // Update global player stats
    final stats = _persistence.getPlayerStats();
    final newShards = updated.shardCount - currentRecord.shardCount;
    var updatedStats = stats.addPlayTime(completionTimeMs);
    if (newShards > 0) {
      updatedStats = updatedStats.addShards(newShards);
    }
    await _persistence.savePlayerStats(updatedStats);

    // Evaluate tactical milestones
    final allRecords = await loadAllRecords(50);
    await MilestoneService.instance.evaluateAfterChamberRun(
      chamberId: chamberId,
      record: updated,
      allRecords: allRecords,
      totalCampaignChambers: 50,
      isProcedural: chamberId > 50,
    );

    return updated;
  }

  Future<void> resetProgression() async {
    await _ensureInitialized();
    await _persistence.resetProgressionTelemetry();
    await MilestoneService.instance.resetAllMilestones();
  }
}
