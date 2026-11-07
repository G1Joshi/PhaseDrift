import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/theme.dart';

class ExitPortal extends PositionComponent {
  ExitPortal({required Vector2 position})
    : super(
        position: position,
        size: Vector2(24.0, 32.0),
        anchor: Anchor.bottomCenter,
      );

  double _pulseTime = 0.0;

  @override
  void update(double dt) {
    super.update(dt);
    _pulseTime += dt * 3.0;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(size.x / 2));

    final backPaint = Paint()..color = AppColors.deepCharcoal;
    final solarArch = Paint()
      ..color = AppColors.solarAmber
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final pulseAlpha = 0.6 + (math.sin(_pulseTime) * 0.3);
    final voidArch = Paint()
      ..color = AppColors.voidCyan.withValues(alpha: pulseAlpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawRRect(rrect, backPaint);
    canvas.drawRRect(rrect, solarArch);
    canvas.drawRRect(rrect.deflate(3.0), voidArch);
  }
}
