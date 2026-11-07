import 'package:flame/camera.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../core/domain/domain.dart';
import '../core/theme/theme.dart';
import '../ui/controls/input_controller.dart';
import 'components/environment/environment.dart';
import 'components/player/player_component.dart';
import 'constants/kinematic_constants.dart';
import 'levels/chamber_definition.dart';

class PhaseDriftGame extends FlameGame with KeyboardEvents {
  PhaseDriftGame({this.initialPlayerPosition, this.chamber});

  final Vector2? initialPlayerPosition;
  final ChamberDefinition? chamber;

  late final PlayerComponent player;
  late final InputController inputController;

  double moveInput = 0.0;
  double elapsedTime = 0.0;
  int shardsCollectedMask = 0;
  bool isPaused = false;

  int get elapsedMs => (elapsedTime * 1000).toInt();

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
    player = PlayerComponent(initialPosition: spawn);
    world.add(player);
    camera.follow(player);

    inputController = InputController(
      onMoveChanged: (axis) => moveInput = axis,
      onJumpPressed: () {
        player.kinematics.pressJump();
        player.triggerJumpSquish();
      },
      onJumpReleased: () {
        player.kinematics.releaseJump();
      },
      onShiftPressed: () {
        player.kinematics.triggerShift();
      },
      onPausePressed: () {
        togglePause();
      },
    );
  }

  void _loadChamber(ChamberDefinition def) {
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
    for (final sh in def.shards) {
      world.add(ChronoShard(position: sh.position, shardIndex: sh.shardIndex));
    }
    world.add(ExitPortal(position: def.portalPosition));
  }

  void pauseGame() {
    isPaused = true;
    overlays.add('PauseMenu');
  }

  void resumeGame() {
    isPaused = false;
    overlays.remove('PauseMenu');
  }

  void togglePause() {
    if (isPaused) {
      resumeGame();
    } else {
      pauseGame();
    }
  }

  void collectShard(int shardIndex) {
    if (shardIndex >= 0 && shardIndex < 3) {
      shardsCollectedMask |= (1 << shardIndex);
    }
  }

  void restartChamber() {
    elapsedTime = 0.0;
    shardsCollectedMask = 0;
    resumeGame();
    final spawn =
        chamber?.spawnPoint ?? initialPlayerPosition ?? Vector2(100, 200);
    player.position.setFrom(spawn);
    player.kinematics.x = spawn.x;
    player.kinematics.y = spawn.y;
    player.kinematics.vx = 0.0;
    player.kinematics.vy = 0.0;
    player.kinematics.phase = const SolarPhase();
    player.kinematics.isGrounded = false;
  }

  @override
  void update(double dt) {
    if (isPaused) return;
    super.update(dt);
    elapsedTime += dt;
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    final handled = inputController.handleKeyEvent(event, keysPressed);
    return handled ? KeyEventResult.handled : KeyEventResult.ignored;
  }
}
