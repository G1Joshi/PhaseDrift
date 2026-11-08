import 'package:flame/components.dart';

import '../../../core/domain/domain.dart';
import '../../components/environment/environment.dart';
import '../chamber_definition.dart';

ChamberDefinition buildChamber06() {
  return ChamberDefinition(
    chamberId: 6,
    name: 'Precision Ceiling',
    description: 'Low-clearance ceiling passages and micro-hop control',
    parTimeMs: 35000,
    spawnPoint: Vector2(40.0, 340.0),
    portalPosition: Vector2(740.0, 348.0),
    width: 800.0,
    height: 400.0,
    universalBlocks: [
      // Spawn floor
      UniversalBlockData(
        position: Vector2(0.0, 368.0),
        size: Vector2(120.0, 32.0),
      ),
      // Exit floor
      UniversalBlockData(
        position: Vector2(680.0, 368.0),
        size: Vector2(120.0, 32.0),
      ),
      // Outer boundaries
      UniversalBlockData(
        position: Vector2(0.0, 0.0),
        size: Vector2(800.0, 16.0),
      ),
      UniversalBlockData(
        position: Vector2(0.0, 16.0),
        size: Vector2(16.0, 368.0),
      ),
      UniversalBlockData(
        position: Vector2(784.0, 16.0),
        size: Vector2(16.0, 368.0),
      ),
      UniversalBlockData(
        position: Vector2(0.0, 384.0),
        size: Vector2(800.0, 16.0),
      ),
      // Inverted ceiling runway
      UniversalBlockData(
        position: Vector2(140.0, 16.0),
        size: Vector2(520.0, 16.0),
      ),
      // Low tunnel ceiling divider
      UniversalBlockData(
        position: Vector2(260.0, 96.0),
        size: Vector2(300.0, 16.0),
      ),
    ],
    phaseBlocks: [
      // Solar launch pad
      PhaseBlockData(
        position: Vector2(100.0, 240.0),
        size: Vector2(64.0, 16.0),
        phaseType: PhaseType.solar,
      ),
      // Void micro-hop platforms in lower tunnel
      PhaseBlockData(
        position: Vector2(320.0, 180.0),
        size: Vector2(64.0, 16.0),
        phaseType: PhaseType.voidPhase,
      ),
      PhaseBlockData(
        position: Vector2(460.0, 180.0),
        size: Vector2(64.0, 16.0),
        phaseType: PhaseType.voidPhase,
      ),
    ],
    spikes: [
      // Downward inverted spikes on tunnel ceiling
      HazardSpikeData(
        position: Vector2(260.0, 112.0),
        size: Vector2(300.0, 16.0),
        orientation: SpikeOrientation.down,
      ),
      // Upward spikes on bottom pit
      HazardSpikeData(
        position: Vector2(120.0, 368.0),
        size: Vector2(560.0, 16.0),
        orientation: SpikeOrientation.up,
      ),
    ],
    shards: [
      ChronoShardData(position: Vector2(200.0, 50.0), shardIndex: 0),
      ChronoShardData(position: Vector2(410.0, 150.0), shardIndex: 1),
      ChronoShardData(position: Vector2(620.0, 50.0), shardIndex: 2),
    ],
  );
}
