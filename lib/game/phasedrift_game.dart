import 'package:flame/camera.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../core/theme/theme.dart';
import 'components/player/player_component.dart';
import 'constants/kinematic_constants.dart';

class PhaseDriftGame extends FlameGame with KeyboardEvents {
  PhaseDriftGame({this.initialPlayerPosition});

  final Vector2? initialPlayerPosition;

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

    player = PlayerComponent(initialPosition: initialPlayerPosition);
    world.add(player);
    camera.follow(player);
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
