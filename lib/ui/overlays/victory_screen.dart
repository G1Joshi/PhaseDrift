import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/domain/domain.dart';
import '../../core/theme/theme.dart';
import '../controls/chamfer_button.dart';
import '../hud/split_stopwatch.dart';

class VictoryScreen extends StatefulWidget {
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

  @override
  State<VictoryScreen> createState() => _VictoryScreenState();
}

class _VictoryScreenState extends State<VictoryScreen> {
  final FocusNode _focusNode = FocusNode();
  int _focusedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    final hasNext = widget.onNextChamber != null;
    final totalOptions =
        (hasNext ? 1 : 0) + 1 + (widget.onChamberSelect != null ? 1 : 0);

    if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
        event.logicalKey == LogicalKeyboardKey.keyS) {
      setState(() => _focusedIndex = (_focusedIndex + 1) % totalOptions);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
        event.logicalKey == LogicalKeyboardKey.keyW) {
      setState(
        () => _focusedIndex = (_focusedIndex - 1 + totalOptions) % totalOptions,
      );
    } else if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.space) {
      _activateFocused(hasNext);
    } else if (event.logicalKey == LogicalKeyboardKey.keyR) {
      widget.onRetry();
    } else if (event.logicalKey == LogicalKeyboardKey.escape) {
      widget.onChamberSelect?.call();
    }
  }

  void _activateFocused(bool hasNext) {
    if (hasNext) {
      if (_focusedIndex == 0) {
        widget.onNextChamber?.call();
      } else if (_focusedIndex == 1) {
        widget.onRetry();
      } else {
        widget.onChamberSelect?.call();
      }
    } else {
      if (_focusedIndex == 0) {
        widget.onRetry();
      } else {
        widget.onChamberSelect?.call();
      }
    }
  }

  Widget _buildShardPip(int index) {
    final isCollected = (widget.shardsMask & (1 << index)) != 0;
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
    required int index,
    bool isPrimary = false,
    Color? accentColor,
  }) {
    return ChamferButton(
      label: label,
      onTap: () {
        setState(() => _focusedIndex = index);
        onTap();
      },
      isFocused: _focusedIndex == index,
      isPrimary: isPrimary,
      accentColor: accentColor ?? AppColors.solarAmber,
    );
  }

  @override
  Widget build(BuildContext context) {
    final shardCount = ChamberRecord.countShards(widget.shardsMask);

    final rank = ChamberRank.calculate(
      completionTimeMs: widget.clearTimeMs,
      parTimeMs: widget.parTimeMs,
      shardCount: shardCount,
    );

    final chamberCode =
        'CHAMBER ${widget.chamberId.toString().padLeft(2, '0')}';
    final hasNext = widget.onNextChamber != null;

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Stack(
        children: [
          // Backdrop Blur
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
            child: Container(
              color: AppColors.obsidianVoid.withValues(alpha: 0.85),
            ),
          ),

          // Dialog
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420.0),
              child: Container(
                margin: const EdgeInsets.all(24.0),
                padding: const EdgeInsets.all(24.0),
                decoration: ShapeDecoration(
                  color: AppColors.canvasDark,
                  shape: AppDecorations.chamferShape(
                    chamfer: AppDecorations.chamferLg,
                    borderColor: rank.color,
                    borderWidth: 1.5,
                  ),
                  shadows: [
                    BoxShadow(
                      color: rank.color.withValues(alpha: 0.20),
                      blurRadius: 28.0,
                      spreadRadius: 2.0,
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header Status
                      Text(
                        'CHAMBER CONQUERED',
                        style: AppTypography.telemetryLabel.copyWith(
                          color: rank.color,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        '$chamberCode // ${widget.chamberName.toUpperCase()}',
                        style: AppTypography.titleChamber.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 20.0,
                        ),
                      ),
                      const SizedBox(height: 20.0),

                      // Center Rank Badge
                      Container(
                        width: 80.0,
                        height: 80.0,
                        decoration: ShapeDecoration(
                          color: rank.color.withValues(alpha: 0.15),
                          shape: AppDecorations.chamferShape(
                            chamfer: AppDecorations.chamferMd,
                            borderColor: rank.color,
                            borderWidth: 2.0,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            rank.label,
                            style: AppTypography.displayHero.copyWith(
                              fontSize: 48.0,
                              color: rank.color,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        rank.title,
                        style: AppTypography.telemetryLabel.copyWith(
                          color: rank.color,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20.0),

                      // Metrics Telemetry Panel
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: AppDecorations.hudModule(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text(
                                  'CLEAR TIME',
                                  style: AppTypography.telemetryLabel,
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  SplitStopwatchView.formatTime(
                                    widget.clearTimeMs,
                                  ),
                                  style: AppTypography.telemetryValueSm
                                      .copyWith(
                                        color: AppColors.onSurface,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ],
                            ),
                            Container(
                              width: 1.0,
                              height: 32.0,
                              color: AppColors.structuralSeam,
                            ),
                            Column(
                              children: [
                                Text(
                                  'PAR TIME',
                                  style: AppTypography.telemetryLabel,
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  SplitStopwatchView.formatTime(
                                    widget.parTimeMs,
                                  ),
                                  style: AppTypography.telemetryLabel.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: 1.0,
                              height: 32.0,
                              color: AppColors.structuralSeam,
                            ),
                            Column(
                              children: [
                                Text(
                                  'SHARDS',
                                  style: AppTypography.telemetryLabel,
                                ),
                                const SizedBox(height: 4.0),
                                Row(
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
                      if (hasNext) ...[
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
                                        if (widget.nextChamberTier != null) ...[
                                          const SizedBox(width: 6.0),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 4.0,
                                              vertical: 1.0,
                                            ),
                                            decoration: ShapeDecoration(
                                              color:
                                                  (widget.nextChamberTierColor ??
                                                          AppColors.voidCyan)
                                                      .withValues(alpha: 0.15),
                                              shape: AppDecorations.chamferShape(
                                                chamfer:
                                                    AppDecorations.chamferXs,
                                                borderColor:
                                                    widget
                                                        .nextChamberTierColor ??
                                                    AppColors.voidCyan,
                                              ),
                                            ),
                                            child: Text(
                                              widget.nextChamberTier!,
                                              style: AppTypography
                                                  .telemetryLabel
                                                  .copyWith(
                                                    color:
                                                        widget
                                                            .nextChamberTierColor ??
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
                                      widget.nextChamberName ??
                                          'SECTOR ${(widget.chamberId + 1).toString().padLeft(2, '0')}',
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
                              if (widget.nextParTimeMs != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                    vertical: 3.0,
                                  ),
                                  decoration: AppDecorations.hudModule(),
                                  child: Text(
                                    'PAR ${SplitStopwatchView.formatTime(widget.nextParTimeMs!)}',
                                    style: AppTypography.telemetryLabel
                                        .copyWith(
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
                          onTap: widget.onNextChamber!,
                          index: 0,
                          isPrimary: true,
                          accentColor: rank.color,
                        ),
                      ],
                      _buildButton(
                        label: 'RETRY CHAMBER',
                        onTap: widget.onRetry,
                        index: hasNext ? 1 : 0,
                      ),
                      if (widget.onChamberSelect != null)
                        _buildButton(
                          label: 'CHAMBER SELECT',
                          onTap: widget.onChamberSelect!,
                          index: hasNext ? 2 : 1,
                        ),
                      const SizedBox(height: 12.0),
                      Text(
                        '[R] RETRY  \u2022  [ENTER] CONFIRM  \u2022  [ESC] MATRIX',
                        style: AppTypography.telemetryLabel.copyWith(
                          fontSize: 9.0,
                          color: AppColors.onSurfaceVariant.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
