import 'package:flame/components.dart';

import '../../../core/domain/domain.dart';
import '../../components/environment/environment.dart';
import '../chamber_definition.dart';

ChamberDefinition buildChamber05() {
  return ChamberDefinition(
    chamberId: 5,
    name: 'Dual Orbit',
    description: 'Orbital momentum loops with automated shift beacons',
    parTimeMs: 32000,
    spawnPoint: Vector2(50.0, 420.0),
    portalPosition: Vector2(660.0, 432.0),
    width: 720.0,
    height: 480.0,
    universalBlocks: [
      // Left starting floor
      UniversalBlockData(
        position: Vector2(0.0, 448.0),
        size: Vector2(140.0, 32.0),
      ),
      // Right exit platform
      UniversalBlockData(
        position: Vector2(600.0, 448.0),
        size: Vector2(120.0, 32.0),
      ),
      // Outer boundaries
      UniversalBlockData(
        position: Vector2(0.0, 0.0),
        size: Vector2(720.0, 16.0),
      ),
      UniversalBlockData(
        position: Vector2(0.0, 16.0),
        size: Vector2(16.0, 448.0),
      ),
      UniversalBlockData(
        position: Vector2(704.0, 16.0),
        size: Vector2(16.0, 448.0),
      ),
      UniversalBlockData(
        position: Vector2(0.0, 464.0),
        size: Vector2(720.0, 16.0),
      ),
      // Central spike core island
      UniversalBlockData(
        position: Vector2(310.0, 200.0),
        size: Vector2(100.0, 80.0),
      ),
    ],
    phaseBlocks: [
      // Top solar guide ceiling
      PhaseBlockData(
        position: Vector2(260.0, 60.0),
        size: Vector2(200.0, 16.0),
        phaseType: PhaseType.solar,
      ),
      // Bottom void floor guide
      PhaseBlockData(
        position: Vector2(260.0, 400.0),
        size: Vector2(200.0, 16.0),
        phaseType: PhaseType.voidPhase,
      ),
    ],
    spikes: [
      // Core hazard spikes surrounding central island
      HazardSpikeData(
        position: Vector2(310.0, 184.0),
        size: Vector2(100.0, 16.0),
        orientation: SpikeOrientation.up,
      ),
      HazardSpikeData(
        position: Vector2(310.0, 280.0),
        size: Vector2(100.0, 16.0),
        orientation: SpikeOrientation.down,
      ),
    ],
    beacons: [
      // Shift Beacon 1: entry orbit flip
      ShiftBeaconData(position: Vector2(220.0, 240.0)),
      // Shift Beacon 2: exit orbit flip
      ShiftBeaconData(position: Vector2(500.0, 240.0)),
    ],
    shards: [
      ChronoShardData(position: Vector2(220.0, 130.0), shardIndex: 0),
      ChronoShardData(position: Vector2(360.0, 130.0), shardIndex: 1),
      ChronoShardData(position: Vector2(500.0, 350.0), shardIndex: 2),
    ],
  );
}
