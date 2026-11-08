import 'package:flame/components.dart';

import '../../../core/domain/domain.dart';
import '../../components/environment/environment.dart';
import '../chamber_definition.dart';

ChamberDefinition buildChamber08() {
  return ChamberDefinition(
    chamberId: 8,
    name: 'Singularity',
    description: 'Chrono Singularity core apex trial',
    parTimeMs: 55000,
    spawnPoint: Vector2(50.0, 480.0),
    portalPosition: Vector2(980.0, 260.0),
    width: 1040.0,
    height: 560.0,
    universalBlocks: [
      // Starting base platform
      UniversalBlockData(
        position: Vector2(0.0, 512.0),
        size: Vector2(120.0, 48.0),
      ),
      // Apex portal vault platform
      UniversalBlockData(
        position: Vector2(920.0, 288.0),
        size: Vector2(120.0, 32.0),
      ),
      // Outer boundaries
      UniversalBlockData(
        position: Vector2(0.0, 0.0),
        size: Vector2(1040.0, 16.0),
      ),
      UniversalBlockData(
        position: Vector2(0.0, 16.0),
        size: Vector2(16.0, 528.0),
      ),
      UniversalBlockData(
        position: Vector2(1024.0, 16.0),
        size: Vector2(16.0, 528.0),
      ),
      UniversalBlockData(
        position: Vector2(0.0, 544.0),
        size: Vector2(1040.0, 16.0),
      ),
      // Singularity core chamber structure
      UniversalBlockData(
        position: Vector2(460.0, 200.0),
        size: Vector2(120.0, 16.0),
      ),
      UniversalBlockData(
        position: Vector2(460.0, 340.0),
        size: Vector2(120.0, 16.0),
      ),
      UniversalBlockData(
        position: Vector2(240.0, 120.0),
        size: Vector2(32.0, 280.0),
      ),
      UniversalBlockData(
        position: Vector2(720.0, 160.0),
        size: Vector2(32.0, 280.0),
      ),
    ],
    phaseBlocks: [
      // Solar lower sling ramp
      PhaseBlockData(
        position: Vector2(160.0, 420.0),
        size: Vector2(64.0, 16.0),
        phaseType: PhaseType.solar,
      ),
      // Void upper slipstream
      PhaseBlockData(
        position: Vector2(340.0, 80.0),
        size: Vector2(80.0, 16.0),
        phaseType: PhaseType.voidPhase,
      ),
      // Core approach Solar step
      PhaseBlockData(
        position: Vector2(620.0, 380.0),
        size: Vector2(64.0, 16.0),
        phaseType: PhaseType.solar,
      ),
      // Final Void gateway
      PhaseBlockData(
        position: Vector2(820.0, 180.0),
        size: Vector2(80.0, 16.0),
        phaseType: PhaseType.voidPhase,
      ),
    ],
    spikes: [
      // Abyss floor spikes
      HazardSpikeData(
        position: Vector2(120.0, 528.0),
        size: Vector2(904.0, 16.0),
        orientation: SpikeOrientation.up,
      ),
      // Ceiling hazard barriers
      HazardSpikeData(
        position: Vector2(460.0, 216.0),
        size: Vector2(120.0, 16.0),
        orientation: SpikeOrientation.down,
      ),
    ],
    beacons: [
      ShiftBeaconData(position: Vector2(280.0, 240.0)),
      ShiftBeaconData(position: Vector2(760.0, 240.0)),
    ],
    shards: [
      ChronoShardData(position: Vector2(340.0, 440.0), shardIndex: 0),
      ChronoShardData(position: Vector2(520.0, 150.0), shardIndex: 1),
      ChronoShardData(position: Vector2(860.0, 230.0), shardIndex: 2),
    ],
  );
}
