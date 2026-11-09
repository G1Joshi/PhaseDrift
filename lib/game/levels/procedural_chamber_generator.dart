import 'dart:math' as math;

import 'package:flame/components.dart';

import '../../core/domain/domain.dart';
import 'chamber_definition.dart';

abstract final class ProceduralChamberGenerator {
  static const List<String> _sector1Names = [
    'Awakening',
    'Threshold',
    'Low Stride',
    'Kinetic Arc',
    'Twin Paths',
    'Amber Horizon',
    'Solar Spire',
    'Gravity Drop',
    'Return Loop',
    'Solar Apex',
  ];

  static const List<String> _sector2Names = [
    'Inversion',
    'Cyan Drift',
    'Sub-Zero Tunnel',
    'Ceiling Vault',
    'Polarity Divide',
    'Azure Conduit',
    'Void Spire',
    'Abyss Plunge',
    'Inverted Horseshoe',
    'Void Monolith',
  ];

  static const List<String> _sector3Names = [
    'Velocity Gate',
    'Emerald Islets',
    'The Squeeze',
    'Tachyon Pendulum',
    'Forked Vector',
    'Resonance Stride',
    'Kinetic Tower',
    'Graviton Chasm',
    'Momentum Switchback',
    'Tachyon Accelerator',
  ];

  static const List<String> _sector4Names = [
    'Phase Labyrinth',
    'Polar Archipelago',
    'Razor Corridor',
    'Singularity Slingshot',
    'Bifurcated Rift',
    'Quantum Cadence',
    'Pulsar Spire',
    'Eventide Descent',
    'Tachyon Loop',
    'Pulsar Singularity',
  ];

  static const List<String> _sector5Names = [
    'Event Horizon',
    'Void Steppes',
    'Singularity Wall',
    'Cosmic Catapult',
    'The Grand Bifurcation',
    'Dirac Sequence',
    'Apex Spire',
    'Planckean Plunge',
    'Singularity Switchback',
    'Grand Singularity',
  ];

  static const _endlessPrefixes = [
    'QUANTUM',
    'POLARITY',
    'SINGULARITY',
    'CHRONO',
    'NEBULA',
    'VORTEX',
    'SYNAPSE',
    'HORIZON',
    'ECLIPSE',
    'HYPERION',
  ];

  static const _endlessSuffixes = [
    'MATRIX',
    'CORRIDOR',
    'GAUNTLET',
    'NEXUS',
    'VAULT',
    'SECTOR',
    'RUN',
    'ARRAY',
    'DRIFT',
    'CHASM',
  ];

  static ChamberTier tierForChamber(int chamberId) {
    if (chamberId <= 10) return ChamberTier.veryEasy;
    if (chamberId <= 20) return ChamberTier.easy;
    if (chamberId <= 30) return ChamberTier.medium;
    if (chamberId <= 40) return ChamberTier.hard;
    if (chamberId <= 50) return ChamberTier.veryHard;
    return ChamberTier.endless;
  }

  static String getChamberName(int chamberId, math.Random rng) {
    if (chamberId >= 1 && chamberId <= 10) {
      return _sector1Names[chamberId - 1];
    } else if (chamberId >= 11 && chamberId <= 20) {
      return _sector2Names[chamberId - 11];
    } else if (chamberId >= 21 && chamberId <= 30) {
      return _sector3Names[chamberId - 21];
    } else if (chamberId >= 31 && chamberId <= 40) {
      return _sector4Names[chamberId - 31];
    } else if (chamberId >= 41 && chamberId <= 50) {
      return _sector5Names[chamberId - 41];
    }
    final prefix = _endlessPrefixes[rng.nextInt(_endlessPrefixes.length)];
    final suffix = _endlessSuffixes[rng.nextInt(_endlessSuffixes.length)];
    return '$prefix $suffix';
  }

  static ChamberDefinition generateChamber({
    required int chamberId,
    int? seed,
    int? difficulty,
  }) {
    final effectiveSeed = seed ?? (chamberId * 2654435761 ^ 0x9E3779B9);
    final rng = math.Random(effectiveSeed);

    final tier = tierForChamber(chamberId);
    final name = getChamberName(chamberId, rng);

    final tierIdx = switch (tier) {
      ChamberTier.veryEasy => 0,
      ChamberTier.easy => 1,
      ChamberTier.medium => 2,
      ChamberTier.hard => 3,
      ChamberTier.veryHard => 4,
      ChamberTier.endless => ((difficulty ?? 3).clamp(1, 10) ~/ 2).clamp(0, 4),
    };

    final topologyType = (chamberId <= 50)
        ? (chamberId - 1) % 10
        : rng.nextInt(9);

    switch (topologyType) {
      case 0:
        return _buildKineticSprint(
          chamberId: chamberId,
          name: name,
          tier: tier,
          tierIdx: tierIdx,
          rng: rng,
          isIntroductory: true,
        );
      case 1:
        return _buildPhaseArchipelago(
          chamberId: chamberId,
          name: name,
          tier: tier,
          tierIdx: tierIdx,
          rng: rng,
        );
      case 2:
        return _buildClaustrophobicSqueeze(
          chamberId: chamberId,
          name: name,
          tier: tier,
          tierIdx: tierIdx,
          rng: rng,
        );
      case 3:
        return _buildSlingshotPendulum(
          chamberId: chamberId,
          name: name,
          tier: tier,
          tierIdx: tierIdx,
          rng: rng,
        );
      case 4:
        return _buildBifurcatedArena(
          chamberId: chamberId,
          name: name,
          tier: tier,
          tierIdx: tierIdx,
          rng: rng,
        );
      case 5:
        return _buildKineticSprint(
          chamberId: chamberId,
          name: name,
          tier: tier,
          tierIdx: tierIdx,
          rng: rng,
          isIntroductory: false,
        );
      case 6:
        return _buildAscentTower(
          chamberId: chamberId,
          name: name,
          tier: tier,
          tierIdx: tierIdx,
          rng: rng,
        );
      case 7:
        return _buildDescentChasm(
          chamberId: chamberId,
          name: name,
          tier: tier,
          tierIdx: tierIdx,
          rng: rng,
        );
      case 8:
        return _buildSwitchback(
          chamberId: chamberId,
          name: name,
          tier: tier,
          tierIdx: tierIdx,
          rng: rng,
        );
      case 9:
      default:
        return _buildSectorClimax(
          chamberId: chamberId,
          name: name,
          tier: tier,
          tierIdx: tierIdx,
          rng: rng,
        );
    }
  }

  static ChamberDefinition _buildKineticSprint({
    required int chamberId,
    required String name,
    required ChamberTier tier,
    required int tierIdx,
    required math.Random rng,
    required bool isIntroductory,
  }) {
    final width = 680.0 + (tierIdx * 24.0);
    const height = 320.0;
    const floorY = 288.0;
    final padWidth = (tier == ChamberTier.veryEasy) ? 120.0 : 100.0;

    final universal = <UniversalBlockData>[
      UniversalBlockData(position: Vector2(0, 0), size: Vector2(width, 16)),
      UniversalBlockData(position: Vector2(0, 0), size: Vector2(16, height)),
      UniversalBlockData(
        position: Vector2(width - 16, 0),
        size: Vector2(16, height),
      ),
      UniversalBlockData(
        position: Vector2(0, floorY),
        size: Vector2(padWidth, 32),
      ),
      UniversalBlockData(
        position: Vector2(width - padWidth, floorY),
        size: Vector2(padWidth, 32),
      ),
    ];

    final phaseBlocks = <PhaseBlockData>[];
    final spikes = <HazardSpikeData>[];
    final shards = <ChronoShardData>[];

    final chasmW = width - (2 * padWidth);
    if (tier == ChamberTier.veryEasy && chamberId <= 2) {
      universal.add(
        UniversalBlockData(
          position: Vector2(padWidth, floorY),
          size: Vector2(chasmW, 32),
        ),
      );
    } else {
      spikes.add(
        HazardSpikeData(
          position: Vector2(padWidth, height - 16),
          size: Vector2(chasmW, 16),
        ),
      );
    }

    final platW = (tier == ChamberTier.veryEasy) ? 80.0 : 64.0 - (tierIdx * 4);
    final step1X = padWidth + 40.0;
    final step2X = step1X + platW + 40.0;
    final step3X = step2X + platW + 40.0;

    phaseBlocks.addAll([
      PhaseBlockData(
        position: Vector2(step1X, floorY - 36.0),
        size: Vector2(platW, 16),
        phaseType: PhaseType.solar,
      ),
      PhaseBlockData(
        position: Vector2(step2X, floorY - 56.0),
        size: Vector2(platW, 16),
        phaseType: PhaseType.voidPhase,
      ),
      PhaseBlockData(
        position: Vector2(step3X, floorY - 36.0),
        size: Vector2(platW, 16),
        phaseType: PhaseType.solar,
      ),
    ]);

    shards.addAll([
      ChronoShardData(
        position: Vector2(step1X + platW / 2, floorY - 60.0),
        shardIndex: 0,
      ),
      ChronoShardData(
        position: Vector2(step2X + platW / 2, floorY - 80.0),
        shardIndex: 1,
      ),
      ChronoShardData(
        position: Vector2(step3X + platW / 2, floorY - 60.0),
        shardIndex: 2,
      ),
    ]);

    final phaseGates = <PhaseGateData>[];
    final tachyonPads = <TachyonPadData>[];
    final directives = <ChamberDirectiveData>[];

    if (chamberId == 1) {
      directives.addAll([
        ChamberDirectiveData(
          position: Vector2(60, 220),
          title: 'KINETIC RUN',
          subtitle: 'ACCELERATE HORIZONTALLY',
        ),
        ChamberDirectiveData(
          position: Vector2(170, 190),
          title: 'JUMP IMPULSE',
          subtitle: 'HOLD FOR HEIGHT',
        ),
        ChamberDirectiveData(
          position: Vector2(290, 160),
          title: 'PHASE SHIFT',
          subtitle: 'INVERT REALITY',
        ),
        ChamberDirectiveData(
          position: Vector2(width - 60, 220),
          title: 'WARP PORTAL',
          subtitle: 'ENTER TO ADVANCE',
        ),
      ]);
    }

    if (tierIdx >= 2) {
      tachyonPads.add(
        TachyonPadData(
          position: Vector2(step1X + 10.0, floorY - 26.0),
          size: Vector2(32.0, 6.0),
          boostVelocity: Vector2(320.0, 0.0),
        ),
      );
      phaseGates.add(
        PhaseGateData(
          position: Vector2(step2X + (platW / 2) - 8.0, floorY - 110.0),
          size: Vector2(16.0, 48.0),
          phase: const VoidPhase(),
        ),
      );
    }

    return ChamberDefinition(
      chamberId: chamberId,
      name: name,
      topologyName: isIntroductory ? 'KINETIC SPRINT' : 'RHYTHM SPRINT',
      description:
          'Sector ${chamberId.toString().padLeft(3, '0')} // ${tier.sectorName}',
      parTimeMs: 14000 + (tierIdx * 3000),
      tier: tier,
      spawnPoint: Vector2(40.0, floorY - 18.0),
      portalPosition: Vector2(width - 50.0, floorY),
      width: width,
      height: height,
      universalBlocks: universal,
      phaseBlocks: phaseBlocks,
      spikes: spikes,
      shards: shards,
      phaseGates: phaseGates,
      tachyonPads: tachyonPads,
      directives: directives,
    );
  }

  static ChamberDefinition _buildPhaseArchipelago({
    required int chamberId,
    required String name,
    required ChamberTier tier,
    required int tierIdx,
    required math.Random rng,
  }) {
    final width = 740.0 + (tierIdx * 20.0);
    const height = 340.0;
    const floorY = 260.0;

    final universal = <UniversalBlockData>[
      UniversalBlockData(position: Vector2(0, 0), size: Vector2(width, 16)),
      UniversalBlockData(position: Vector2(0, 0), size: Vector2(16, height)),
      UniversalBlockData(
        position: Vector2(width - 16, 0),
        size: Vector2(16, height),
      ),
      UniversalBlockData(position: Vector2(0, floorY), size: Vector2(80, 24)),
      UniversalBlockData(
        position: Vector2(width - 80, floorY),
        size: Vector2(80, 24),
      ),
    ];

    final spikes = <HazardSpikeData>[
      HazardSpikeData(
        position: Vector2(16, height - 16),
        size: Vector2(width - 32, 16),
      ),
    ];

    final platW = 60.0 - (tierIdx * 3);
    final phaseBlocks = <PhaseBlockData>[
      PhaseBlockData(
        position: Vector2(130, 250),
        size: Vector2(platW, 16),
        phaseType: PhaseType.solar,
      ),
      PhaseBlockData(
        position: Vector2(250, 230),
        size: Vector2(platW, 16),
        phaseType: PhaseType.voidPhase,
      ),
      PhaseBlockData(
        position: Vector2(380, 240),
        size: Vector2(platW, 16),
        phaseType: PhaseType.solar,
      ),
      PhaseBlockData(
        position: Vector2(510, 250),
        size: Vector2(platW, 16),
        phaseType: PhaseType.voidPhase,
      ),
    ];

    final shards = <ChronoShardData>[
      ChronoShardData(position: Vector2(130 + platW / 2, 215), shardIndex: 0),
      ChronoShardData(position: Vector2(250 + platW / 2, 195), shardIndex: 1),
      ChronoShardData(position: Vector2(510 + platW / 2, 215), shardIndex: 2),
    ];

    final directives = <ChamberDirectiveData>[];
    if (chamberId == 2) {
      directives.add(
        ChamberDirectiveData(
          position: Vector2(80, 200),
          title: 'PHASE ARCHIPELAGO',
          subtitle: 'CROSS FLOATING VOID ISLETS',
        ),
      );
    }

    final movingPlatforms = <MovingPlatformData>[];
    if (tierIdx >= 1) {
      movingPlatforms.add(
        MovingPlatformData(
          startPosition: Vector2(300.0, 210.0),
          endPosition: Vector2(360.0, 210.0),
          size: Vector2(48.0, 14.0),
          speed: 45.0,
        ),
      );
    }

    return ChamberDefinition(
      chamberId: chamberId,
      name: name,
      topologyName: 'PHASE ARCHIPELAGO',
      description:
          'Sector ${chamberId.toString().padLeft(3, '0')} // ${tier.sectorName}',
      parTimeMs: 16000 + (tierIdx * 3200),
      tier: tier,
      spawnPoint: Vector2(40.0, floorY - 18.0),
      portalPosition: Vector2(width - 40.0, floorY),
      width: width,
      height: height,
      universalBlocks: universal,
      phaseBlocks: phaseBlocks,
      spikes: spikes,
      shards: shards,
      directives: directives,
      movingPlatforms: movingPlatforms,
    );
  }

  static ChamberDefinition _buildClaustrophobicSqueeze({
    required int chamberId,
    required String name,
    required ChamberTier tier,
    required int tierIdx,
    required math.Random rng,
  }) {
    final width = 760.0 + (tierIdx * 20.0);
    const height = 260.0;
    const floorY = 228.0;

    final universal = <UniversalBlockData>[
      UniversalBlockData(position: Vector2(0, 0), size: Vector2(width, 16)),
      UniversalBlockData(position: Vector2(0, 0), size: Vector2(16, height)),
      UniversalBlockData(
        position: Vector2(width - 16, 0),
        size: Vector2(16, height),
      ),
      UniversalBlockData(position: Vector2(0, floorY), size: Vector2(100, 32)),
      UniversalBlockData(
        position: Vector2(width - 100, floorY),
        size: Vector2(100, 32),
      ),
      // Central low ceiling barrier
      UniversalBlockData(
        position: Vector2(120, 16),
        size: Vector2(width - 240, 100),
      ),
    ];

    final phaseBlocks = <PhaseBlockData>[
      PhaseBlockData(
        position: Vector2(140, floorY),
        size: Vector2(110, 32),
        phaseType: PhaseType.solar,
      ),
      PhaseBlockData(
        position: Vector2(290, floorY),
        size: Vector2(110, 32),
        phaseType: PhaseType.voidPhase,
      ),
      PhaseBlockData(
        position: Vector2(440, floorY),
        size: Vector2(110, 32),
        phaseType: PhaseType.solar,
      ),
    ];

    final spikes = <HazardSpikeData>[
      HazardSpikeData(
        position: Vector2(250, floorY - 12),
        size: Vector2(40, 12),
      ),
      HazardSpikeData(
        position: Vector2(400, floorY - 12),
        size: Vector2(40, 12),
      ),
      HazardSpikeData(
        position: Vector2(200, 116),
        size: Vector2(32, 12),
        orientation: SpikeOrientation.down,
      ),
      HazardSpikeData(
        position: Vector2(350, 116),
        size: Vector2(32, 12),
        orientation: SpikeOrientation.down,
      ),
    ];

    final shards = <ChronoShardData>[
      ChronoShardData(position: Vector2(200, 185), shardIndex: 0),
      ChronoShardData(position: Vector2(350, 185), shardIndex: 1),
      ChronoShardData(position: Vector2(500, 185), shardIndex: 2),
    ];

    final directives = <ChamberDirectiveData>[];
    if (chamberId == 3) {
      directives.add(
        ChamberDirectiveData(
          position: Vector2(80, 170),
          title: 'LOW CLEARANCE',
          subtitle: 'MICRO-HOP & CEILING STRIDE',
        ),
      );
    }

    final movingPlatforms = <MovingPlatformData>[];
    if (tierIdx >= 2) {
      movingPlatforms.add(
        MovingPlatformData(
          startPosition: Vector2(250.0, 160.0),
          endPosition: Vector2(370.0, 160.0),
          size: Vector2(40.0, 12.0),
          speed: 55.0,
        ),
      );
    }

    return ChamberDefinition(
      chamberId: chamberId,
      name: name,
      topologyName: 'LOW CLEARANCE',
      description:
          'Sector ${chamberId.toString().padLeft(3, '0')} // ${tier.sectorName}',
      parTimeMs: 15000 + (tierIdx * 3000),
      tier: tier,
      spawnPoint: Vector2(40.0, floorY - 18.0),
      portalPosition: Vector2(width - 50.0, floorY),
      width: width,
      height: height,
      universalBlocks: universal,
      phaseBlocks: phaseBlocks,
      spikes: spikes,
      shards: shards,
      directives: directives,
      movingPlatforms: movingPlatforms,
    );
  }

  static ChamberDefinition _buildSlingshotPendulum({
    required int chamberId,
    required String name,
    required ChamberTier tier,
    required int tierIdx,
    required math.Random rng,
  }) {
    final width = 800.0 + (tierIdx * 24.0);
    const height = 420.0;
    const launchY = 140.0;

    final universal = <UniversalBlockData>[
      UniversalBlockData(position: Vector2(0, 0), size: Vector2(width, 16)),
      UniversalBlockData(position: Vector2(0, 0), size: Vector2(16, height)),
      UniversalBlockData(
        position: Vector2(width - 16, 0),
        size: Vector2(16, height),
      ),
      UniversalBlockData(position: Vector2(0, launchY), size: Vector2(110, 24)),
      UniversalBlockData(
        position: Vector2(width - 110, launchY),
        size: Vector2(110, 24),
      ),
    ];

    final spikes = <HazardSpikeData>[
      HazardSpikeData(
        position: Vector2(110, height - 16),
        size: Vector2(width - 220, 16),
      ),
    ];

    final phaseBlocks = <PhaseBlockData>[
      PhaseBlockData(
        position: Vector2(170, 240),
        size: Vector2(70, 16),
        phaseType: PhaseType.solar,
      ),
      PhaseBlockData(
        position: Vector2(300, 320),
        size: Vector2(70, 16),
        phaseType: PhaseType.solar,
      ),
      PhaseBlockData(
        position: Vector2(440, 48),
        size: Vector2(130, 16),
        phaseType: PhaseType.voidPhase,
      ),
      PhaseBlockData(
        position: Vector2(620, 190),
        size: Vector2(70, 16),
        phaseType: PhaseType.solar,
      ),
    ];

    final shards = <ChronoShardData>[
      ChronoShardData(position: Vector2(205, 205), shardIndex: 0),
      ChronoShardData(position: Vector2(505, 80), shardIndex: 1),
      ChronoShardData(position: Vector2(655, 155), shardIndex: 2),
    ];

    return ChamberDefinition(
      chamberId: chamberId,
      name: name,
      topologyName: 'SLINGSHOT PENDULUM',
      description:
          'Sector ${chamberId.toString().padLeft(3, '0')} // ${tier.sectorName}',
      parTimeMs: 18000 + (tierIdx * 3500),
      tier: tier,
      spawnPoint: Vector2(40.0, launchY - 18.0),
      portalPosition: Vector2(width - 50.0, launchY),
      width: width,
      height: height,
      universalBlocks: universal,
      phaseBlocks: phaseBlocks,
      spikes: spikes,
      shards: shards,
    );
  }

  static ChamberDefinition _buildBifurcatedArena({
    required int chamberId,
    required String name,
    required ChamberTier tier,
    required int tierIdx,
    required math.Random rng,
  }) {
    final width = 840.0 + (tierIdx * 24.0);
    const height = 380.0;
    const floorY = 348.0;

    final universal = <UniversalBlockData>[
      UniversalBlockData(position: Vector2(0, 0), size: Vector2(width, 16)),
      UniversalBlockData(position: Vector2(0, 0), size: Vector2(16, height)),
      UniversalBlockData(
        position: Vector2(width - 16, 0),
        size: Vector2(16, height),
      ),
      UniversalBlockData(position: Vector2(0, floorY), size: Vector2(100, 32)),
      UniversalBlockData(
        position: Vector2(width - 100, floorY),
        size: Vector2(100, 32),
      ),
      // Safe low path platforms
      UniversalBlockData(
        position: Vector2(140, floorY),
        size: Vector2(120, 32),
      ),
      UniversalBlockData(
        position: Vector2(320, floorY),
        size: Vector2(140, 32),
      ),
      UniversalBlockData(
        position: Vector2(520, floorY),
        size: Vector2(140, 32),
      ),
    ];

    // High speedrun/shard aerial route
    final phaseBlocks = <PhaseBlockData>[
      PhaseBlockData(
        position: Vector2(180, 220),
        size: Vector2(60, 16),
        phaseType: PhaseType.solar,
      ),
      PhaseBlockData(
        position: Vector2(350, 150),
        size: Vector2(60, 16),
        phaseType: PhaseType.voidPhase,
      ),
      PhaseBlockData(
        position: Vector2(520, 190),
        size: Vector2(60, 16),
        phaseType: PhaseType.solar,
      ),
      PhaseBlockData(
        position: Vector2(660, 260),
        size: Vector2(60, 16),
        phaseType: PhaseType.voidPhase,
      ),
    ];

    final spikes = <HazardSpikeData>[
      HazardSpikeData(
        position: Vector2(260, height - 16),
        size: Vector2(60, 16),
      ),
      HazardSpikeData(
        position: Vector2(460, height - 16),
        size: Vector2(60, 16),
      ),
      HazardSpikeData(
        position: Vector2(660, height - 16),
        size: Vector2(80, 16),
      ),
    ];

    final shards = <ChronoShardData>[
      ChronoShardData(position: Vector2(210, 185), shardIndex: 0),
      ChronoShardData(position: Vector2(380, 115), shardIndex: 1),
      ChronoShardData(position: Vector2(550, 155), shardIndex: 2),
    ];

    return ChamberDefinition(
      chamberId: chamberId,
      name: name,
      topologyName: 'SPLIT PATH',
      description:
          'Sector ${chamberId.toString().padLeft(3, '0')} // ${tier.sectorName}',
      parTimeMs: 20000 + (tierIdx * 3500),
      tier: tier,
      spawnPoint: Vector2(40.0, floorY - 18.0),
      portalPosition: Vector2(width - 50.0, floorY),
      width: width,
      height: height,
      universalBlocks: universal,
      phaseBlocks: phaseBlocks,
      spikes: spikes,
      shards: shards,
    );
  }

  static ChamberDefinition _buildAscentTower({
    required int chamberId,
    required String name,
    required ChamberTier tier,
    required int tierIdx,
    required math.Random rng,
  }) {
    const width = 480.0;
    const height = 640.0;
    const floorY = 608.0;

    final universal = <UniversalBlockData>[
      UniversalBlockData(position: Vector2(0, 0), size: Vector2(width, 16)),
      UniversalBlockData(position: Vector2(0, 0), size: Vector2(16, height)),
      UniversalBlockData(
        position: Vector2(width - 16, 0),
        size: Vector2(16, height),
      ),
      UniversalBlockData(position: Vector2(0, floorY), size: Vector2(120, 32)),
      // Top portal shelf
      UniversalBlockData(
        position: Vector2(width - 120, 80),
        size: Vector2(120, 24),
      ),
    ];

    final spikes = <HazardSpikeData>[
      HazardSpikeData(
        position: Vector2(120, height - 16),
        size: Vector2(width - 120, 16),
      ),
    ];

    final platW = 74.0 - (tierIdx * 3);
    final phaseBlocks = <PhaseBlockData>[
      PhaseBlockData(
        position: Vector2(16, 520),
        size: Vector2(platW, 16),
        phaseType: PhaseType.solar,
      ),
      PhaseBlockData(
        position: Vector2(width - 16 - platW, 440),
        size: Vector2(platW, 16),
        phaseType: PhaseType.voidPhase,
      ),
      PhaseBlockData(
        position: Vector2(16, 360),
        size: Vector2(platW, 16),
        phaseType: PhaseType.solar,
      ),
      PhaseBlockData(
        position: Vector2(width - 16 - platW, 270),
        size: Vector2(platW, 16),
        phaseType: PhaseType.voidPhase,
      ),
      PhaseBlockData(
        position: Vector2(16, 180),
        size: Vector2(platW, 16),
        phaseType: PhaseType.solar,
      ),
    ];

    final shards = <ChronoShardData>[
      ChronoShardData(position: Vector2(50, 485), shardIndex: 0),
      ChronoShardData(position: Vector2(width - 60, 235), shardIndex: 1),
      ChronoShardData(position: Vector2(50, 145), shardIndex: 2),
    ];

    final ladders = <PhaseLadderData>[
      PhaseLadderData(
        position: Vector2(width / 2 - 10.0, 310.0),
        size: Vector2(20.0, 90.0),
      ),
    ];

    return ChamberDefinition(
      chamberId: chamberId,
      name: name,
      topologyName: 'ASCENT SPIRE',
      description:
          'Sector ${chamberId.toString().padLeft(3, '0')} // ${tier.sectorName}',
      parTimeMs: 24000 + (tierIdx * 4000),
      tier: tier,
      spawnPoint: Vector2(40.0, floorY - 18.0),
      portalPosition: Vector2(width - 50.0, 80.0),
      width: width,
      height: height,
      universalBlocks: universal,
      phaseBlocks: phaseBlocks,
      spikes: spikes,
      shards: shards,
      ladders: ladders,
    );
  }

  static ChamberDefinition _buildDescentChasm({
    required int chamberId,
    required String name,
    required ChamberTier tier,
    required int tierIdx,
    required math.Random rng,
  }) {
    const width = 500.0;
    const height = 640.0;
    const topY = 80.0;
    const bottomY = 608.0;

    final universal = <UniversalBlockData>[
      UniversalBlockData(position: Vector2(0, 0), size: Vector2(width, 16)),
      UniversalBlockData(position: Vector2(0, 0), size: Vector2(16, height)),
      UniversalBlockData(
        position: Vector2(width - 16, 0),
        size: Vector2(16, height),
      ),
      // Top spawn ledge
      UniversalBlockData(position: Vector2(0, topY), size: Vector2(110, 24)),
      // Bottom portal landing
      UniversalBlockData(
        position: Vector2(width - 110, bottomY),
        size: Vector2(110, 32),
      ),
    ];

    final spikes = <HazardSpikeData>[
      HazardSpikeData(
        position: Vector2(16, 120),
        size: Vector2(12, 420),
        orientation: SpikeOrientation.right,
      ),
      HazardSpikeData(
        position: Vector2(width - 28, 120),
        size: Vector2(12, 420),
        orientation: SpikeOrientation.left,
      ),
      HazardSpikeData(
        position: Vector2(0, height - 16),
        size: Vector2(width - 110, 16),
      ),
    ];

    final phaseBlocks = <PhaseBlockData>[
      PhaseBlockData(
        position: Vector2(170, 200),
        size: Vector2(160, 16),
        phaseType: PhaseType.solar,
      ),
      PhaseBlockData(
        position: Vector2(170, 340),
        size: Vector2(160, 16),
        phaseType: PhaseType.voidPhase,
      ),
      PhaseBlockData(
        position: Vector2(170, 480),
        size: Vector2(160, 16),
        phaseType: PhaseType.solar,
      ),
    ];

    final shards = <ChronoShardData>[
      ChronoShardData(position: Vector2(250, 160), shardIndex: 0),
      ChronoShardData(position: Vector2(250, 300), shardIndex: 1),
      ChronoShardData(position: Vector2(250, 440), shardIndex: 2),
    ];

    return ChamberDefinition(
      chamberId: chamberId,
      name: name,
      topologyName: 'DESCENT CHASM',
      description:
          'Sector ${chamberId.toString().padLeft(3, '0')} // ${tier.sectorName}',
      parTimeMs: 20000 + (tierIdx * 3500),
      tier: tier,
      spawnPoint: Vector2(40.0, topY - 18.0),
      portalPosition: Vector2(width - 50.0, bottomY),
      width: width,
      height: height,
      universalBlocks: universal,
      phaseBlocks: phaseBlocks,
      spikes: spikes,
      shards: shards,
    );
  }

  static ChamberDefinition _buildSwitchback({
    required int chamberId,
    required String name,
    required ChamberTier tier,
    required int tierIdx,
    required math.Random rng,
  }) {
    final width = 700.0 + (tierIdx * 20.0);
    const height = 440.0;
    const floorY = 408.0;

    final universal = <UniversalBlockData>[
      UniversalBlockData(position: Vector2(0, 0), size: Vector2(width, 16)),
      UniversalBlockData(position: Vector2(0, 0), size: Vector2(16, height)),
      UniversalBlockData(
        position: Vector2(width - 16, 0),
        size: Vector2(16, height),
      ),
      // Bottom start runway
      UniversalBlockData(position: Vector2(0, floorY), size: Vector2(100, 32)),
      // Top-left portal shelf
      UniversalBlockData(position: Vector2(0, 90), size: Vector2(110, 24)),
      // Floor hurdle
      UniversalBlockData(
        position: Vector2(width - 150, floorY - 24),
        size: Vector2(50, 24),
      ),
    ];

    final phaseBlocks = <PhaseBlockData>[
      PhaseBlockData(
        position: Vector2(140, floorY),
        size: Vector2(width - 320, 32),
        phaseType: PhaseType.solar,
      ),
      // Inverted ceiling return rail
      PhaseBlockData(
        position: Vector2(110, 32),
        size: Vector2(width - 240, 16),
        phaseType: PhaseType.voidPhase,
      ),
    ];

    final spikes = <HazardSpikeData>[
      HazardSpikeData(
        position: Vector2(width - 100, height - 16),
        size: Vector2(84, 16),
      ),
    ];

    final shards = <ChronoShardData>[
      ChronoShardData(position: Vector2(260, floorY - 30), shardIndex: 0),
      ChronoShardData(
        position: Vector2(width - 80, height * 0.5),
        shardIndex: 1,
      ),
      ChronoShardData(position: Vector2(220, 70), shardIndex: 2),
    ];

    return ChamberDefinition(
      chamberId: chamberId,
      name: name,
      topologyName: 'SWITCHBACK LOOP',
      description:
          'Sector ${chamberId.toString().padLeft(3, '0')} // ${tier.sectorName}',
      parTimeMs: 22000 + (tierIdx * 4000),
      tier: tier,
      spawnPoint: Vector2(40.0, floorY - 18.0),
      portalPosition: Vector2(50.0, 90.0),
      width: width,
      height: height,
      universalBlocks: universal,
      phaseBlocks: phaseBlocks,
      spikes: spikes,
      shards: shards,
    );
  }

  static ChamberDefinition _buildSectorClimax({
    required int chamberId,
    required String name,
    required ChamberTier tier,
    required int tierIdx,
    required math.Random rng,
  }) {
    const width = 920.0;
    const height = 480.0;
    const floorY = 448.0;

    final universal = <UniversalBlockData>[
      UniversalBlockData(position: Vector2(0, 0), size: Vector2(width, 16)),
      UniversalBlockData(position: Vector2(0, 0), size: Vector2(16, height)),
      UniversalBlockData(
        position: Vector2(width - 16, 0),
        size: Vector2(16, height),
      ),
      UniversalBlockData(position: Vector2(0, 200), size: Vector2(100, 24)),
      UniversalBlockData(
        position: Vector2(width - 100, floorY),
        size: Vector2(100, 32),
      ),
      // Mid-stage divider barrier
      UniversalBlockData(position: Vector2(520, 16), size: Vector2(24, 280)),
    ];

    final phaseBlocks = <PhaseBlockData>[
      // Step A: Slingshot chasm dive
      PhaseBlockData(
        position: Vector2(160, 300),
        size: Vector2(70, 16),
        phaseType: PhaseType.solar,
      ),
      PhaseBlockData(
        position: Vector2(280, 400),
        size: Vector2(70, 16),
        phaseType: PhaseType.solar,
      ),
      // Step B: Inverted ceiling catapult over divider
      PhaseBlockData(
        position: Vector2(400, 48),
        size: Vector2(110, 16),
        phaseType: PhaseType.voidPhase,
      ),
      // Step C: Right descent runway
      PhaseBlockData(
        position: Vector2(580, 260),
        size: Vector2(70, 16),
        phaseType: PhaseType.solar,
      ),
      PhaseBlockData(
        position: Vector2(690, 360),
        size: Vector2(70, 16),
        phaseType: PhaseType.voidPhase,
      ),
    ];

    final spikes = <HazardSpikeData>[
      HazardSpikeData(
        position: Vector2(100, height - 16),
        size: Vector2(width - 200, 16),
      ),
    ];

    final shards = <ChronoShardData>[
      ChronoShardData(position: Vector2(200, 265), shardIndex: 0),
      ChronoShardData(position: Vector2(455, 85), shardIndex: 1),
      ChronoShardData(position: Vector2(725, 325), shardIndex: 2),
    ];

    final phaseGates = <PhaseGateData>[];
    final tachyonPads = <TachyonPadData>[];

    if (tierIdx >= 2) {
      tachyonPads.add(
        TachyonPadData(
          position: Vector2(300.0, 180.0),
          size: Vector2(32.0, 6.0),
          boostVelocity: Vector2(340.0, -100.0),
        ),
      );
      phaseGates.add(
        PhaseGateData(
          position: Vector2(560.0, 120.0),
          size: Vector2(16.0, 56.0),
          phase: const SolarPhase(),
        ),
      );
    }

    return ChamberDefinition(
      chamberId: chamberId,
      name: name,
      topologyName: 'SECTOR CLIMAX',
      description: 'GRAND SECTOR FINALE // ${tier.sectorName}',
      parTimeMs: 25000 + (tierIdx * 5000),
      tier: tier,
      spawnPoint: Vector2(40.0, 182.0),
      portalPosition: Vector2(width - 50.0, floorY),
      width: width,
      height: height,
      universalBlocks: universal,
      phaseBlocks: phaseBlocks,
      spikes: spikes,
      shards: shards,
      phaseGates: phaseGates,
      tachyonPads: tachyonPads,
    );
  }

  static ChamberDefinition generateRandomChamber({
    int? seed,
    int difficulty = 3,
  }) {
    const randomId = 999;
    final resolvedSeed = seed ?? DateTime.now().millisecondsSinceEpoch;
    final chamber = generateChamber(
      chamberId: randomId,
      seed: resolvedSeed,
      difficulty: difficulty,
    );
    return ChamberDefinition(
      chamberId: randomId,
      name: 'QUANTUM // ${chamber.name}',
      topologyName: chamber.topologyName,
      description: 'Unstable procedurally synthesized reality anomaly',
      parTimeMs: chamber.parTimeMs,
      tier: ChamberTier.endless,
      spawnPoint: chamber.spawnPoint,
      portalPosition: chamber.portalPosition,
      width: chamber.width,
      height: chamber.height,
      universalBlocks: chamber.universalBlocks,
      phaseBlocks: chamber.phaseBlocks,
      spikes: chamber.spikes,
      shards: chamber.shards,
      beacons: chamber.beacons,
      phaseGates: chamber.phaseGates,
      tachyonPads: chamber.tachyonPads,
      directives: chamber.directives,
      movingPlatforms: chamber.movingPlatforms,
      ladders: chamber.ladders,
    );
  }
}
