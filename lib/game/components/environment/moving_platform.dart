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

  Color get _baseColor => phaseType == null
      ? AppColors.universalPlatform
      : (phaseType == PhaseType.solar
            ? AppColors.solarGold
            : AppColors.voidCyan);

  late final RRect _rrect = RRect.fromRectAndRadius(
    Rect.fromLTWH(0, 0, size.x, size.y),
    const Radius.circular(3.0),
  );
  late final Paint _fillPaint = Paint()
    ..color = _baseColor.withValues(alpha: 0.85)
    ..style = PaintingStyle.fill;
  late final Paint _borderPaint = Paint()
    ..color = _baseColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;
  static final Paint _chevronPaint = Paint()
    ..color = AppColors.obsidianVoid.withValues(alpha: 0.45)
    ..strokeWidth = 2.0;

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

    final oldX = position.x;
    final oldY = position.y;

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
    position.setValues(
      _startPosition.x + (_endPosition.x - _startPosition.x) * smoothT,
      _startPosition.y + (_endPosition.y - _startPosition.y) * smoothT,
    );

    if (dt > 0) {
      velocity.setValues((position.x - oldX) / dt, (position.y - oldY) / dt);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    canvas.drawRRect(_rrect, _fillPaint);
    canvas.drawRRect(_rrect, _borderPaint);

    for (double x = 8.0; x < size.x - 4.0; x += 12.0) {
      canvas.drawLine(
        Offset(x, 3.0),
        Offset(x + 4.0, size.y - 3.0),
        _chevronPaint,
      );
    }
  }
}
