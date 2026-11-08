import 'package:flame/components.dart';

import '../../../core/domain/domain.dart';
import '../../components/environment/environment.dart';
import '../chamber_definition.dart';

ChamberDefinition buildChamber07() {
  return ChamberDefinition(
    chamberId: 7,
    name: 'Velocity Gauntlet',
    description: 'Chained multi-stage momentum slingshots',
    parTimeMs: 40000,
    spawnPoint: Vector2(40.0, 80.0),
    portalPosition: Vector2(900.0, 420.0),
    width: 960.0,
    height: 480.0,
    universalBlocks: [
      // High spawn ledge
      UniversalBlockData(
        position: Vector2(0.0, 112.0),
        size: Vector2(100.0, 16.0),
      ),
      // Exit landing platform
      UniversalBlockData(
        position: Vector2(840.0, 448.0),
        size: Vector2(120.0, 32.0),
      ),
      // Outer boundaries
      UniversalBlockData(
        position: Vector2(0.0, 0.0),
        size: Vector2(960.0, 16.0),
      ),
      UniversalBlockData(
        position: Vector2(0.0, 16.0),
        size: Vector2(16.0, 448.0),
      ),
      UniversalBlockData(
        position: Vector2(944.0, 16.0),
        size: Vector2(16.0, 448.0),
      ),
      UniversalBlockData(
        position: Vector2(0.0, 464.0),
        size: Vector2(960.0, 16.0),
      ),
      // Dividing vertical baffle columns forcing vertical slingshots
      UniversalBlockData(
        position: Vector2(220.0, 0.0),
        size: Vector2(24.0, 240.0),
      ),
      UniversalBlockData(
        position: Vector2(440.0, 240.0),
        size: Vector2(24.0, 224.0),
      ),
      UniversalBlockData(
        position: Vector2(660.0, 0.0),
        size: Vector2(24.0, 240.0),
      ),
    ],
    phaseBlocks: [
      // Solar rebound step 1
      PhaseBlockData(
        position: Vector2(140.0, 360.0),
        size: Vector2(48.0, 16.0),
        phaseType: PhaseType.solar,
      ),
      // Void ceiling step 2
      PhaseBlockData(
        position: Vector2(340.0, 60.0),
        size: Vector2(48.0, 16.0),
        phaseType: PhaseType.voidPhase,
      ),
      // Solar rebound step 3
      PhaseBlockData(
        position: Vector2(560.0, 360.0),
        size: Vector2(48.0, 16.0),
        phaseType: PhaseType.solar,
      ),
      // Void ceiling step 4
      PhaseBlockData(
        position: Vector2(760.0, 60.0),
        size: Vector2(48.0, 16.0),
        phaseType: PhaseType.voidPhase,
      ),
    ],
    spikes: [
      // Floor spike chasm
      HazardSpikeData(
        position: Vector2(100.0, 448.0),
        size: Vector2(740.0, 16.0),
        orientation: SpikeOrientation.up,
      ),
    ],
    shards: [
      ChronoShardData(position: Vector2(300.0, 120.0), shardIndex: 0),
      ChronoShardData(position: Vector2(520.0, 320.0), shardIndex: 1),
      ChronoShardData(position: Vector2(740.0, 120.0), shardIndex: 2),
    ],
  );
}
