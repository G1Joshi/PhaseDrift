import 'package:flame/camera.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../core/theme/theme.dart';
import 'components/environment/environment.dart';
import 'components/player/player_component.dart';
import 'constants/kinematic_constants.dart';
import 'levels/chamber_definition.dart';

class PhaseDriftGame extends FlameGame with KeyboardEvents {
  PhaseDriftGame({this.initialPlayerPosition, this.chamber});

  final Vector2? initialPlayerPosition;
  final ChamberDefinition? chamber;

  late final PlayerComponent player;
  double moveInput = 0.0;

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

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    final isLeft =
        keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
        keysPressed.contains(LogicalKeyboardKey.keyA);
    final isRight =
        keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
        keysPressed.contains(LogicalKeyboardKey.keyD);

    if (isLeft && !isRight) {
      moveInput = -1.0;
    } else if (isRight && !isLeft) {
      moveInput = 1.0;
    } else {
      moveInput = 0.0;
    }

    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.space) {
        player.kinematics.pressJump();
        player.triggerJumpSquish();
      } else if (event.logicalKey == LogicalKeyboardKey.shiftLeft ||
          event.logicalKey == LogicalKeyboardKey.shiftRight) {
        player.kinematics.triggerShift();
      }
    } else if (event is KeyUpEvent) {
      if (event.logicalKey == LogicalKeyboardKey.space) {
        player.kinematics.releaseJump();
      }
    }

    return KeyEventResult.handled;
  }
}
