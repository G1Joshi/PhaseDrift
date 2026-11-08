import 'package:flame/components.dart';

import '../../../core/domain/domain.dart';
import '../../components/environment/environment.dart';
import '../chamber_definition.dart';

ChamberDefinition buildChamber03() {
  return ChamberDefinition(
    chamberId: 3,
    name: 'Slingshot',
    description: 'Momentum slingshot and high chasm launch',
    parTimeMs: 25000,
    spawnPoint: Vector2(60.0, 70.0),
    portalPosition: Vector2(580.0, 80.0),
    width: 640.0,
    height: 560.0,
    universalBlocks: [
      // Outer boundaries
      UniversalBlockData(
        position: Vector2(0.0, 0.0),
        size: Vector2(640.0, 16.0),
      ),
      UniversalBlockData(
        position: Vector2(0.0, 544.0),
        size: Vector2(640.0, 16.0),
      ),
      UniversalBlockData(
        position: Vector2(0.0, 16.0),
        size: Vector2(16.0, 528.0),
      ),
      UniversalBlockData(
        position: Vector2(624.0, 16.0),
        size: Vector2(16.0, 528.0),
      ),
      // High spawn ledge (top left)
      UniversalBlockData(
        position: Vector2(16.0, 96.0),
        size: Vector2(140.0, 16.0),
      ),
      // Central dividing pillar creating the drop shaft
      UniversalBlockData(
        position: Vector2(260.0, 96.0),
        size: Vector2(32.0, 360.0),
      ),
      // High exit vault floor (top right)
      UniversalBlockData(
        position: Vector2(480.0, 96.0),
        size: Vector2(144.0, 16.0),
      ),
    ],
    phaseBlocks: [
      // Solar catch step in drop shaft
      PhaseBlockData(
        position: Vector2(100.0, 360.0),
        size: Vector2(64.0, 16.0),
        phaseType: PhaseType.solar,
      ),
      // Void landing platform at upper launch apex
      PhaseBlockData(
        position: Vector2(360.0, 140.0),
        size: Vector2(80.0, 16.0),
        phaseType: PhaseType.voidPhase,
      ),
    ],
    spikes: [
      // Floor spikes catching failed slingshots
      HazardSpikeData(
        position: Vector2(16.0, 528.0),
        size: Vector2(608.0, 16.0),
        orientation: SpikeOrientation.up,
      ),
    ],
    shards: [
      ChronoShardData(position: Vector2(180.0, 260.0), shardIndex: 0),
      ChronoShardData(position: Vector2(400.0, 100.0), shardIndex: 1),
      ChronoShardData(position: Vector2(530.0, 70.0), shardIndex: 2),
    ],
  );
}
