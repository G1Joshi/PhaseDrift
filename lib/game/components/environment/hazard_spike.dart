import 'package:flame/components.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/theme.dart';

enum SpikeOrientation { up, down, left, right }

class HazardSpike extends PositionComponent {
  HazardSpike({
    required Vector2 position,
    required Vector2 size,
    this.orientation = SpikeOrientation.up,
  }) : super(position: position, size: size, anchor: Anchor.topLeft);

  final SpikeOrientation orientation;

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final path = Path();
    switch (orientation) {
      case SpikeOrientation.up:
        path.moveTo(size.x / 2, 0);
        path.lineTo(size.x, size.y);
        path.lineTo(0, size.y);
        break;
      case SpikeOrientation.down:
        path.moveTo(0, 0);
        path.lineTo(size.x, 0);
        path.lineTo(size.x / 2, size.y);
        break;
      case SpikeOrientation.left:
        path.moveTo(0, size.y / 2);
        path.lineTo(size.x, 0);
        path.lineTo(size.x, size.y);
        break;
      case SpikeOrientation.right:
        path.moveTo(0, 0);
        path.lineTo(size.x, size.y / 2);
        path.lineTo(0, size.y);
        break;
    }
    path.close();

    final fillPaint = Paint()..color = AppColors.hazardRed;
    final strokePaint = Paint()
      ..color = AppColors.onSurface
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }
}
