import 'package:flame/components.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/theme.dart';

class FloatingCallout extends PositionComponent {
  FloatingCallout({
    required Vector2 position,
    required this.text,
    this.color = AppColors.solarAmber,
  }) : super(position: position, priority: 50);

  final String text;
  final Color color;

  double _lifetime = 0.0;
  static const double _maxLifetime = 0.65;

  @override
  void update(double dt) {
    super.update(dt);
    _lifetime += dt;
    position.y -= 35.0 * dt;

    if (_lifetime >= _maxLifetime) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final progress = (_lifetime / _maxLifetime).clamp(0.0, 1.0);
    final alpha = (1.0 - progress).clamp(0.0, 1.0);

    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        fontFamily: 'monospace',
        fontSize: 10.0,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
        color: color.withValues(alpha: alpha),
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );
  }
}
