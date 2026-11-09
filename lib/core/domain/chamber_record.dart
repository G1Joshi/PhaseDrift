class ChamberRecord {
  const ChamberRecord({
    required this.chamberId,
    this.bestTimeMs,
    this.collectedShardsMask = 0,
    this.isUnlocked = false,
    this.clearedAtEpochMs,
  });

  factory ChamberRecord.initial(int chamberId, {bool isUnlocked = false}) {
    return ChamberRecord(chamberId: chamberId, isUnlocked: isUnlocked);
  }

  factory ChamberRecord.fromJson(Map<String, dynamic> json) {
    return ChamberRecord(
      chamberId: json['chamberId'] as int,
      bestTimeMs: json['bestTimeMs'] as int?,
      collectedShardsMask: (json['collectedShardsMask'] as int?) ?? 0,
      isUnlocked: (json['isUnlocked'] as bool?) ?? false,
      clearedAtEpochMs: json['clearedAtEpochMs'] as int?,
    );
  }

  final int chamberId;
  final int? bestTimeMs;
  final int collectedShardsMask;
  final bool isUnlocked;
  final int? clearedAtEpochMs;

  bool get isCleared => bestTimeMs != null;

  static int countShards(int mask) {
    var count = 0;
    var m = mask;
    while (m > 0) {
      count += m & 1;
      m >>= 1;
    }
    return count;
  }

  int get shardCount => countShards(collectedShardsMask);

  bool hasShard(int index) {
    if (index < 0 || index >= 3) return false;
    return (collectedShardsMask & (1 << index)) != 0;
  }

  ChamberRecord recordRun({
    required int completionTimeMs,
    int newShardsMask = 0,
  }) {
    final updatedBest = bestTimeMs == null
        ? completionTimeMs
        : (completionTimeMs < bestTimeMs! ? completionTimeMs : bestTimeMs);

    return ChamberRecord(
      chamberId: chamberId,
      bestTimeMs: updatedBest,
      collectedShardsMask: collectedShardsMask | newShardsMask,
      isUnlocked: true,
      clearedAtEpochMs: DateTime.now().millisecondsSinceEpoch,
    );
  }

  ChamberRecord copyWith({
    int? chamberId,
    int? bestTimeMs,
    int? collectedShardsMask,
    bool? isUnlocked,
    int? clearedAtEpochMs,
  }) {
    return ChamberRecord(
      chamberId: chamberId ?? this.chamberId,
      bestTimeMs: bestTimeMs ?? this.bestTimeMs,
      collectedShardsMask: collectedShardsMask ?? this.collectedShardsMask,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      clearedAtEpochMs: clearedAtEpochMs ?? this.clearedAtEpochMs,
    );
  }

  Map<String, dynamic> toJson() => {
    'chamberId': chamberId,
    'bestTimeMs': bestTimeMs,
    'collectedShardsMask': collectedShardsMask,
    'isUnlocked': isUnlocked,
    'clearedAtEpochMs': clearedAtEpochMs,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChamberRecord &&
          runtimeType == other.runtimeType &&
          chamberId == other.chamberId &&
          bestTimeMs == other.bestTimeMs &&
          collectedShardsMask == other.collectedShardsMask &&
          isUnlocked == other.isUnlocked &&
          clearedAtEpochMs == other.clearedAtEpochMs;

  @override
  int get hashCode => Object.hash(
    chamberId,
    bestTimeMs,
    collectedShardsMask,
    isUnlocked,
    clearedAtEpochMs,
  );
}
