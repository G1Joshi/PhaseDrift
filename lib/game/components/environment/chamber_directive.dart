import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';

class ChamberDirective extends PositionComponent {
  ChamberDirective({
    required Vector2 position,
    required this.title,
    this.subtitle = '',
    this.accentColor = AppColors.solarAmber,
  }) : super(
         position: position,
         size: Vector2(76.0, 22.0),
         anchor: Anchor.center,
         priority: -1,
       );

  final String title;
  final String subtitle;
  final Color accentColor;

  double _pulseTimer = 0.0;

  static final Paint _bgPaint = Paint()
    ..color = AppColors.obsidianVoid.withValues(alpha: 0.65)
    ..style = PaintingStyle.fill;
  final Paint _fillPaint = Paint()..style = PaintingStyle.fill;
  final Paint _borderPaint = Paint()
    ..strokeWidth = 0.75
    ..style = PaintingStyle.stroke;
  late final RRect _rrect = RRect.fromRectAndRadius(
    Rect.fromLTWH(0, 0, size.x, size.y),
    const Radius.circular(2.5),
  );

  late final TextPaint _titlePaint = TextPaint(
    style: const TextStyle(
      fontFamily: 'JetBrainsMono',
      fontSize: 6.5,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.8,
      color: AppColors.onSurface,
    ),
  );
  late final TextPaint _subtitlePaint = TextPaint(
    style: TextStyle(
      fontFamily: 'JetBrainsMono',
      fontSize: 4.8,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      color: accentColor.withValues(alpha: 0.85),
    ),
  );

  @override
  void update(double dt) {
    super.update(dt);
    _pulseTimer += dt * 3.0;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final pulse = 0.5 + 0.5 * math.sin(_pulseTimer);
    final bgAlpha = 0.08 + 0.04 * pulse;
    final borderAlpha = 0.35 + 0.25 * pulse;

    // Subtle dark translucent background
    canvas.drawRRect(_rrect, _bgPaint);

    _fillPaint.color = accentColor.withValues(alpha: bgAlpha);
    canvas.drawRRect(_rrect, _fillPaint);

    // Tactical corner bracket accents
    _borderPaint.color = accentColor.withValues(alpha: borderAlpha);

    const bLen = 5.0;
    // Top-left
    canvas.drawLine(Offset.zero, const Offset(bLen, 0), _borderPaint);
    canvas.drawLine(Offset.zero, const Offset(0, bLen), _borderPaint);

    // Top-right
    canvas.drawLine(Offset(size.x, 0), Offset(size.x - bLen, 0), _borderPaint);
    canvas.drawLine(Offset(size.x, 0), Offset(size.x, bLen), _borderPaint);

    // Bottom-left
    canvas.drawLine(Offset(0, size.y), Offset(bLen, size.y), _borderPaint);
    canvas.drawLine(Offset(0, size.y), Offset(0, size.y - bLen), _borderPaint);

    // Bottom-right
    canvas.drawLine(
      Offset(size.x, size.y),
      Offset(size.x - bLen, size.y),
      _borderPaint,
    );
    canvas.drawLine(
      Offset(size.x, size.y),
      Offset(size.x, size.y - bLen),
      _borderPaint,
    );

    // Draw Title
    _titlePaint.render(
      canvas,
      title,
      Vector2(size.x / 2, subtitle.isNotEmpty ? 7.5 : 11.0),
      anchor: Anchor.center,
    );

    // Draw Subtitle
    if (subtitle.isNotEmpty) {
      _subtitlePaint.render(
        canvas,
        subtitle,
        Vector2(size.x / 2, 15.5),
        anchor: Anchor.center,
      );
    }
  }
}
