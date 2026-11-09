import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/domain/domain.dart';
import '../../../../core/theme/theme.dart';

class PhaseLadder extends PositionComponent {
  PhaseLadder({
    required Vector2 position,
    required Vector2 size,
    this.phaseType,
  }) : super(position: position, size: size, priority: -1);

  final PhaseType? phaseType;
  double _pulse = 0.0;

  bool isActive(GamePhase currentPhase) {
    if (phaseType == null) return true;
    return currentPhase.isPlatformSolid(phaseType!);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _pulse += dt * 4.0;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final baseColor = phaseType == null
        ? AppColors.solarGold
        : (phaseType == PhaseType.solar
              ? AppColors.solarGold
              : AppColors.voidCyan);

    final glow = 0.6 + 0.4 * math.sin(_pulse);

    // Left and right vertical energy rails
    final railPaint = Paint()
      ..color = baseColor.withValues(alpha: 0.6 * glow)
      ..strokeWidth = 2.0;

    canvas.drawLine(const Offset(2.0, 0), Offset(2.0, size.y), railPaint);
    canvas.drawLine(
      Offset(size.x - 2.0, 0),
      Offset(size.x - 2.0, size.y),
      railPaint,
    );

    // Horizontal luminous rungs
    final rungPaint = Paint()
      ..color = baseColor.withValues(alpha: 0.85 * glow)
      ..strokeWidth = 2.5;

    for (double y = 8.0; y < size.y; y += 14.0) {
      final rungOffset = math.sin(_pulse + y * 0.1) * 0.5;
      canvas.drawLine(
        Offset(3.0, y + rungOffset),
        Offset(size.x - 3.0, y + rungOffset),
        rungPaint,
      );
    }
  }
}
