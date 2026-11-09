import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/audio/audio.dart';
import '../../../core/services/services.dart';
import '../../../core/theme/theme.dart';
import '../../constants/kinematic_constants.dart';
import '../../fx/fx.dart';
import '../../phasedrift_game.dart';
import '../environment/environment.dart';
import 'player_kinematics.dart';

class PlayerComponent extends PositionComponent
    with HasGameReference<PhaseDriftGame> {
  PlayerComponent({Vector2? initialPosition})
    : kinematics = PlayerKinematics(
        x: initialPosition?.x ?? 100.0,
        y: initialPosition?.y ?? 200.0,
      ),
      super(
        size: Vector2(
          KinematicConstants.playerWidth,
          KinematicConstants.playerHeight,
        ),
        anchor: Anchor.center,
      );

  final PlayerKinematics kinematics;

  double squishX = 1.0;
  double squishY = 1.0;
  final List<Vector2> _ghostTrail = [];
  double _wallSparkTimer = 0.0;

  @override
  void update(double dt) {
    super.update(dt);

    final wasGrounded = kinematics.isGrounded;
    final preVy = kinematics.vy;

    final obstacles = <Rect>[];
    for (final block in game.world.children.query<UniversalBlock>()) {
      obstacles.add(block.toRect());
    }
    for (final block in game.world.children.query<PhaseBlock>()) {
      if (block.isSolid(kinematics.phase)) {
        obstacles.add(block.toRect());
      }
    }

    // Moving Platform carrier interaction
    Vector2 moverDelta = Vector2.zero();
    for (final mover in game.world.children.query<MovingPlatform>()) {
      if (mover.isSolid(kinematics.phase)) {
        obstacles.add(mover.toRect());
        final halfW = size.x / 2;
        final halfH = size.y / 2;
        final footRect = kinematics.isSolar
            ? Rect.fromLTWH(
                position.x - halfW + 1,
                position.y + halfH - 2,
                size.x - 2,
                4,
              )
            : Rect.fromLTWH(
                position.x - halfW + 1,
                position.y - halfH - 2,
                size.x - 2,
                4,
              );
        if (footRect.overlaps(mover.toRect())) {
          moverDelta = mover.velocity * dt;
        }
      }
    }

    // Phase Ladder & Gravitational Conduit interaction
    bool isOnLadder = false;
    for (final ladder in game.world.children.query<PhaseLadder>()) {
      if (ladder.isActive(kinematics.phase) &&
          toRect().overlaps(ladder.toRect())) {
        isOnLadder = true;
        break;
      }
    }

    kinematics.isOnLadder = isOnLadder;
    if (isOnLadder) {
      if (kinematics.isSolar && kinematics.vy > 40.0) {
        kinematics.vy = 40.0;
      } else if (!kinematics.isSolar && kinematics.vy < -40.0) {
        kinematics.vy = -40.0;
      }
    }

    kinematics.update(dt, moveAxis: game.moveInput, solidObstacles: obstacles);

    if (moverDelta.x != 0 || moverDelta.y != 0) {
      kinematics.x += moverDelta.x;
      kinematics.y += moverDelta.y;
    }
    position.setValues(kinematics.x, kinematics.y);

    // Dynamic ghost trails during high-speed kinetic runs and slingshots
    final speed = math.sqrt(
      kinematics.vx * kinematics.vx + kinematics.vy * kinematics.vy,
    );
    if (speed > 130.0 && !game.reduceMotion) {
      _ghostTrail.add(position.clone());
      if (_ghostTrail.length > 4) _ghostTrail.removeAt(0);
    } else if (_ghostTrail.isNotEmpty) {
      _ghostTrail.removeAt(0);
    }

    if (!wasGrounded && kinematics.isGrounded) {
      AudioEngine.instance.playLand();
      HapticsService.instance.triggerLand();
      final isHardLanding = preVy.abs() > 200.0;
      if (isHardLanding) {
        triggerHeavyLandingSquish();
        game.screenShake.addTrauma(0.12);
      } else {
        triggerLandingSquish();
      }
      final particleY = kinematics.isSolar
          ? position.y + size.y / 2
          : position.y - size.y / 2;
      game.world.addAll(
        ParticleFactory.createLandingBurst(
          position: Vector2(position.x, particleY),
          color: kinematics.phase.primaryColor,
          count: isHardLanding ? 14 : 8,
        ),
      );
    }

    // Wall slide friction sparks
    if (!kinematics.isGrounded &&
        (kinematics.isTouchingWallLeft || kinematics.isTouchingWallRight) &&
        kinematics.vy.abs() > 40.0 &&
        !game.reduceMotion) {
      _wallSparkTimer += dt;
      if (_wallSparkTimer >= 0.08) {
        _wallSparkTimer = 0.0;
        final wallX = kinematics.isTouchingWallLeft
            ? position.x - size.x / 2
            : position.x + size.x / 2;
        game.world.addAll(
          ParticleFactory.createLandingBurst(
            position: Vector2(wallX, position.y),
            color: kinematics.phase.accentColor,
            count: 3,
          ),
        );
      }
    }

    if (squishX != 1.0 || squishY != 1.0) {
      squishX = squishX + (1.0 - squishX) * (dt * 15.0);
      squishY = squishY + (1.0 - squishY) * (dt * 15.0);
      if ((squishX - 1.0).abs() < 0.01) squishX = 1.0;
      if ((squishY - 1.0).abs() < 0.01) squishY = 1.0;
    }

    scale.setValues(squishX, squishY);
  }

  void triggerJumpSquish() {
    squishX = 0.85;
    squishY = 1.25;
  }

  void triggerLandingSquish() {
    squishX = 1.30;
    squishY = 0.70;
  }

  void triggerHeavyLandingSquish() {
    squishX = 1.45;
    squishY = 0.55;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final phaseColor = kinematics.phase.primaryColor;
    final accentColor = kinematics.phase.accentColor;

    final bodyPaint = Paint()..color = AppColors.deepCharcoal;
    final rimPaint = Paint()
      ..color = phaseColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(3.0));

    // Render Speed Ghost Trails
    for (var i = 0; i < _ghostTrail.length; i++) {
      final ghost = _ghostTrail[i];
      final alpha = (0.08 * (i + 1)).clamp(0.0, 0.35);
      final ghostPaint = Paint()..color = phaseColor.withValues(alpha: alpha);
      final offset = Offset(ghost.x - position.x, ghost.y - position.y);
      canvas.drawRRect(rrect.shift(offset), ghostPaint);
    }

    canvas.drawRRect(rrect, bodyPaint);
    canvas.drawRRect(rrect, rimPaint);

    final visorPaint = Paint()..color = accentColor;
    final visorY = kinematics.isSolar ? 4.0 : size.y - 7.0;
    final visorRect = Rect.fromLTWH(2.0, visorY, size.x - 4.0, 3.0);
    canvas.drawRRect(
      RRect.fromRectAndRadius(visorRect, const Radius.circular(1.0)),
      visorPaint,
    );

    final thrusterPaint = Paint()
      ..color = phaseColor.withValues(alpha: 0.8)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);

    final thrusterY = kinematics.isSolar ? size.y : 0.0;
    canvas.drawCircle(Offset(size.x / 2, thrusterY), 2.5, thrusterPaint);
  }
}
