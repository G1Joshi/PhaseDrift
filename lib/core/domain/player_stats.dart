class PlayerStats {
  const PlayerStats({
    this.totalShifts = 0,
    this.totalDeaths = 0,
    this.totalTimePlayedMs = 0,
    this.totalShardsCollected = 0,
    this.totalJumps = 0,
  });

  const PlayerStats.initial()
    : totalShifts = 0,
      totalDeaths = 0,
      totalTimePlayedMs = 0,
      totalShardsCollected = 0,
      totalJumps = 0;

  factory PlayerStats.fromJson(Map<String, dynamic> json) {
    return PlayerStats(
      totalShifts: (json['totalShifts'] as int?) ?? 0,
      totalDeaths: (json['totalDeaths'] as int?) ?? 0,
      totalTimePlayedMs: (json['totalTimePlayedMs'] as int?) ?? 0,
      totalShardsCollected: (json['totalShardsCollected'] as int?) ?? 0,
      totalJumps: (json['totalJumps'] as int?) ?? 0,
    );
  }

  final int totalShifts;
  final int totalDeaths;
  final int totalTimePlayedMs;
  final int totalShardsCollected;
  final int totalJumps;

  PlayerStats registerShift() => copyWith(totalShifts: totalShifts + 1);

  PlayerStats registerDeath() => copyWith(totalDeaths: totalDeaths + 1);

  PlayerStats registerJump() => copyWith(totalJumps: totalJumps + 1);

  PlayerStats addPlayTime(int ms) =>
      copyWith(totalTimePlayedMs: totalTimePlayedMs + ms);

  PlayerStats addShards(int count) =>
      copyWith(totalShardsCollected: totalShardsCollected + count);

  PlayerStats copyWith({
    int? totalShifts,
    int? totalDeaths,
    int? totalTimePlayedMs,
    int? totalShardsCollected,
    int? totalJumps,
  }) {
    return PlayerStats(
      totalShifts: totalShifts ?? this.totalShifts,
      totalDeaths: totalDeaths ?? this.totalDeaths,
      totalTimePlayedMs: totalTimePlayedMs ?? this.totalTimePlayedMs,
      totalShardsCollected: totalShardsCollected ?? this.totalShardsCollected,
      totalJumps: totalJumps ?? this.totalJumps,
    );
  }

  Map<String, dynamic> toJson() => {
    'totalShifts': totalShifts,
    'totalDeaths': totalDeaths,
    'totalTimePlayedMs': totalTimePlayedMs,
    'totalShardsCollected': totalShardsCollected,
    'totalJumps': totalJumps,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerStats &&
          runtimeType == other.runtimeType &&
          totalShifts == other.totalShifts &&
          totalDeaths == other.totalDeaths &&
          totalTimePlayedMs == other.totalTimePlayedMs &&
          totalShardsCollected == other.totalShardsCollected &&
          totalJumps == other.totalJumps;

  @override
  int get hashCode => Object.hash(
    totalShifts,
    totalDeaths,
    totalTimePlayedMs,
    totalShardsCollected,
    totalJumps,
  );
}
