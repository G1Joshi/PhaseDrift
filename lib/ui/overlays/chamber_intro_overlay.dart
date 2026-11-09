import 'package:material_ui/material_ui.dart';

import '../../core/theme/theme.dart';
import '../../game/levels/chamber_definition.dart';
import '../hud/split_stopwatch.dart';

class ChamberIntroOverlay extends StatefulWidget {
  const ChamberIntroOverlay({super.key, required this.chamber});

  final ChamberDefinition chamber;

  @override
  State<ChamberIntroOverlay> createState() => _ChamberIntroOverlayState();
}

class _ChamberIntroOverlayState extends State<ChamberIntroOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _opacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 25,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 50),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 25,
      ),
    ]).animate(_ctrl);

    _slide = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(0.0, -0.4),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 25,
      ),
      TweenSequenceItem(tween: ConstantTween<Offset>(Offset.zero), weight: 50),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(0.0, -0.2),
        ).chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 25,
      ),
    ]).animate(_ctrl);

    _ctrl.forward().then((_) {
      if (mounted) {
        setState(() => _isFinished = true);
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isFinished) return const SizedBox.shrink();

    final tier = widget.chamber.tier;
    final chamberCode =
        'CHAMBER ${widget.chamber.chamberId.toString().padLeft(2, '0')}';

    return IgnorePointer(
      child: Center(
        child: FadeTransition(
          opacity: _opacity,
          child: SlideTransition(
            position: _slide,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24.0),
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 14.0,
              ),
              decoration: ShapeDecoration(
                color: AppColors.canvasDark.withValues(alpha: 0.90),
                shape: AppDecorations.chamferShape(
                  chamfer: AppDecorations.chamferMd,
                  borderColor: tier.color,
                  borderWidth: 1.5,
                ),
                shadows: [
                  BoxShadow(
                    color: tier.color.withValues(alpha: 0.30),
                    blurRadius: 24.0,
                    spreadRadius: 2.0,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tier.sectorName,
                    style: AppTypography.telemetryLabel.copyWith(
                      color: tier.color,
                      fontSize: 10.0,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    '$chamberCode // ${widget.chamber.name.toUpperCase()}',
                    style: AppTypography.titleChamber.copyWith(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6.0),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 2.0,
                    ),
                    decoration: AppDecorations.hudModule(),
                    child: Text(
                      'TARGET PAR // ${SplitStopwatchView.formatTime(widget.chamber.parTimeMs)}',
                      style: AppTypography.telemetryLabel.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 9.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
