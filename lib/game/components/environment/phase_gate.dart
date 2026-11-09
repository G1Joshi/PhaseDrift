import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/domain/domain.dart';
import '../../../core/theme/theme.dart';

class PhaseGate extends PositionComponent {
  PhaseGate({
    required Vector2 position,
    required Vector2 size,
    required this.phase,
  }) : super(position: position, size: size, anchor: Anchor.topLeft);

  final GamePhase phase;
  double _pulseTime = 0.0;

  @override
  void update(double dt) {
    super.update(dt);
    _pulseTime += dt * 4.0;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final color = phase.primaryColor;
    final pulse = 0.75 + (0.25 * math.sin(_pulseTime));
    final isVertical = size.y >= size.x;

    final capPaint = Paint()..color = AppColors.cardSurface;
    final capBorderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    if (isVertical) {
      final topCap = Rect.fromLTWH(0, 0, size.x, 4.0);
      final btmCap = Rect.fromLTWH(0, size.y - 4.0, size.x, 4.0);
      canvas.drawRect(topCap, capPaint);
      canvas.drawRect(topCap, capBorderPaint);
      canvas.drawRect(btmCap, capPaint);
      canvas.drawRect(btmCap, capBorderPaint);

      final beamGlowPaint = Paint()
        ..color = color.withValues(alpha: 0.25 * pulse)
        ..style = PaintingStyle.fill;
      canvas.drawRect(
        Rect.fromLTWH(0, 4.0, size.x, size.y - 8.0),
        beamGlowPaint,
      );

      final beamCorePaint = Paint()
        ..color = color.withValues(alpha: 0.85 * pulse)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(size.x / 2, 4.0),
        Offset(size.x / 2, size.y - 4.0),
        beamCorePaint,
      );
    } else {
      final leftCap = Rect.fromLTWH(0, 0, 4.0, size.y);
      final rightCap = Rect.fromLTWH(size.x - 4.0, 0, 4.0, size.y);
      canvas.drawRect(leftCap, capPaint);
      canvas.drawRect(leftCap, capBorderPaint);
      canvas.drawRect(rightCap, capPaint);
      canvas.drawRect(rightCap, capBorderPaint);

      final beamGlowPaint = Paint()
        ..color = color.withValues(alpha: 0.25 * pulse)
        ..style = PaintingStyle.fill;
      canvas.drawRect(
        Rect.fromLTWH(4.0, 0, size.x - 8.0, size.y),
        beamGlowPaint,
      );

      final beamCorePaint = Paint()
        ..color = color.withValues(alpha: 0.85 * pulse)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(4.0, size.y / 2),
        Offset(size.x - 4.0, size.y / 2),
        beamCorePaint,
      );
    }
  }
}
