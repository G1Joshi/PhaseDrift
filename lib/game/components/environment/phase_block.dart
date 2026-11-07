import 'package:flame/components.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/domain/domain.dart';
import '../../../core/theme/theme.dart';

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

    final solid = isSolid(const SolarPhase());
    final opacity = solid ? 1.0 : 0.25;

    final fillPaint = Paint()
      ..color = _color.withValues(alpha: solid ? 0.35 : 0.10);
    final borderPaint = Paint()
      ..color = _color.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    canvas.drawRect(rect, fillPaint);
    canvas.drawRect(rect, borderPaint);
  }
}
