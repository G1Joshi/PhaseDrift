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

  static final Paint _capPaint = Paint()..color = AppColors.cardSurface;
  late final Paint _capBorderPaint = Paint()
    ..color = phase.primaryColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;
  final Paint _beamGlowPaint = Paint()..style = PaintingStyle.fill;
  final Paint _beamCorePaint = Paint()
    ..strokeWidth = 2.0
    ..style = PaintingStyle.stroke;

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

    _beamGlowPaint.color = color.withValues(alpha: 0.25 * pulse);
    _beamCorePaint.color = color.withValues(alpha: 0.85 * pulse);

    if (isVertical) {
      final topCap = Rect.fromLTWH(0, 0, size.x, 4.0);
      final btmCap = Rect.fromLTWH(0, size.y - 4.0, size.x, 4.0);
      canvas.drawRect(topCap, _capPaint);
      canvas.drawRect(topCap, _capBorderPaint);
      canvas.drawRect(btmCap, _capPaint);
      canvas.drawRect(btmCap, _capBorderPaint);

      canvas.drawRect(
        Rect.fromLTWH(0, 4.0, size.x, size.y - 8.0),
        _beamGlowPaint,
      );

      canvas.drawLine(
        Offset(size.x / 2, 4.0),
        Offset(size.x / 2, size.y - 4.0),
        _beamCorePaint,
      );
    } else {
      final leftCap = Rect.fromLTWH(0, 0, 4.0, size.y);
      final rightCap = Rect.fromLTWH(size.x - 4.0, 0, 4.0, size.y);
      canvas.drawRect(leftCap, _capPaint);
      canvas.drawRect(leftCap, _capBorderPaint);
      canvas.drawRect(rightCap, _capPaint);
      canvas.drawRect(rightCap, _capBorderPaint);

      canvas.drawRect(
        Rect.fromLTWH(4.0, 0, size.x - 8.0, size.y),
        _beamGlowPaint,
      );

      canvas.drawLine(
        Offset(4.0, size.y / 2),
        Offset(size.x - 4.0, size.y / 2),
        _beamCorePaint,
      );
    }
  }
}
