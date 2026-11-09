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
         size: Vector2(120.0, 40.0),
         anchor: Anchor.center,
         priority: -1,
       );

  final String title;
  final String subtitle;
  final Color accentColor;

  double _pulseTimer = 0.0;

  late final TextPaint _titlePaint;
  late final TextPaint _subtitlePaint;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _titlePaint = TextPaint(
      style: const TextStyle(
        fontFamily: 'monospace',
        fontSize: 10.0,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        color: AppColors.onSurface,
      ),
    );
    _subtitlePaint = TextPaint(
      style: TextStyle(
        fontFamily: 'monospace',
        fontSize: 7.5,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        color: accentColor.withValues(alpha: 0.85),
      ),
    );
  }

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

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      const Radius.circular(4.0),
    );

    // Subtle dark translucent background
    final bgPaint = Paint()
      ..color = AppColors.obsidianVoid.withValues(alpha: 0.65)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rrect, bgPaint);

    final fillPaint = Paint()
      ..color = accentColor.withValues(alpha: bgAlpha)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rrect, fillPaint);

    // Tactical corner bracket accents
    final borderPaint = Paint()
      ..color = accentColor.withValues(alpha: borderAlpha)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const bLen = 8.0;
    // Top-left
    canvas.drawLine(Offset.zero, const Offset(bLen, 0), borderPaint);
    canvas.drawLine(Offset.zero, const Offset(0, bLen), borderPaint);

    // Top-right
    canvas.drawLine(Offset(size.x, 0), Offset(size.x - bLen, 0), borderPaint);
    canvas.drawLine(Offset(size.x, 0), Offset(size.x, bLen), borderPaint);

    // Bottom-left
    canvas.drawLine(Offset(0, size.y), Offset(bLen, size.y), borderPaint);
    canvas.drawLine(Offset(0, size.y), Offset(0, size.y - bLen), borderPaint);

    // Bottom-right
    canvas.drawLine(
      Offset(size.x, size.y),
      Offset(size.x - bLen, size.y),
      borderPaint,
    );
    canvas.drawLine(
      Offset(size.x, size.y),
      Offset(size.x, size.y - bLen),
      borderPaint,
    );

    // Draw Title
    _titlePaint.render(
      canvas,
      title,
      Vector2(size.x / 2, subtitle.isNotEmpty ? 12.0 : 20.0),
      anchor: Anchor.center,
    );

    // Draw Subtitle
    if (subtitle.isNotEmpty) {
      _subtitlePaint.render(
        canvas,
        subtitle,
        Vector2(size.x / 2, 26.0),
        anchor: Anchor.center,
      );
    }
  }
}
