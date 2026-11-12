import 'package:flame/components.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/theme.dart';

class UniversalBlock extends PositionComponent {
  UniversalBlock({required Vector2 position, required Vector2 size})
    : super(position: position, size: size, anchor: Anchor.topLeft);

  static final Paint _fillPaint = Paint()..color = AppColors.canvasDark;
  static final Paint _rimPaint = Paint()
    ..color = AppColors.structuralSeam
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;
  static final Paint _treadPaint = Paint()
    ..color = AppColors.onSurface.withValues(alpha: 0.25)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;
  static final Paint _accentPaint = Paint()..color = AppColors.universalBorder;

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final rect = Rect.fromLTWH(0, 0, size.x, size.y);

    // 1. Dark Structural Core
    canvas.drawRect(rect, _fillPaint);

    // 2. High-Contrast Rim & Bevel
    canvas.drawRect(rect, _rimPaint);

    // 3. Top Glowing Edge Highlight (Platform Tread)
    canvas.drawLine(const Offset(0, 0.75), Offset(size.x, 0.75), _treadPaint);

    // 4. Tactical Corner Accents if large enough
    if (size.x >= 32.0 && size.y >= 16.0) {
      canvas.drawRect(const Rect.fromLTWH(2, 2, 2, 2), _accentPaint);
      canvas.drawRect(Rect.fromLTWH(size.x - 4, 2, 2, 2), _accentPaint);
    }
  }
}
