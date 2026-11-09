import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/domain/domain.dart';
import '../../../../core/theme/theme.dart';

class MovingPlatform extends PositionComponent {
  MovingPlatform({
    required Vector2 startPosition,
    required Vector2 endPosition,
    required Vector2 size,
    this.speed = 60.0,
    this.phaseType,
  }) : _startPosition = startPosition.clone(),
       _endPosition = endPosition.clone(),
       super(position: startPosition.clone(), size: size);

  final Vector2 _startPosition;
  final Vector2 _endPosition;
  final double speed;
  final PhaseType? phaseType;

  double _progress = 0.0;
  bool _forward = true;
  Vector2 velocity = Vector2.zero();

  bool isSolid(GamePhase currentPhase) {
    if (phaseType == null) return true;
    return currentPhase.isPlatformSolid(phaseType!);
  }

  @override
  void update(double dt) {
    super.update(dt);
    final distance = _startPosition.distanceTo(_endPosition);
    if (distance <= 0.001) return;

    final travelTime = distance / speed;
    final delta = dt / travelTime;

    final oldPos = position.clone();

    if (_forward) {
      _progress += delta;
      if (_progress >= 1.0) {
        _progress = 1.0;
        _forward = false;
      }
    } else {
      _progress -= delta;
      if (_progress <= 0.0) {
        _progress = 0.0;
        _forward = true;
      }
    }

    final smoothT = (1.0 - math.cos(_progress * math.pi)) / 2.0;
    position.setFrom(
      _startPosition + (_endPosition - _startPosition) * smoothT,
    );

    if (dt > 0) {
      velocity = (position - oldPos) / dt;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(3.0));

    final baseColor = phaseType == null
        ? AppColors.universalPlatform
        : (phaseType == PhaseType.solar
              ? AppColors.solarGold
              : AppColors.voidCyan);

    final fillPaint = Paint()
      ..color = baseColor.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawRRect(rrect, fillPaint);
    canvas.drawRRect(rrect, borderPaint);

    final chevronPaint = Paint()
      ..color = AppColors.obsidianVoid.withValues(alpha: 0.45)
      ..strokeWidth = 2.0;
    for (double x = 8.0; x < size.x - 4.0; x += 12.0) {
      canvas.drawLine(
        Offset(x, 3.0),
        Offset(x + 4.0, size.y - 3.0),
        chevronPaint,
      );
    }
  }
}
