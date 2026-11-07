import 'package:flame/components.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/theme.dart';

class UniversalBlock extends PositionComponent {
  UniversalBlock({required Vector2 position, required Vector2 size})
    : super(position: position, size: size, anchor: Anchor.topLeft);

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final fillPaint = Paint()..color = AppColors.universalPlatform;
    final borderPaint = Paint()
      ..color = AppColors.universalBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    canvas.drawRect(rect, fillPaint);
    canvas.drawRect(rect, borderPaint);
  }
}
