import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/theme.dart';

class TachyonPad extends PositionComponent {
  TachyonPad({
    required Vector2 position,
    required Vector2 size,
    Vector2? boostVelocity,
  }) : boostVelocity = boostVelocity ?? Vector2(320.0, 0.0),
       super(position: position, size: size, anchor: Anchor.topLeft);

  final Vector2 boostVelocity;
  double _cooldown = 0.0;
  double _animTime = 0.0;

  static final Paint _bgPaint = Paint()..color = AppColors.cardSurface;
  static final Paint _borderPaint = Paint()
    ..color = AppColors.solarGold
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;
  final Paint _chevronPaint = Paint()
    ..color = AppColors.solarGold
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;
  final Path _chevronPath = Path();

  bool get canTrigger => _cooldown <= 0.0;

  bool trigger() {
    if (!canTrigger) return false;
    _cooldown = 0.40;
    return true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_cooldown > 0.0) {
      _cooldown = math.max(0.0, _cooldown - dt);
    }
    _animTime += dt * 5.0;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    canvas.drawRect(rect, _bgPaint);
    canvas.drawRect(rect, _borderPaint);

    // Animated directional accelerator chevrons
    final chevronCount = (size.x / 10).floor().clamp(2, 6);
    final chevronSpacing = size.x / (chevronCount + 1);
    final cy = size.y / 2;

    for (var i = 1; i <= chevronCount; i++) {
      final wave = math.sin(_animTime + (i * 0.8));
      final opacity = (0.4 + (0.6 * ((wave + 1.0) / 2.0))).clamp(0.2, 1.0);
      _chevronPaint.color = AppColors.solarGold.withValues(alpha: opacity);

      final cx = i * chevronSpacing;
      _chevronPath
        ..reset()
        ..moveTo(cx - 3, cy - 3)
        ..lineTo(cx + 2, cy)
        ..lineTo(cx - 3, cy + 3);

      canvas.drawPath(_chevronPath, _chevronPaint);
    }
  }
}
