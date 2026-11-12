import 'package:flame/components.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/domain/domain.dart';
import '../../../core/theme/theme.dart';
import '../../constants/kinematic_constants.dart';
import '../../phasedrift_game.dart';

class GhostReplayComponent extends PositionComponent
    with HasGameReference<PhaseDriftGame> {
  GhostReplayComponent({required this.ghostRun})
    : super(
        size: Vector2(
          KinematicConstants.playerWidth,
          KinematicConstants.playerHeight,
        ),
        anchor: Anchor.center,
        priority: -2,
      );

  final GhostRun ghostRun;
  static const double sampleInterval = 0.05; // 20 Hz recording

  bool isSolar = true;
  double squishX = 1.0;
  double squishY = 1.0;
  bool isCompleted = false;

  late final TextPaint _labelPaint;
  final Paint _bodyPaint = Paint()..style = PaintingStyle.fill;
  final Paint _rimPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.2;
  final Paint _visorPaint = Paint();

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _labelPaint = TextPaint(
      style: const TextStyle(
        fontFamily: 'JetBrainsMono',
        fontSize: 6.5,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurfaceVariant,
        letterSpacing: 0.5,
      ),
    );
  }

  void reset() {
    isCompleted = false;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!game.isTimerStarted) {
      isCompleted = false;
      return;
    }

    final frameIndex = (game.elapsedTime / sampleInterval).floor();
    if (frameIndex >= 0 && frameIndex < ghostRun.frames.length) {
      final frame = ghostRun.frames[frameIndex];
      position.setValues(frame.x, frame.y);
      isSolar = frame.isSolar;
      squishX = frame.squishX;
      squishY = frame.squishY;
      scale.setValues(squishX, squishY);
      isCompleted = false;
    } else if (frameIndex >= ghostRun.frames.length && !isCompleted) {
      isCompleted = true;
    }
  }

  @override
  void render(Canvas canvas) {
    if (!game.isTimerStarted || isCompleted) return;
    super.render(canvas);

    final color = isSolar ? AppColors.solarAmber : AppColors.voidCyan;

    // 1. Ghost Translucent Body
    _bodyPaint.color = color.withValues(alpha: 0.22);

    // 2. Hologram Scanline Rim
    _rimPaint.color = color.withValues(alpha: 0.65);

    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(3.0));

    canvas.drawRRect(rrect, _bodyPaint);
    canvas.drawRRect(rrect, _rimPaint);

    // 3. Subtle Hologram Visor
    _visorPaint.color = color.withValues(alpha: 0.85);
    final visorY = isSolar ? 4.0 : size.y - 7.0;
    final visorRect = Rect.fromLTWH(2.0, visorY, size.x - 4.0, 2.5);
    canvas.drawRRect(
      RRect.fromRectAndRadius(visorRect, const Radius.circular(1.0)),
      _visorPaint,
    );

    // 4. Floating Holographic Label
    final labelY = isSolar ? -8.0 : size.y + 2.0;
    _labelPaint.render(canvas, 'PB GHOST', Vector2(size.x / 2 - 14.0, labelY));
  }
}
