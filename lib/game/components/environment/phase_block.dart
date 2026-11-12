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
  }) : super(position: position, size: size, anchor: Anchor.topLeft) {
    final c = _color;
    _fillPaint = Paint()..color = c.withValues(alpha: 0.35);
    _borderPaint = Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    _innerPaint = Paint()
      ..color = c.withValues(alpha: 0.60)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    _ghostBorderPaint = Paint()
      ..color = c.withValues(alpha: 0.20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
  }

  final PhaseType phaseType;
  late final Paint _fillPaint;
  late final Paint _borderPaint;
  late final Paint _innerPaint;
  late final Paint _ghostBorderPaint;
  PhaseDriftGame? _cachedGame;

  bool isSolid(GamePhase currentPhase) =>
      currentPhase.isPlatformSolid(phaseType);

  Color get _color =>
      phaseType == PhaseType.solar ? AppColors.solarAmber : AppColors.voidCyan;

  @override
  void onMount() {
    super.onMount();
    final g = findGame();
    _cachedGame = g is PhaseDriftGame ? g : null;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final parentGame = _cachedGame;
    final currentPhase = parentGame != null && parentGame.isLoaded
        ? parentGame.player.kinematics.phase
        : (phaseType == PhaseType.solar
              ? const SolarPhase()
              : const VoidPhase());
    final solid = isSolid(currentPhase);
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);

    if (solid) {
      canvas.drawRect(rect, _fillPaint);
      canvas.drawRect(rect, _borderPaint);
      canvas.drawLine(
        Offset(4.0, size.y / 2),
        Offset(size.x - 4.0, size.y / 2),
        _innerPaint,
      );
    } else {
      canvas.drawRect(rect, _ghostBorderPaint);
    }
  }
}
