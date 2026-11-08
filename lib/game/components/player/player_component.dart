import 'package:flame/components.dart';
import 'package:material_ui/material_ui.dart';

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

  @override
  void update(double dt) {
    super.update(dt);

    final wasGrounded = kinematics.isGrounded;

    final obstacles = <Rect>[];
    for (final block in game.world.children.query<UniversalBlock>()) {
      obstacles.add(block.toRect());
    }
    for (final block in game.world.children.query<PhaseBlock>()) {
      if (block.isSolid(kinematics.phase)) {
        obstacles.add(block.toRect());
      }
    }

    kinematics.update(dt, moveAxis: game.moveInput, solidObstacles: obstacles);
    position.setValues(kinematics.x, kinematics.y);

    if (!wasGrounded && kinematics.isGrounded) {
      triggerLandingSquish();
      final particleY = kinematics.isSolar
          ? position.y + size.y / 2
          : position.y - size.y / 2;
      game.world.addAll(
        ParticleFactory.createLandingBurst(
          position: Vector2(position.x, particleY),
          color: kinematics.phase.primaryColor,
        ),
      );
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
