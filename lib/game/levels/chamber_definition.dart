import 'dart:ui';

import 'package:flame/components.dart';

import '../../core/domain/domain.dart';
import '../components/environment/hazard_spike.dart';

export '../components/environment/hazard_spike.dart' show SpikeOrientation;

enum ChamberTier {
  veryEasy('VERY EASY', Color(0xFF00E676), 'SECTOR 1 // SOLAR DAWN'),
  easy('EASY', Color(0xFF00F5FF), 'SECTOR 2 // VOID CHASM'),
  medium('MEDIUM', Color(0xFFFF9E00), 'SECTOR 3 // TACHYON SURGE'),
  hard('HARD', Color(0xFFE040FB), 'SECTOR 4 // PULSAR RIFT'),
  veryHard('VERY HARD', Color(0xFFFF1744), 'SECTOR 5 // GRAND SINGULARITY'),
  endless('QUANTUM', Color(0xFFD500F9), 'ANOMALY // QUANTUM DRIFT');

  const ChamberTier(this.label, this.color, this.sectorName);
  final String label;
  final Color color;
  final String sectorName;
}

class ChamberDirectiveData {
  const ChamberDirectiveData({
    required this.position,
    required this.title,
    this.subtitle = '',
  });

  final Vector2 position;
  final String title;
  final String subtitle;
}

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

class PhaseGateData {
  const PhaseGateData({
    required this.position,
    required this.size,
    required this.phase,
  });

  final Vector2 position;
  final Vector2 size;
  final GamePhase phase;
}

class TachyonPadData {
  const TachyonPadData({
    required this.position,
    required this.size,
    this.boostVelocity,
  });

  final Vector2 position;
  final Vector2 size;
  final Vector2? boostVelocity;
}

class MovingPlatformData {
  const MovingPlatformData({
    required this.startPosition,
    required this.endPosition,
    required this.size,
    this.speed = 60.0,
    this.phaseType,
  });

  final Vector2 startPosition;
  final Vector2 endPosition;
  final Vector2 size;
  final double speed;
  final PhaseType? phaseType;
}

class PhaseLadderData {
  const PhaseLadderData({
    required this.position,
    required this.size,
    this.phaseType,
  });

  final Vector2 position;
  final Vector2 size;
  final PhaseType? phaseType;
}

class ChamberDefinition {
  const ChamberDefinition({
    required this.chamberId,
    required this.name,
    required this.spawnPoint,
    required this.portalPosition,
    this.topologyName = 'KINETIC SPRINT',
    this.description = '',
    this.parTimeMs = 15000,
    this.tier = ChamberTier.medium,
    this.width = 560.0,
    this.height = 320.0,
    this.universalBlocks = const [],
    this.phaseBlocks = const [],
    this.spikes = const [],
    this.shards = const [],
    this.beacons = const [],
    this.phaseGates = const [],
    this.tachyonPads = const [],
    this.directives = const [],
    this.movingPlatforms = const [],
    this.ladders = const [],
  });

  final int chamberId;
  final String name;
  final String topologyName;
  final String description;
  final int parTimeMs;
  final ChamberTier tier;
  final Vector2 spawnPoint;
  final Vector2 portalPosition;
  final double width;
  final double height;
  final List<UniversalBlockData> universalBlocks;
  final List<PhaseBlockData> phaseBlocks;
  final List<HazardSpikeData> spikes;
  final List<ChronoShardData> shards;
  final List<ShiftBeaconData> beacons;
  final List<PhaseGateData> phaseGates;
  final List<TachyonPadData> tachyonPads;
  final List<ChamberDirectiveData> directives;
  final List<MovingPlatformData> movingPlatforms;
  final List<PhaseLadderData> ladders;

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
