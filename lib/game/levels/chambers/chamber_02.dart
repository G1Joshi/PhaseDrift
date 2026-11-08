import 'package:flame/components.dart';

import '../../../core/domain/domain.dart';
import '../../components/environment/environment.dart';
import '../chamber_definition.dart';

ChamberDefinition buildChamber02() {
  return ChamberDefinition(
    chamberId: 2,
    name: 'Inversion',
    description: 'Polarity swap and ceiling traversal',
    parTimeMs: 22000,
    spawnPoint: Vector2(40.0, 270.0),
    portalPosition: Vector2(590.0, 288.0),
    width: 640.0,
    height: 320.0,
    universalBlocks: [
      // Left starting floor
      UniversalBlockData(
        position: Vector2(0.0, 288.0),
        size: Vector2(200.0, 32.0),
      ),
      // Right exit floor
      UniversalBlockData(
        position: Vector2(440.0, 288.0),
        size: Vector2(200.0, 32.0),
      ),
      // Full boundary walls
      UniversalBlockData(
        position: Vector2(0.0, 0.0),
        size: Vector2(16.0, 320.0),
      ),
      UniversalBlockData(
        position: Vector2(624.0, 0.0),
        size: Vector2(16.0, 320.0),
      ),
      // Inversion ceiling bridge over bottomless gap
      UniversalBlockData(
        position: Vector2(180.0, 0.0),
        size: Vector2(280.0, 16.0),
      ),
      // Left ceiling boundary
      UniversalBlockData(
        position: Vector2(0.0, 0.0),
        size: Vector2(180.0, 16.0),
      ),
      UniversalBlockData(
        position: Vector2(460.0, 0.0),
        size: Vector2(180.0, 16.0),
      ),
    ],
    phaseBlocks: [
      // Mid-chasm Solar safety step
      PhaseBlockData(
        position: Vector2(300.0, 200.0),
        size: Vector2(48.0, 16.0),
        phaseType: PhaseType.solar,
      ),
      // High Void guide rail
      PhaseBlockData(
        position: Vector2(260.0, 80.0),
        size: Vector2(120.0, 16.0),
        phaseType: PhaseType.voidPhase,
      ),
    ],
    spikes: [
      // Hazard pit lining the floor chasm
      HazardSpikeData(
        position: Vector2(200.0, 304.0),
        size: Vector2(240.0, 16.0),
        orientation: SpikeOrientation.up,
      ),
    ],
    shards: [
      ChronoShardData(position: Vector2(140.0, 270.0), shardIndex: 0),
      ChronoShardData(position: Vector2(320.0, 36.0), shardIndex: 1),
      ChronoShardData(position: Vector2(520.0, 270.0), shardIndex: 2),
    ],
  );
}
