import 'dart:ui';

import 'package:material_ui/material_ui.dart';

import '../../core/domain/domain.dart';
import '../../core/theme/theme.dart';
import '../hud/split_stopwatch.dart';

class VictoryScreen extends StatelessWidget {
  const VictoryScreen({
    super.key,
    required this.chamberId,
    required this.chamberName,
    required this.clearTimeMs,
    required this.parTimeMs,
    required this.shardsMask,
    required this.onRetry,
    this.onNextChamber,
    this.onChamberSelect,
  });

  final int chamberId;
  final String chamberName;
  final int clearTimeMs;
  final int parTimeMs;
  final int shardsMask;
  final VoidCallback onRetry;
  final VoidCallback? onNextChamber;
  final VoidCallback? onChamberSelect;

  Widget _buildShardPip(int index) {
    final isCollected = (shardsMask & (1 << index)) != 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Icon(
        Icons.diamond,
        size: 18.0,
        color: isCollected ? AppColors.chronoShard : AppColors.structuralSeam,
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
    Color? accentColor,
  }) {
    final color = accentColor ?? AppColors.solarAmber;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: AppDecorations.chamferShape(
            chamfer: AppDecorations.chamferSm,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            decoration: ShapeDecoration(
              color: isPrimary ? color : AppColors.interactiveModule,
              shape: AppDecorations.chamferShape(
                chamfer: AppDecorations.chamferSm,
                borderColor: isPrimary ? color : AppColors.structuralSeam,
              ),
            ),
            child: Center(
              child: Text(
                label,
                style: AppTypography.button.copyWith(
                  color: isPrimary
                      ? AppColors.obsidianVoid
                      : AppColors.onSurface,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var shardCount = 0;
    var mask = shardsMask;
    while (mask > 0) {
      shardCount += mask & 1;
      mask >>= 1;
    }

    final rank = ChamberRank.calculate(
      completionTimeMs: clearTimeMs,
      parTimeMs: parTimeMs,
      shardCount: shardCount,
    );

    final delta = clearTimeMs - parTimeMs;
    final deltaText = SplitStopwatchView.formatDelta(delta);
    final deltaColor = delta <= 0
        ? AppColors.successGreen
        : AppColors.hazardRed;

    final chamberCode = 'CHAMBER ${chamberId.toString().padLeft(2, '0')}';

    return Stack(
      children: [
        // Backdrop Blur
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
          child: Container(
            color: AppColors.obsidianVoid.withValues(alpha: 0.80),
          ),
        ),

        // Centered Victory Card
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380.0),
            child: Container(
              margin: const EdgeInsets.all(24.0),
              padding: const EdgeInsets.all(24.0),
              decoration: ShapeDecoration(
                color: AppColors.canvasDark,
                shape: AppDecorations.chamferShape(
                  chamfer: AppDecorations.chamferMd,
                  borderColor: rank.color,
                  borderWidth: 1.5,
                ),
                shadows: [
                  BoxShadow(
                    color: rank.color.withValues(alpha: 0.20),
                    blurRadius: 30.0,
                    spreadRadius: 2.0,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Text(
                    'CHAMBER COMPLETE',
                    style: AppTypography.sectionHeader.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    '$chamberCode // ${chamberName.toUpperCase()}',
                    style: AppTypography.telemetryLabel.copyWith(
                      color: rank.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Rank Badge
                  Container(
                    width: 90.0,
                    height: 90.0,
                    decoration: ShapeDecoration(
                      color: AppColors.interactiveModule,
                      shape: AppDecorations.chamferShape(
                        chamfer: AppDecorations.chamferMd,
                        borderColor: rank.color,
                        borderWidth: 2.0,
                      ),
                      shadows: [
                        BoxShadow(
                          color: rank.color.withValues(alpha: 0.35),
                          blurRadius: 16.0,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          rank.label,
                          style: AppTypography.displayHero.copyWith(
                            fontSize: 48.0,
                            color: rank.color,
                            height: 1.0,
                          ),
                        ),
                        Text(
                          rank.title,
                          style: AppTypography.telemetryLabel.copyWith(
                            fontSize: 8.0,
                            letterSpacing: 0.8,
                            color: rank.color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20.0),

                  // Telemetry Split Box
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: AppDecorations.hudModule(),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'CLEAR TIME',
                              style: AppTypography.telemetryLabel,
                            ),
                            Text(
                              SplitStopwatchView.formatTime(clearTimeMs),
                              style: AppTypography.telemetryValueSm,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'PAR TIME',
                              style: AppTypography.telemetryLabel,
                            ),
                            Text(
                              SplitStopwatchView.formatTime(parTimeMs),
                              style: AppTypography.telemetryLabel.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'SPLIT DELTA',
                              style: AppTypography.telemetryLabel,
                            ),
                            Text(
                              deltaText,
                              style: AppTypography.telemetryValueSm.copyWith(
                                color: deltaColor,
                              ),
                            ),
                          ],
                        ),
                        const Divider(
                          color: AppColors.structuralSeam,
                          height: 16.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'CHRONO-SHARDS',
                              style: AppTypography.telemetryLabel,
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildShardPip(0),
                                _buildShardPip(1),
                                _buildShardPip(2),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20.0),

                  // Actions
                  if (onNextChamber != null)
                    _buildButton(
                      label: 'NEXT CHAMBER',
                      onTap: onNextChamber!,
                      isPrimary: true,
                      accentColor: rank.color,
                    ),
                  _buildButton(label: 'RETRY CHAMBER', onTap: onRetry),
                  if (onChamberSelect != null)
                    _buildButton(
                      label: 'CHAMBER SELECT',
                      onTap: onChamberSelect!,
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
