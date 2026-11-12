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

  static final Paint _backPaint = Paint()..color = AppColors.deepCharcoal;
  static final Paint _solarArch = Paint()
    ..color = AppColors.solarAmber
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0;
  final Paint _voidArch = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;

  late final RRect _outerRRect = RRect.fromRectAndRadius(
    Rect.fromLTWH(0, 0, size.x, size.y),
    Radius.circular(size.x / 2),
  );
  late final RRect _innerRRect = _outerRRect.deflate(3.0);

  @override
  void update(double dt) {
    super.update(dt);
    _pulseTime += dt * 3.0;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final pulseAlpha = 0.6 + (math.sin(_pulseTime) * 0.3);
    _voidArch.color = AppColors.voidCyan.withValues(alpha: pulseAlpha);

    canvas.drawRRect(_outerRRect, _backPaint);
    canvas.drawRRect(_outerRRect, _solarArch);
    canvas.drawRRect(_innerRRect, _voidArch);
  }
}
