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
  late final InputController inputController;
  final ScreenShake screenShake = ScreenShake();

  double moveInput = 0.0;
  double elapsedTime = 0.0;
  bool isTimerStarted = false;
  int shardsCollectedMask = 0;
  bool isPaused = false;
  bool isCompleted = false;
  bool reduceMotion = false;

  int get elapsedMs => (elapsedTime * 1000).toInt();

  int get shardsCollectedCount {
    var count = 0;
    if ((shardsCollectedMask & 1) != 0) count++;
    if ((shardsCollectedMask & 2) != 0) count++;
    if ((shardsCollectedMask & 4) != 0) count++;
    return count;
  }

  void setReduceMotion(bool value) {
    reduceMotion = value;
    screenShake.reduceMotion = value;
  }

  @override
  Color backgroundColor() => AppColors.obsidianVoid;

  @override
  Future<void> onLoad() async {
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
    camera.follow(_player!);

    inputController = InputController(
      onMoveChanged: (axis) {
        moveInput = axis;
        if (axis.abs() > 0.05) isTimerStarted = true;
      },
      onJumpPressed: () {
        isTimerStarted = true;
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
        final highSpeed = player.kinematics.vy.abs() > 180.0;
        player.kinematics.triggerShift();
        AudioEngine.instance.playShift();
        AudioEngine.instance.crossfadeToPhase(player.kinematics.phase);
        screenShake.addTrauma(highSpeed ? 0.45 : 0.25);
        HapticsService.instance.triggerShift();
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
    world.add(ExitPortal(position: def.portalPosition));
  }

  void pauseGame() {
    isPaused = true;
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
      shardsCollectedMask |= (1 << shardIndex);
      AudioEngine.instance.playShard();
      HapticsService.instance.triggerShard();

      if (shardsCollectedCount == 3) {
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

      world.addAll(
        ParticleFactory.createShardSparkles(position: shardPosition),
      );
    }
  }

  void killPlayer() {
    AudioEngine.instance.playDeath();
    HapticsService.instance.triggerDeath();
    screenShake.addTrauma(0.70);
    world.addAll(
      ParticleFactory.createDeathBurst(position: player.position.clone()),
    );
    final spawn =
        chamber?.spawnPoint ?? initialPlayerPosition ?? Vector2(100, 200);
    player.position.setFrom(spawn);
    player.kinematics.x = spawn.x;
    player.kinematics.y = spawn.y;
    player.kinematics.vx = 0.0;
    player.kinematics.vy = 0.0;
    player.kinematics.coyoteTimer = 0.0;
    player.kinematics.jumpBufferTimer = 0.0;
    player.kinematics.phase = const SolarPhase();
    player.kinematics.isGrounded = false;
    AudioEngine.instance.crossfadeToPhase(const SolarPhase());
  }

  void completeChamber() async {
    if (isCompleted) return;
    isCompleted = true;
    isPaused = true;
    AudioEngine.instance.playShard();

    final def = chamber;
    if (def != null) {
      await ProgressionService.instance.completeChamber(
        chamberId: def.chamberId,
        completionTimeMs: elapsedMs,
        shardsMask: shardsCollectedMask,
      );
    }
    overlays.add('VictoryScreen');
  }

  void restartChamber() {
    elapsedTime = 0.0;
    isTimerStarted = false;
    shardsCollectedMask = 0;
    isCompleted = false;
    overlays.remove('VictoryScreen');
    resumeGame();

    final p = _player;
    if (p == null) return;

    final def = chamber;
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
    p.kinematics.x = spawn.x;
    p.kinematics.y = spawn.y;
    p.kinematics.vx = 0.0;
    p.kinematics.vy = 0.0;
    p.kinematics.coyoteTimer = 0.0;
    p.kinematics.jumpBufferTimer = 0.0;
    p.kinematics.phase = const SolarPhase();
    p.kinematics.isGrounded = false;
    AudioEngine.instance.crossfadeToPhase(const SolarPhase());
  }

  @override
  void update(double dt) {
    if (isPaused || isCompleted) return;
    super.update(dt);
    if (isTimerStarted) {
      elapsedTime += dt;
    }

    // Apply Screen Shake to viewfinder
    final (shakeOffset, shakeAngle) = screenShake.update(dt);
    if (shakeOffset.x != 0 || shakeOffset.y != 0) {
      camera.viewfinder.position.add(shakeOffset);
    }
    camera.viewfinder.angle = shakeAngle;

    final p = _player;
    if (p == null) return;
    final playerRect = p.toRect();

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
          AudioEngine.instance.playShift();
          AudioEngine.instance.crossfadeToPhase(player.kinematics.phase);
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

    // 4. Out of bounds check
    final chamberH = chamber?.height ?? 320.0;
    if (player.position.y > chamberH + 60.0 || player.position.y < -60.0) {
      killPlayer();
      return;
    }

    // 5. Exit Portal Victory
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
    if (isCompleted) return KeyEventResult.ignored;
    final handled = inputController.handleKeyEvent(event, keysPressed);
    return handled ? KeyEventResult.handled : KeyEventResult.ignored;
  }
}
