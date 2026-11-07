import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/theme.dart';

class ChronoShard extends PositionComponent {
  ChronoShard({required Vector2 position, required this.shardIndex})
    : _baseY = position.y,
      super(position: position, size: Vector2.all(12.0), anchor: Anchor.center);

  final int shardIndex;
  final double _baseY;

  bool isCollected = false;
  double _elapsedTime = 0.0;

  bool collect() {
    if (isCollected) return false;
    isCollected = true;
    removeFromParent();
    return true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isCollected) return;

    _elapsedTime += dt;
    angle += 2.5 * dt;
    position.y = _baseY + math.sin(_elapsedTime * 3.5) * 3.0;
  }

  @override
  void render(Canvas canvas) {
    if (isCollected) return;
    super.render(canvas);

    final path = Path()
      ..moveTo(size.x / 2, 0)
      ..lineTo(size.x, size.y / 2)
      ..lineTo(size.x / 2, size.y)
      ..lineTo(0, size.y / 2)
      ..close();

    final fillPaint = Paint()..color = AppColors.chronoShard;
    final glowPaint = Paint()
      ..color = AppColors.chronoShard.withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, fillPaint);
  }
}
