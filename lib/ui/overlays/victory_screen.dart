import 'dart:ui';

import 'package:flutter/services.dart';
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
    this.nextChamberName,
    this.nextParTimeMs,
    this.nextChamberTier,
    this.nextChamberTierColor,
    this.onNextChamber,
    this.onChamberSelect,
  });

  final int chamberId;
  final String chamberName;
  final int clearTimeMs;
  final int parTimeMs;
  final int shardsMask;
  final String? nextChamberName;
  final int? nextParTimeMs;
  final String? nextChamberTier;
  final Color? nextChamberTierColor;
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

    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.space ||
              event.logicalKey == LogicalKeyboardKey.enter) {
            if (onNextChamber != null) {
              onNextChamber!();
              return KeyEventResult.handled;
            }
          } else if (event.logicalKey == LogicalKeyboardKey.keyR) {
            onRetry();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Stack(
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

                    // Next Sector Telemetry Teaser
                    if (onNextChamber != null) ...[
                      Container(
                        margin: const EdgeInsets.only(bottom: 12.0),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14.0,
                          vertical: 10.0,
                        ),
                        decoration: ShapeDecoration(
                          color: AppColors.canvasDark,
                          shape: AppDecorations.chamferShape(
                            chamfer: AppDecorations.chamferSm,
                            borderColor: AppColors.voidCyan,
                            borderWidth: 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'NEXT',
                                        style: AppTypography.telemetryLabel
                                            .copyWith(
                                              color: AppColors.voidCyan,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 8.5,
                                              letterSpacing: 1.0,
                                            ),
                                      ),
                                      if (nextChamberTier != null) ...[
                                        const SizedBox(width: 6.0),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4.0,
                                            vertical: 1.0,
                                          ),
                                          decoration: ShapeDecoration(
                                            color:
                                                (nextChamberTierColor ??
                                                        AppColors.voidCyan)
                                                    .withValues(alpha: 0.15),
                                            shape: AppDecorations.chamferShape(
                                              chamfer: AppDecorations.chamferXs,
                                              borderColor:
                                                  nextChamberTierColor ??
                                                  AppColors.voidCyan,
                                            ),
                                          ),
                                          child: Text(
                                            nextChamberTier!,
                                            style: AppTypography.telemetryLabel
                                                .copyWith(
                                                  color:
                                                      nextChamberTierColor ??
                                                      AppColors.voidCyan,
                                                  fontSize: 7.5,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 2.0),
                                  Text(
                                    nextChamberName ??
                                        'SECTOR ${(chamberId + 1).toString().padLeft(2, '0')}',
                                    style: AppTypography.button.copyWith(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            if (nextParTimeMs != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 3.0,
                                ),
                                decoration: AppDecorations.hudModule(),
                                child: Text(
                                  'PAR ${SplitStopwatchView.formatTime(nextParTimeMs!)}',
                                  style: AppTypography.telemetryLabel.copyWith(
                                    fontSize: 9.0,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      _buildButton(
                        label: 'WARP TO NEXT SECTOR  \u2192',
                        onTap: onNextChamber!,
                        isPrimary: true,
                        accentColor: rank.color,
                      ),
                    ],
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
      ),
    );
  }
}
