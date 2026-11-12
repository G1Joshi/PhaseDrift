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

  TextPainter? _textPainter;
  int _lastAlphaStep = -1;

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
    final alphaStep = (alpha * 20).round();

    var textPainter = _textPainter;
    if (textPainter == null || alphaStep != _lastAlphaStep) {
      _lastAlphaStep = alphaStep;
      textPainter ??= TextPainter(textDirection: TextDirection.ltr);
      textPainter.text = TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: 'JetBrainsMono',
          fontSize: 10.0,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
          color: color.withValues(alpha: alphaStep / 20.0),
        ),
      );
      textPainter.layout();
      _textPainter = textPainter;
    }

    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );
  }

  @override
  void onRemove() {
    _textPainter?.dispose();
    _textPainter = null;
    super.onRemove();
  }
}
