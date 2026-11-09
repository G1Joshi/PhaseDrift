import 'package:flame/components.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/theme.dart';

class UniversalBlock extends PositionComponent {
  UniversalBlock({required Vector2 position, required Vector2 size})
    : super(position: position, size: size, anchor: Anchor.topLeft);

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final rect = Rect.fromLTWH(0, 0, size.x, size.y);

    // 1. Dark Structural Core
    final fillPaint = Paint()..color = AppColors.canvasDark;
    canvas.drawRect(rect, fillPaint);

    // 2. High-Contrast Rim & Bevel
    final rimPaint = Paint()
      ..color = AppColors.structuralSeam
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRect(rect, rimPaint);

    // 3. Top Glowing Edge Highlight (Platform Tread)
    final treadPaint = Paint()
      ..color = AppColors.onSurface.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawLine(const Offset(0, 0.75), Offset(size.x, 0.75), treadPaint);

    // 4. Tactical Corner Accents if large enough
    if (size.x >= 32.0 && size.y >= 16.0) {
      final accentPaint = Paint()..color = AppColors.universalBorder;
      canvas.drawRect(const Rect.fromLTWH(2, 2, 2, 2), accentPaint);
      canvas.drawRect(Rect.fromLTWH(size.x - 4, 2, 2, 2), accentPaint);
    }
  }
}
