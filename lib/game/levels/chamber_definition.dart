import 'package:flame/components.dart';

import '../../core/domain/domain.dart';
import '../components/environment/hazard_spike.dart';

class PhaseBlockData {
  const PhaseBlockData({
    required this.position,
    required this.size,
    required this.phaseType,
  });

  final Vector2 position;
  final Vector2 size;
  final PhaseType phaseType;
}

class UniversalBlockData {
  const UniversalBlockData({required this.position, required this.size});

  final Vector2 position;
  final Vector2 size;
}

class HazardSpikeData {
  const HazardSpikeData({
    required this.position,
    required this.size,
    this.orientation = SpikeOrientation.up,
  });

  final Vector2 position;
  final Vector2 size;
  final SpikeOrientation orientation;
}

class ChronoShardData {
  const ChronoShardData({required this.position, required this.shardIndex});

  final Vector2 position;
  final int shardIndex;
}

class ShiftBeaconData {
  const ShiftBeaconData({required this.position, this.size});

  final Vector2 position;
  final Vector2? size;
}

class ChamberDefinition {
  const ChamberDefinition({
    required this.chamberId,
    required this.name,
    required this.spawnPoint,
    required this.portalPosition,
    this.description = '',
    this.parTimeMs = 15000,
    this.width = 560.0,
    this.height = 320.0,
    this.universalBlocks = const [],
    this.phaseBlocks = const [],
    this.spikes = const [],
    this.shards = const [],
    this.beacons = const [],
  });

  final int chamberId;
  final String name;
  final String description;
  final int parTimeMs;
  final Vector2 spawnPoint;
  final Vector2 portalPosition;
  final double width;
  final double height;
  final List<UniversalBlockData> universalBlocks;
  final List<PhaseBlockData> phaseBlocks;
  final List<HazardSpikeData> spikes;
  final List<ChronoShardData> shards;
  final List<ShiftBeaconData> beacons;

  bool get isValid {
    if (name.isEmpty) return false;
    if (chamberId <= 0) return false;
    if (parTimeMs <= 0) return false;
    if (spawnPoint.x < 0 || spawnPoint.x > width) return false;
    if (spawnPoint.y < 0 || spawnPoint.y > height) return false;
    if (portalPosition.x < 0 || portalPosition.x > width) return false;
    if (portalPosition.y < 0 || portalPosition.y > height) return false;
    if (shards.length != 3) return false;

    final indices = shards.map((s) => s.shardIndex).toSet();
    return indices.contains(0) && indices.contains(1) && indices.contains(2);
  }
}
