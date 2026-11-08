import 'package:material_ui/material_ui.dart';

import '../theme/theme.dart';

enum ChamberRank {
  s('S', 'APEX DRIFTER', AppColors.solarGold),
  a('A', 'SUPERCONDUCTOR', AppColors.voidCyan),
  b('B', 'PHASE SURGEON', AppColors.solarAmber),
  c('C', 'OPERATIVE', AppColors.onSurfaceVariant);

  const ChamberRank(this.label, this.title, this.color);

  final String label;
  final String title;
  final Color color;

  static ChamberRank calculate({
    required int completionTimeMs,
    required int parTimeMs,
    required int shardCount,
  }) {
    final isUnderPar = completionTimeMs <= parTimeMs;
    final allShards = shardCount >= 3;

    // S Rank: Under Par Time AND all 3 Chrono-Shards collected
    if (isUnderPar && allShards) {
      return ChamberRank.s;
    }

    // A Rank: Within 25% of par, or all shards within 40% of par
    if (completionTimeMs <= (parTimeMs * 1.25) ||
        (allShards && completionTimeMs <= (parTimeMs * 1.4))) {
      return ChamberRank.a;
    }

    // B Rank: Within 60% of par or at least 2 shards collected
    if (completionTimeMs <= (parTimeMs * 1.6) || shardCount >= 2) {
      return ChamberRank.b;
    }

    // C Rank: Base completion
    return ChamberRank.c;
  }
}
