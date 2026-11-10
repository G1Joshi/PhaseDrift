import 'package:material_ui/material_ui.dart';

import '../../core/domain/domain.dart';
import '../../core/services/services.dart';
import '../../core/theme/theme.dart';
import 'amber_cyan_progress_bar.dart';
import 'phase_indicator.dart';
import 'split_stopwatch.dart';

class TelemetryHud extends StatelessWidget {
  const TelemetryHud({
    super.key,
    required this.chamberName,
    required this.chamberNumber,
    required this.phase,
    required this.elapsedMs,
    this.bestTimeMs,
    this.shardsMask = 0,
    this.velocity = 0.0,
    this.maxVelocity = 200.0,
    this.onPause,
  });

  final String chamberName;
  final int chamberNumber;
  final GamePhase phase;
  final int elapsedMs;
  final int? bestTimeMs;
  final int shardsMask;
  final double velocity;
  final double maxVelocity;
  final VoidCallback? onPause;

  Widget _buildShardPip(int index) {
    final isCollected = (shardsMask & (1 << index)) != 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: Icon(
        Icons.diamond,
        size: 14.0,
        color: isCollected ? AppColors.chronoShard : AppColors.structuralSeam,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final speedRatio = maxVelocity > 0 ? (velocity.abs() / maxVelocity) : 0.0;
    final chamberCode = 'CHAMBER ${chamberNumber.toString().padLeft(2, '0')}';
    final size = MediaQuery.sizeOf(context);
    final isCompact = size.height <= 480.0 || size.width < 720.0;
    final showCenterGauge = size.width >= 640.0;

    return Align(
      alignment: Alignment.topCenter,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 12.0 : 16.0,
            vertical: isCompact ? 8.0 : 12.0,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top-Left: Chamber badge and Phase Indicator
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isCompact ? 180.0 : 260.0,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      decoration: AppDecorations.hudModule(),
                      child: Text(
                        '$chamberCode // ${chamberName.toUpperCase()}',
                        style: AppTypography.telemetryLabel.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6.0),
                  PhaseIndicator(phase: phase, compact: true),
                ],
              ),

              // Top-Center: Velocity Gauge (hidden on narrow screens to prevent crowding)
              if (showCenterGauge)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'VELOCITY // ${velocity.abs().toStringAsFixed(0)} PX/S',
                      style: AppTypography.telemetryLabel,
                    ),
                    const SizedBox(height: 4.0),
                    AmberCyanProgressBar(
                      value: speedRatio,
                      width: isCompact ? 110.0 : 140.0,
                      height: 6.0,
                    ),
                  ],
                ),

              // Top-Right: Shards, Stopwatch, Pause Button
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 42.0,
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    margin: const EdgeInsets.only(right: 8.0),
                    decoration: AppDecorations.hudModule(),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildShardPip(0),
                        _buildShardPip(1),
                        _buildShardPip(2),
                      ],
                    ),
                  ),
                  SplitStopwatchView(
                    elapsedMs: elapsedMs,
                    bestTimeMs: bestTimeMs,
                  ),
                  if (onPause != null) ...[
                    const SizedBox(width: 8.0),
                    Tooltip(
                      message: 'Pause [Esc]',
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            HapticsService.instance.triggerTouchDown();
                            onPause!();
                          },
                          customBorder: AppDecorations.chamferShape(
                            chamfer: AppDecorations.chamferSm,
                          ),
                          child: Container(
                            width: 42.0,
                            height: 42.0,
                            decoration: ShapeDecoration(
                              color: AppColors.interactiveModule,
                              shape: AppDecorations.chamferShape(
                                chamfer: AppDecorations.chamferSm,
                                borderColor: AppColors.structuralSeam,
                              ),
                            ),
                            child: const Icon(
                              Icons.pause,
                              color: AppColors.onSurface,
                              size: 18.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
