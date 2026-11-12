import 'package:flame/camera.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../core/audio/audio.dart';
import '../core/domain/domain.dart';
import '../core/services/services.dart';
import '../core/theme/theme.dart';
import '../ui/controls/input_controller.dart';
import 'components/environment/environment.dart';
import 'components/player/ghost_replay_component.dart';
import 'components/player/player_component.dart';
import 'constants/kinematic_constants.dart';
import 'fx/fx.dart';
import 'levels/chamber_definition.dart';

class PhaseDriftGame extends FlameGame with KeyboardEvents {
  PhaseDriftGame({this.initialPlayerPosition, this.chamber});

  final Vector2? initialPlayerPosition;
  final ChamberDefinition? chamber;

  PlayerComponent? _player;
  PlayerComponent get player => _player!;
  InputController? _inputController;
  InputController get inputController => _inputController!;
  final ScreenShake screenShake = ScreenShake();

  double moveInput = 0.0;
  double elapsedTime = 0.0;
  bool isTimerStarted = false;
  int shardsCollectedMask = 0;
  bool isPaused = false;
  bool isCompleted = false;
  bool reduceMotion = false;
  double ceilingDriftSeconds = 0.0;
  int sessionShifts = 0;
  int sessionJumps = 0;
  int sessionDeaths = 0;
  static const int _maxGhostFrames = 3600;
  final List<GhostFrame> _recordedFrames = [];
  double _ghostSampleTimer = 0.0;
  final ValueNotifier<GamePhase> phaseNotifier = ValueNotifier<GamePhase>(
    const SolarPhase(),
  );

  int get elapsedMs => (elapsedTime * 1000).toInt();

  int get shardsCollectedCount =>
      ChamberRecord.countShards(shardsCollectedMask);

  void setReduceMotion(bool value) {
    reduceMotion = value;
    screenShake.reduceMotion = value;
  }

  @override
  void onDispose() {
    phaseNotifier.dispose();
    super.onDispose();
  }

  @override
  Color backgroundColor() => (_player != null && !player.kinematics.isSolar)
      ? const Color(0xFF03070C)
      : const Color(0xFF090704);

  @override
  Future<void> onLoad() async {
    world.children.register<UniversalBlock>();
    world.children.register<PhaseBlock>();
    world.children.register<MovingPlatform>();
    world.children.register<PhaseLadder>();
    world.children.register<ChronoShard>();
    world.children.register<ShiftBeacon>();
    world.children.register<HazardSpike>();
    world.children.register<PhaseGate>();
    world.children.register<TachyonPad>();
    world.children.register<ExitPortal>();
    world.children.register<FloatingCallout>();
    world.children.register<GhostReplayComponent>();

    camera.viewport = FixedResolutionViewport(
      resolution: Vector2(
        KinematicConstants.virtualWidth,
        KinematicConstants.virtualHeight,
      ),
    );

    final def = chamber;
    if (def != null) {
      _loadChamber(def);
    }

    final spawn = def?.spawnPoint ?? initialPlayerPosition ?? Vector2(100, 200);
    _player = PlayerComponent(initialPosition: spawn);
    world.add(_player!);

    _spawnGhostForChamber(def?.chamberId);

    camera.follow(_player!);

    _inputController = InputController(
      onMoveChanged: (axis) {
        moveInput = axis;
        if (axis.abs() > 0.05) isTimerStarted = true;
      },
      onJumpPressed: () {
        isTimerStarted = true;
        sessionJumps++;
        player.kinematics.pressJump();
        player.triggerJumpSquish();
        AudioEngine.instance.playJump();
        HapticsService.instance.triggerJump();
      },
      onJumpReleased: () {
        player.kinematics.releaseJump();
      },
      onShiftPressed: () {
        isTimerStarted = true;
        sessionShifts++;
        MilestoneService.instance.triggerUnlock('first_shift');
        final highSpeed = player.kinematics.vy.abs() > 180.0;
        player.kinematics.triggerShift();
        phaseNotifier.value = player.kinematics.phase;
        AudioEngine.instance.playShift();
        AudioEngine.instance.crossfadeToPhase(player.kinematics.phase);
        screenShake.addTrauma(highSpeed ? 0.45 : 0.25);
        if (highSpeed) {
          HapticsService.instance.triggerSlingshot();
          world.add(
            FloatingCallout(
              position: Vector2(player.position.x, player.position.y - 20.0),
              text: 'SLINGSHOT!',
              color: player.kinematics.phase.primaryColor,
            ),
          );
        } else {
          HapticsService.instance.triggerShift();
        }
        if (!reduceMotion) {
          world.add(
            ParticleFactory.createShockwave(
              center: player.position.clone(),
              primaryColor: player.kinematics.phase.primaryColor,
              accentColor: player.kinematics.phase.accentColor,
            ),
          );
          if (highSpeed) {
            world.addAll(
              ParticleFactory.createLandingBurst(
                position: player.position.clone(),
                color: player.kinematics.phase.primaryColor,
                count: 14,
              ),
            );
          }
        }
      },
      onPausePressed: () {
        togglePause();
      },
      onRestartPressed: () {
        restartChamber();
      },
    );
  }

  void _loadChamber(ChamberDefinition def) {
    world.add(
      QuantumBackdrop(width: def.width, height: def.height, tier: def.tier),
    );
    for (final b in def.universalBlocks) {
      world.add(UniversalBlock(position: b.position, size: b.size));
    }
    for (final pb in def.phaseBlocks) {
      world.add(
        PhaseBlock(
          position: pb.position,
          size: pb.size,
          phaseType: pb.phaseType,
        ),
      );
    }
    for (final s in def.spikes) {
      world.add(
        HazardSpike(
          position: s.position,
          size: s.size,
          orientation: s.orientation,
        ),
      );
    }
    for (final b in def.beacons) {
      world.add(ShiftBeacon(position: b.position, size: b.size));
    }
    for (final sh in def.shards) {
      world.add(ChronoShard(position: sh.position, shardIndex: sh.shardIndex));
    }
    for (final g in def.phaseGates) {
      world.add(PhaseGate(position: g.position, size: g.size, phase: g.phase));
    }
    for (final pad in def.tachyonPads) {
      world.add(
        TachyonPad(
          position: pad.position,
          size: pad.size,
          boostVelocity: pad.boostVelocity,
        ),
      );
    }
    for (final dir in def.directives) {
      world.add(
        ChamberDirective(
          position: dir.position,
          title: dir.title,
          subtitle: dir.subtitle,
          accentColor: def.tier.color,
        ),
      );
    }
    for (final m in def.movingPlatforms) {
      world.add(
        MovingPlatform(
          startPosition: m.startPosition,
          endPosition: m.endPosition,
          size: m.size,
          speed: m.speed,
          phaseType: m.phaseType,
        ),
      );
    }
    for (final l in def.ladders) {
      world.add(
        PhaseLadder(position: l.position, size: l.size, phaseType: l.phaseType),
      );
    }
    world.add(ExitPortal(position: def.portalPosition));
  }

  void _spawnGhostForChamber(int? chamberId) {
    for (final ghost in world.children.query<GhostReplayComponent>()) {
      ghost.removeFromParent();
    }
    if (chamberId == null ||
        chamberId == 999 ||
        !PersistenceService.instance.getGhostEnabled()) {
      return;
    }
    final savedGhost = PersistenceService.instance.getGhostRun(chamberId);
    if (savedGhost != null && savedGhost.frames.isNotEmpty) {
      world.add(GhostReplayComponent(ghostRun: savedGhost));
    }
  }

  void pauseGame() {
    isPaused = true;
    _inputController?.reset();
    overlays.add('PauseMenu');
    AudioEngine.instance.pauseMusic();
  }

  void resumeGame() {
    isPaused = false;
    overlays.remove('PauseMenu');
    AudioEngine.instance.resumeMusic();
  }

  void togglePause() {
    if (isCompleted) return;
    if (isPaused) {
      resumeGame();
    } else {
      pauseGame();
    }
  }

  void collectShard(int shardIndex, Vector2 shardPosition) {
    if (shardIndex >= 0 && shardIndex < 3) {
      shardsCollectedMask |= 1 << shardIndex;
      AudioEngine.instance.playShard();
      HapticsService.instance.triggerShard();

      final currentCount = shardsCollectedCount;
      final String calloutText;
      final Color calloutColor;
      if (currentCount == 1) {
        calloutText = 'SHARD 1/3';
        calloutColor = AppColors.solarAmber;
      } else if (currentCount == 2) {
        calloutText = 'SHARD 2/3';
        calloutColor = AppColors.solarAmber;
      } else {
        calloutText = 'CHRONO OVERDRIVE (3/3)';
        calloutColor = AppColors.chronoShard;
        screenShake.addTrauma(0.45);
        if (!reduceMotion) {
          world.add(
            ParticleFactory.createShockwave(
              center: shardPosition.clone(),
              primaryColor: AppColors.chronoShard,
              accentColor: AppColors.solarAmber,
            ),
          );
          world.addAll(
            ParticleFactory.createLandingBurst(
              position: shardPosition.clone(),
              color: AppColors.chronoShard,
              count: 16,
            ),
          );
        }
      }

      world.add(
        FloatingCallout(
          position: shardPosition.clone(),
          text: calloutText,
          color: calloutColor,
        ),
      );

      world.addAll(
        ParticleFactory.createShardSparkles(position: shardPosition),
      );
    }
  }

  void killPlayer() {
    sessionDeaths++;
    _inputController?.reset();
    AudioEngine.instance.playDeath();
    HapticsService.instance.triggerDeath();
    screenShake.addTrauma(0.70);
    world.addAll(
      ParticleFactory.createDeathBurst(position: player.position.clone()),
    );
    final spawn =
        chamber?.spawnPoint ?? initialPlayerPosition ?? Vector2(100, 200);
    player.position.setFrom(spawn);
    player.squishX = 1.0;
    player.squishY = 1.0;
    player.kinematics.x = spawn.x;
    player.kinematics.y = spawn.y;
    player.kinematics.vx = 0.0;
    player.kinematics.vy = 0.0;
    player.kinematics.coyoteTimer = 0.0;
    player.kinematics.jumpBufferTimer = 0.0;
    player.kinematics.phase = const SolarPhase();
    phaseNotifier.value = const SolarPhase();
    player.kinematics.isGrounded = false;
    AudioEngine.instance.crossfadeToPhase(const SolarPhase());
  }

  void completeChamber() async {
    if (isCompleted) return;
    isCompleted = true;
    isPaused = true;
    _inputController?.reset();
    await AudioEngine.instance.playShard();

    final def = chamber;
    if (def != null) {
      if (_recordedFrames.isNotEmpty && def.chamberId != 999) {
        final prevRecord = PersistenceService.instance.getChamberRecord(
          def.chamberId,
        );
        final isNewPb =
            prevRecord.bestTimeMs == null || elapsedMs < prevRecord.bestTimeMs!;
        if (isNewPb) {
          await PersistenceService.instance.saveGhostRun(
            GhostRun(
              chamberId: def.chamberId,
              clearTimeMs: elapsedMs,
              frames: List.of(_recordedFrames),
            ),
          );
        }
      }
      await ProgressionService.instance.completeChamber(
        chamberId: def.chamberId,
        completionTimeMs: elapsedMs,
        shardsMask: shardsCollectedMask,
        shiftsCount: sessionShifts,
        jumpsCount: sessionJumps,
        deathsCount: sessionDeaths,
      );
    }
    overlays.add('VictoryScreen');
  }

  void restartChamber() {
    elapsedTime = 0.0;
    isTimerStarted = false;
    shardsCollectedMask = 0;
    isCompleted = false;
    ceilingDriftSeconds = 0.0;
    sessionShifts = 0;
    sessionJumps = 0;
    sessionDeaths = 0;
    _recordedFrames.clear();
    _ghostSampleTimer = 0.0;
    _inputController?.reset();
    screenShake.reset();
    camera.viewfinder.angle = 0.0;
    for (final callout in world.children.query<FloatingCallout>()) {
      callout.removeFromParent();
    }
    overlays.remove('VictoryScreen');
    resumeGame();

    final p = _player;
    if (p == null) return;

    final def = chamber;
    _spawnGhostForChamber(def?.chamberId);
    if (def != null) {
      for (final s in world.children.query<ChronoShard>()) {
        s.removeFromParent();
      }
      for (final sh in def.shards) {
        world.add(
          ChronoShard(position: sh.position, shardIndex: sh.shardIndex),
        );
      }
    }

    final spawn =
        chamber?.spawnPoint ?? initialPlayerPosition ?? Vector2(100, 200);
    p.position.setFrom(spawn);
    p.squishX = 1.0;
    p.squishY = 1.0;
    p.kinematics.x = spawn.x;
    p.kinematics.y = spawn.y;
    p.kinematics.vx = 0.0;
    p.kinematics.vy = 0.0;
    p.kinematics.coyoteTimer = 0.0;
    p.kinematics.jumpBufferTimer = 0.0;
    p.kinematics.phase = const SolarPhase();
    phaseNotifier.value = const SolarPhase();
    p.kinematics.isGrounded = false;
    AudioEngine.instance.crossfadeToPhase(const SolarPhase());
  }

  @override
  void update(double dt) {
    if (isPaused || isCompleted || dt <= 0) return;
    final stepDt = dt > 0.1 ? 0.1 : dt;
    super.update(stepDt);
    if (isTimerStarted) {
      elapsedTime += stepDt;
    }

    // Apply Screen Shake to viewfinder
    final (shakeOffset, shakeAngle) = screenShake.update(stepDt);
    if (shakeOffset.x != 0 || shakeOffset.y != 0) {
      camera.viewfinder.position.add(shakeOffset);
    }
    camera.viewfinder.angle = shakeAngle;

    final p = _player;
    if (p == null) return;
    final playerRect = p.toRect();

    // Sample Ghost Replay Frames
    if (isTimerStarted && !isPaused && !isCompleted) {
      _ghostSampleTimer += stepDt;
      if (_ghostSampleTimer >= GhostReplayComponent.sampleInterval) {
        _ghostSampleTimer = 0.0;
        if (_recordedFrames.length < _maxGhostFrames) {
          _recordedFrames.add(
            GhostFrame(
              x: p.position.x,
              y: p.position.y,
              isSolar: p.kinematics.isSolar,
              squishX: p.squishX,
              squishY: p.squishY,
            ),
          );
        }
      }
    }

    // Check kinetic milestones
    if (p.kinematics.vx.abs() >= 220.0) {
      MilestoneService.instance.triggerUnlock('slingshot_master');
    }
    if (p.kinematics.isGrounded && p.kinematics.phase is VoidPhase) {
      ceilingDriftSeconds += stepDt;
      if (ceilingDriftSeconds >= 5.0) {
        MilestoneService.instance.triggerUnlock('ceiling_drifter');
      }
    }

    // 1. Collect Chrono-Shards
    for (final shard in world.children.query<ChronoShard>()) {
      if (!shard.isCollected && playerRect.overlaps(shard.toRect())) {
        final pos = shard.position.clone();
        if (shard.collect()) {
          collectShard(shard.shardIndex, pos);
        }
      }
    }

    // 2. Automated Shift Beacons
    for (final beacon in world.children.query<ShiftBeacon>()) {
      if (playerRect.overlaps(beacon.toRect())) {
        if (beacon.trigger()) {
          player.kinematics.triggerShift();
          phaseNotifier.value = player.kinematics.phase;
          AudioEngine.instance.playShift();
          AudioEngine.instance.crossfadeToPhase(player.kinematics.phase);
          HapticsService.instance.triggerShift();
        }
      }
    }

    // 3. Hazard Spikes
    for (final spike in world.children.query<HazardSpike>()) {
      if (playerRect.overlaps(spike.toRect().deflate(2.0))) {
        killPlayer();
        return;
      }
    }

    // 4. Phase Laser Gates (permeable if phase matches, lethal if mismatch)
    for (final gate in world.children.query<PhaseGate>()) {
      if (playerRect.overlaps(gate.toRect().deflate(2.0))) {
        if (player.kinematics.phase.runtimeType != gate.phase.runtimeType) {
          killPlayer();
          return;
        }
      }
    }

    // 5. Tachyon Acceleration Pads
    for (final pad in world.children.query<TachyonPad>()) {
      if (playerRect.overlaps(pad.toRect())) {
        if (pad.trigger()) {
          player.kinematics.vx = pad.boostVelocity.x;
          if (pad.boostVelocity.y != 0.0) {
            player.kinematics.vy = pad.boostVelocity.y;
          }
          AudioEngine.instance.playShift();
          HapticsService.instance.triggerShift();
          screenShake.addTrauma(0.35);
          if (!reduceMotion) {
            world.add(
              ParticleFactory.createShockwave(
                center: pad.position.clone() + (pad.size / 2),
                primaryColor: AppColors.solarGold,
                accentColor: AppColors.voidCyan,
              ),
            );
          }
        }
      }
    }

    // 6. Out of bounds check
    final chamberH = chamber?.height ?? 320.0;
    if (player.position.y > chamberH + 60.0 || player.position.y < -60.0) {
      killPlayer();
      return;
    }

    // 7. Exit Portal Victory
    final portal = world.children.query<ExitPortal>().firstOrNull;
    if (portal != null && playerRect.overlaps(portal.toRect())) {
      completeChamber();
    }
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    final controller = _inputController;
    if (isCompleted || controller == null) return KeyEventResult.ignored;
    final handled = controller.handleKeyEvent(event, keysPressed);
    return handled ? KeyEventResult.handled : KeyEventResult.ignored;
  }
}
