import 'dart:async';

import '../domain/domain.dart';
import 'persistence_service.dart';

class MilestoneService {
  MilestoneService({PersistenceService? persistence})
    : _persistence = persistence ?? PersistenceService.instance;

  final PersistenceService _persistence;

  static MilestoneService? _instance;
  static MilestoneService get instance => _instance ??= MilestoneService();

  final _milestoneController = StreamController<Milestone>.broadcast();
  Stream<Milestone> get onMilestoneUnlocked => _milestoneController.stream;

  static final List<Milestone> _templates = [
    const Milestone(
      id: 'first_shift',
      title: 'FIRST POLARITY SHIFT',
      description: 'Trigger your first reality shift',
      tier: MilestoneTier.bronze,
      iconName: 'swap_horiz',
    ),
    const Milestone(
      id: 'first_chamber',
      title: 'QUANTUM AWAKENING',
      description: 'Clear Chamber 01',
      tier: MilestoneTier.bronze,
      iconName: 'play_arrow',
    ),
    const Milestone(
      id: 'tier_very_easy',
      title: 'INDUCTION COMPLETE',
      description: 'Clear all Sector 1 chambers (Chambers 001–010)',
      tier: MilestoneTier.bronze,
      iconName: 'check_circle',
    ),
    const Milestone(
      id: 'tier_easy',
      title: 'OPERATOR CALIBRATED',
      description: 'Clear all Sector 2 chambers (Chambers 011–020)',
      tier: MilestoneTier.silver,
      iconName: 'done_all',
    ),
    const Milestone(
      id: 'tier_medium',
      title: 'KINETIC VETERAN',
      description: 'Clear all Sector 3 chambers (Chambers 021–030)',
      tier: MilestoneTier.silver,
      iconName: 'flash_on',
    ),
    const Milestone(
      id: 'tier_hard',
      title: 'MASTER OF DIMENSIONS',
      description: 'Clear all Sector 4 chambers (Chambers 031–040)',
      tier: MilestoneTier.gold,
      iconName: 'military_tech',
    ),
    const Milestone(
      id: 'tier_very_hard',
      title: 'QUANTUM SINGULARITY',
      description: 'Conquer Chamber 050 and clear the Grand Campaign',
      tier: MilestoneTier.platinum,
      iconName: 'workspace_premium',
    ),
    const Milestone(
      id: 'slingshot_master',
      title: 'VELOCITY SLING',
      description: 'Achieve a slingshot speed exceeding 220 px/s',
      tier: MilestoneTier.silver,
      iconName: 'speed',
    ),
    const Milestone(
      id: 'ceiling_drifter',
      title: 'CEILING STRIDER',
      description: 'Run on Void ceilings for 5 seconds total',
      tier: MilestoneTier.bronze,
      iconName: 'vertical_align_top',
    ),
    const Milestone(
      id: 'shards_bronze',
      title: 'CHRONO COLLECTOR',
      description: 'Collect 25 Chrono Shards across sectors',
      tier: MilestoneTier.bronze,
      iconName: 'diamond_outlined',
    ),
    const Milestone(
      id: 'shards_silver',
      title: 'CHRONO HOARDER',
      description: 'Collect 75 Chrono Shards across sectors',
      tier: MilestoneTier.silver,
      iconName: 'diamond',
    ),
    const Milestone(
      id: 'shards_gold',
      title: 'TIMELINE RESTORER',
      description: 'Collect 150 Chrono Shards across sectors',
      tier: MilestoneTier.gold,
      iconName: 'auto_awesome',
    ),
    const Milestone(
      id: 'speed_demon',
      title: 'SUB-PAR PILOT',
      description: 'Earn an S-Rank in any chamber',
      tier: MilestoneTier.silver,
      iconName: 'timer',
    ),
    const Milestone(
      id: 'speed_master',
      title: 'APEX SPEEDSTER',
      description: 'Earn 10 S-Ranks across the campaign',
      tier: MilestoneTier.gold,
      iconName: 'stars',
    ),
    const Milestone(
      id: 'clean_run',
      title: 'UNTOUCHABLE',
      description: 'Clear 10 chambers without a single death',
      tier: MilestoneTier.gold,
      iconName: 'shield',
    ),
    const Milestone(
      id: 'endless_diver',
      title: 'QUANTUM DIVER',
      description: 'Clear a procedural chamber or Quantum Drift anomaly',
      tier: MilestoneTier.silver,
      iconName: 'all_inclusive',
    ),
  ];

  Future<void> _ensureInitialized() async {
    await _persistence.init();
  }

  Future<List<Milestone>> loadMilestones() async {
    await _ensureInitialized();
    final saved = _persistence.getMilestones();
    return _templates
        .map((tpl) {
          if (saved.containsKey(tpl.id)) {
            return Milestone.fromJson(
              saved[tpl.id] as Map<String, dynamic>,
              tpl,
            );
          }
          return tpl;
        })
        .toList(growable: false);
  }

  Future<int> getUnlockedCount() async {
    final list = await loadMilestones();
    return list.where((m) => m.isUnlocked).length;
  }

  Future<bool> isUnlocked(String milestoneId) async {
    final list = await loadMilestones();
    final match = list.where((m) => m.id == milestoneId).firstOrNull;
    return match?.isUnlocked ?? false;
  }

  Future<Milestone?> triggerUnlock(String milestoneId) async {
    await _ensureInitialized();
    final saved = Map<String, dynamic>.from(_persistence.getMilestones());
    final tpl = _templates.where((m) => m.id == milestoneId).firstOrNull;
    if (tpl == null) return null;

    if (saved.containsKey(milestoneId)) {
      final existing = Milestone.fromJson(
        saved[milestoneId] as Map<String, dynamic>,
        tpl,
      );
      if (existing.isUnlocked) return null; // already unlocked
    }

    final unlocked = tpl.unlock();
    saved[milestoneId] = unlocked.toJson();
    await _persistence.saveMilestones(saved);

    _milestoneController.add(unlocked);
    return unlocked;
  }

  Future<List<Milestone>> evaluateAfterChamberRun({
    required int chamberId,
    required ChamberRecord record,
    required List<ChamberRecord> allRecords,
    required int totalCampaignChambers,
    required bool isProcedural,
  }) async {
    await _ensureInitialized();
    final newlyUnlocked = <Milestone>[];

    // 1. First chamber
    if (chamberId == 1 && record.isCleared) {
      final u = await triggerUnlock('first_chamber');
      if (u != null) newlyUnlocked.add(u);
    }

    // 2. Procedural chamber
    if ((isProcedural || chamberId > totalCampaignChambers) &&
        record.isCleared) {
      final u = await triggerUnlock('endless_diver');
      if (u != null) newlyUnlocked.add(u);
    }

    // 3. Tiers
    final clearedIds = allRecords
        .where((r) => r.isCleared)
        .map((r) => r.chamberId)
        .toSet();
    if (record.isCleared) clearedIds.add(chamberId);

    // Tier 1: Very Easy (1..10)
    if (List.generate(10, (i) => i + 1).every(clearedIds.contains)) {
      final u = await triggerUnlock('tier_very_easy');
      if (u != null) newlyUnlocked.add(u);
    }

    // Tier 2: Easy (11..20)
    if (List.generate(10, (i) => i + 11).every(clearedIds.contains)) {
      final u = await triggerUnlock('tier_easy');
      if (u != null) newlyUnlocked.add(u);
    }

    // Tier 3: Medium (21..30)
    if (List.generate(10, (i) => i + 21).every(clearedIds.contains)) {
      final u = await triggerUnlock('tier_medium');
      if (u != null) newlyUnlocked.add(u);
    }

    // Tier 4: Hard (31..40)
    if (List.generate(10, (i) => i + 31).every(clearedIds.contains)) {
      final u = await triggerUnlock('tier_hard');
      if (u != null) newlyUnlocked.add(u);
    }

    // Tier 5: Very Hard (41..50)
    if (List.generate(10, (i) => i + 41).every(clearedIds.contains)) {
      final u = await triggerUnlock('tier_very_hard');
      if (u != null) newlyUnlocked.add(u);
    }

    // 4. Shards
    final totalShards = allRecords.fold<int>(0, (sum, r) => sum + r.shardCount);
    if (totalShards >= 25) {
      final u = await triggerUnlock('shards_bronze');
      if (u != null) newlyUnlocked.add(u);
    }
    if (totalShards >= 75) {
      final u = await triggerUnlock('shards_silver');
      if (u != null) newlyUnlocked.add(u);
    }
    if (totalShards >= 150) {
      final u = await triggerUnlock('shards_gold');
      if (u != null) newlyUnlocked.add(u);
    }

    // 5. Speed Ranks (S-Rank checks: cleared with all 3 Chrono Shards)
    final sRanks = allRecords
        .where((r) => r.isCleared && r.shardCount == 3)
        .length;
    if (sRanks >= 1) {
      final u = await triggerUnlock('speed_demon');
      if (u != null) newlyUnlocked.add(u);
    }
    if (sRanks >= 10) {
      final u = await triggerUnlock('speed_master');
      if (u != null) newlyUnlocked.add(u);
    }

    // 6. Clean run (10 chambers cleared across campaign)
    final clearedRuns = allRecords.where((r) => r.isCleared).length;
    if (clearedRuns >= 10) {
      final u = await triggerUnlock('clean_run');
      if (u != null) newlyUnlocked.add(u);
    }

    return newlyUnlocked;
  }

  Future<void> resetAllMilestones() async {
    await _ensureInitialized();
    await _persistence.saveMilestones({});
  }

  void dispose() {
    _milestoneController.close();
  }
}
