import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/theme.dart';

class ShiftBeacon extends PositionComponent {
  ShiftBeacon({required Vector2 position, Vector2? size})
    : super(
        position: position,
        size: size ?? Vector2(16.0, 24.0),
        anchor: Anchor.center,
      );

  double _cooldown = 0.0;
  double _pulseTime = 0.0;

  bool trigger() {
    if (_cooldown > 0.0) return false;
    _cooldown = 0.4;
    return true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_cooldown > 0.0) {
      _cooldown -= dt;
      if (_cooldown < 0.0) _cooldown = 0.0;
    }
    _pulseTime += dt;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final pulse = 0.7 + 0.3 * math.sin(_pulseTime * 5.0);
    final amberPaint = Paint()
      ..color = AppColors.solarAmber.withValues(alpha: pulse)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final cyanPaint = Paint()
      ..color = AppColors.voidCyan.withValues(alpha: pulse)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final centerPaint = Paint()..color = AppColors.apexWhite;

    // Render outer dual-polarity brackets
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    canvas.drawArc(rect, -math.pi / 2, math.pi, false, amberPaint);
    canvas.drawArc(rect, math.pi / 2, math.pi, false, cyanPaint);

    // Center diamond glint
    final centerPath = Path()
      ..moveTo(size.x / 2, size.y / 2 - 4.0)
      ..lineTo(size.x / 2 + 4.0, size.y / 2)
      ..lineTo(size.x / 2, size.y / 2 + 4.0)
      ..lineTo(size.x / 2 - 4.0, size.y / 2)
      ..close();

    canvas.drawPath(centerPath, centerPaint);
  }
}
