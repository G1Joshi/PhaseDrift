import 'package:flame/components.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/domain/domain.dart';
import '../../../core/theme/theme.dart';
import '../../phasedrift_game.dart';

class PhaseBlock extends PositionComponent {
  PhaseBlock({
    required Vector2 position,
    required Vector2 size,
    required this.phaseType,
  }) : super(position: position, size: size, anchor: Anchor.topLeft);

  final PhaseType phaseType;

  bool isSolid(GamePhase currentPhase) =>
      currentPhase.isPlatformSolid(phaseType);

  Color get _color =>
      phaseType == PhaseType.solar ? AppColors.solarAmber : AppColors.voidCyan;

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final parentGame = findGame();
    final currentPhase = parentGame is PhaseDriftGame && parentGame.isLoaded
        ? parentGame.player.kinematics.phase
        : (phaseType == PhaseType.solar
              ? const SolarPhase()
              : const VoidPhase());
    final solid = isSolid(currentPhase);
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);

    if (solid) {
      final fillPaint = Paint()..color = _color.withValues(alpha: 0.35);
      final borderPaint = Paint()
        ..color = _color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      canvas.drawRect(rect, fillPaint);
      canvas.drawRect(rect, borderPaint);

      final innerPaint = Paint()
        ..color = _color.withValues(alpha: 0.60)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawLine(
        Offset(4.0, size.y / 2),
        Offset(size.x - 4.0, size.y / 2),
        innerPaint,
      );
    } else {
      final ghostBorder = Paint()
        ..color = _color.withValues(alpha: 0.20)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8;
      canvas.drawRect(rect, ghostBorder);
    }
  }
}
