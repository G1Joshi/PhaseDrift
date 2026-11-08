import 'package:flame/components.dart';

import '../../../core/domain/domain.dart';
import '../chamber_definition.dart';

ChamberDefinition buildChamber01() {
  return ChamberDefinition(
    chamberId: 1,
    name: 'Awakening',
    description: 'Ground movement and jump mechanics',
    parTimeMs: 15000,
    spawnPoint: Vector2(40.0, 270.0),
    portalPosition: Vector2(510.0, 288.0),
    width: 560.0,
    height: 320.0,
    universalBlocks: [
      // Floor
      UniversalBlockData(
        position: Vector2(0.0, 288.0),
        size: Vector2(560.0, 32.0),
      ),
      // Ceiling
      UniversalBlockData(
        position: Vector2(0.0, 0.0),
        size: Vector2(560.0, 16.0),
      ),
      // Boundary Walls
      UniversalBlockData(
        position: Vector2(0.0, 16.0),
        size: Vector2(16.0, 272.0),
      ),
      UniversalBlockData(
        position: Vector2(544.0, 16.0),
        size: Vector2(16.0, 272.0),
      ),
      // Stepped universal platforms
      UniversalBlockData(
        position: Vector2(100.0, 240.0),
        size: Vector2(64.0, 16.0),
      ),
      UniversalBlockData(
        position: Vector2(340.0, 160.0),
        size: Vector2(64.0, 16.0),
      ),
    ],
    phaseBlocks: [
      // Phase Alpha (Solar Amber) platform
      PhaseBlockData(
        position: Vector2(220.0, 200.0),
        size: Vector2(64.0, 16.0),
        phaseType: PhaseType.solar,
      ),
      // Phase Omega (Void Cyan) platform
      PhaseBlockData(
        position: Vector2(420.0, 120.0),
        size: Vector2(64.0, 16.0),
        phaseType: PhaseType.voidPhase,
      ),
    ],
    shards: [
      ChronoShardData(position: Vector2(132.0, 220.0), shardIndex: 0),
      ChronoShardData(position: Vector2(252.0, 180.0), shardIndex: 1),
      ChronoShardData(position: Vector2(372.0, 140.0), shardIndex: 2),
    ],
  );
}
