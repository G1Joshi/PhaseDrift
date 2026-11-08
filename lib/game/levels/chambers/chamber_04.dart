import 'package:flame/components.dart';

import '../../../core/domain/domain.dart';
import '../../components/environment/environment.dart';
import '../chamber_definition.dart';

ChamberDefinition buildChamber04() {
  return ChamberDefinition(
    chamberId: 4,
    name: 'The Abyss',
    description: 'Alternating phase gauntlet over bottomless void',
    parTimeMs: 30000,
    spawnPoint: Vector2(50.0, 260.0),
    portalPosition: Vector2(740.0, 272.0),
    width: 800.0,
    height: 320.0,
    universalBlocks: [
      // Left spawn platform
      UniversalBlockData(
        position: Vector2(0.0, 288.0),
        size: Vector2(120.0, 32.0),
      ),
      // Right exit portal platform
      UniversalBlockData(
        position: Vector2(680.0, 288.0),
        size: Vector2(120.0, 32.0),
      ),
      // Boundaries
      UniversalBlockData(
        position: Vector2(0.0, 0.0),
        size: Vector2(800.0, 16.0),
      ),
      UniversalBlockData(
        position: Vector2(0.0, 16.0),
        size: Vector2(16.0, 272.0),
      ),
      UniversalBlockData(
        position: Vector2(784.0, 16.0),
        size: Vector2(16.0, 272.0),
      ),
    ],
    phaseBlocks: [
      // Step 1: Solar
      PhaseBlockData(
        position: Vector2(180.0, 230.0),
        size: Vector2(64.0, 16.0),
        phaseType: PhaseType.solar,
      ),
      // Step 2: Void
      PhaseBlockData(
        position: Vector2(290.0, 180.0),
        size: Vector2(64.0, 16.0),
        phaseType: PhaseType.voidPhase,
      ),
      // Step 3: Solar
      PhaseBlockData(
        position: Vector2(400.0, 220.0),
        size: Vector2(64.0, 16.0),
        phaseType: PhaseType.solar,
      ),
      // Step 4: Void
      PhaseBlockData(
        position: Vector2(510.0, 170.0),
        size: Vector2(64.0, 16.0),
        phaseType: PhaseType.voidPhase,
      ),
      // Step 5: Solar
      PhaseBlockData(
        position: Vector2(610.0, 230.0),
        size: Vector2(64.0, 16.0),
        phaseType: PhaseType.solar,
      ),
    ],
    spikes: [
      // Spikes across the bottom abyss
      HazardSpikeData(
        position: Vector2(120.0, 304.0),
        size: Vector2(560.0, 16.0),
        orientation: SpikeOrientation.up,
      ),
    ],
    shards: [
      ChronoShardData(position: Vector2(212.0, 190.0), shardIndex: 0),
      ChronoShardData(position: Vector2(432.0, 170.0), shardIndex: 1),
      ChronoShardData(position: Vector2(642.0, 190.0), shardIndex: 2),
    ],
  );
}
