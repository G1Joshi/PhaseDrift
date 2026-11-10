import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/domain/domain.dart';
import '../../core/services/services.dart';
import '../../core/theme/theme.dart';
import '../controls/chamfer_button.dart';

class PauseMenu extends StatefulWidget {
  const PauseMenu({
    super.key,
    required this.onResume,
    required this.onRestart,
    this.onSettings,
    this.onQuit,
    this.phase = const SolarPhase(),
    this.chamberName = 'AWAKENING',
    this.chamberNumber = 1,
  });

  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback? onSettings;
  final VoidCallback? onQuit;
  final GamePhase phase;
  final String chamberName;
  final int chamberNumber;

  @override
  State<PauseMenu> createState() => _PauseMenuState();
}

class _PauseMenuState extends State<PauseMenu> {
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

    final totalOptions =
        2 +
        (widget.onSettings != null ? 1 : 0) +
        (widget.onQuit != null ? 1 : 0);

    if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
        event.logicalKey == LogicalKeyboardKey.keyS) {
      setState(() => _focusedIndex = (_focusedIndex + 1) % totalOptions);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
        event.logicalKey == LogicalKeyboardKey.keyW) {
      setState(
        () => _focusedIndex = (_focusedIndex - 1 + totalOptions) % totalOptions,
      );
    } else if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.space ||
        event.logicalKey == LogicalKeyboardKey.gameButtonA) {
      _activateFocused();
    } else if (event.logicalKey == LogicalKeyboardKey.escape ||
        event.logicalKey == LogicalKeyboardKey.keyP ||
        event.logicalKey == LogicalKeyboardKey.gameButtonStart ||
        event.logicalKey == LogicalKeyboardKey.gameButtonB) {
      widget.onResume();
    } else if (event.logicalKey == LogicalKeyboardKey.keyR ||
        event.logicalKey == LogicalKeyboardKey.gameButtonSelect) {
      widget.onRestart();
    }
  }

  void _activateFocused() {
    switch (_focusedIndex) {
      case 0:
        widget.onResume();
        break;
      case 1:
        widget.onRestart();
        break;
      case 2:
        if (widget.onSettings != null) {
          widget.onSettings!();
        } else if (widget.onQuit != null) {
          widget.onQuit!();
        }
        break;
      case 3:
        widget.onQuit?.call();
        break;
    }
  }

  Widget _buildMenuButton({
    required String label,
    required VoidCallback onTap,
    required int index,
    bool isPrimary = false,
    EdgeInsetsGeometry? padding,
    double? fontSize,
  }) {
    return ChamferButton(
      label: label,
      onTap: () {
        setState(() => _focusedIndex = index);
        onTap();
      },
      isFocused: _focusedIndex == index,
      isPrimary: isPrimary,
      accentColor: widget.phase.primaryColor,
      padding: padding ?? const EdgeInsets.symmetric(vertical: 12.0),
      fontSize: fontSize ?? 13.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final chamberCode =
        'CHAMBER ${widget.chamberNumber.toString().padLeft(2, '0')}';
    final phaseColor = widget.phase.primaryColor;
    final size = MediaQuery.sizeOf(context);
    final isCompact = size.height <= 480.0 && size.width > size.height;

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Stack(
        children: [
          // Backdrop Blur & Dim
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
            child: Container(
              color: AppColors.obsidianVoid.withValues(alpha: 0.75),
            ),
          ),

          // Centered Dialog
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 340.0),
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: isCompact ? 10.0 : 24.0,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: isCompact ? 12.0 : 24.0,
                ),
                decoration: ShapeDecoration(
                  color: AppColors.canvasDark,
                  shape: AppDecorations.chamferShape(
                    chamfer: AppDecorations.chamferMd,
                    borderColor: phaseColor,
                    borderWidth: 1.5,
                  ),
                  shadows: [
                    BoxShadow(
                      color: phaseColor.withValues(alpha: 0.15),
                      blurRadius: 24.0,
                      spreadRadius: 2.0,
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'SYSTEM PAUSED',
                        style: AppTypography.sectionHeader.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          fontSize: isCompact ? 15.0 : 17.0,
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        '$chamberCode // ${widget.chamberName.toUpperCase()}',
                        style: AppTypography.telemetryLabel.copyWith(
                          color: phaseColor,
                          fontWeight: FontWeight.w600,
                          fontSize: isCompact ? 9.0 : 10.0,
                        ),
                      ),
                      SizedBox(height: isCompact ? 10.0 : 20.0),
                      _buildMenuButton(
                        label: 'RESUME',
                        onTap: widget.onResume,
                        index: 0,
                        isPrimary: true,
                        padding: EdgeInsets.symmetric(
                          vertical: isCompact ? 9.0 : 12.0,
                        ),
                        fontSize: isCompact ? 12.5 : 13.0,
                      ),
                      if (isCompact) ...[
                        Row(
                          children: [
                            Expanded(
                              child: _buildMenuButton(
                                label: 'RESTART',
                                onTap: widget.onRestart,
                                index: 1,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                fontSize: 11.5,
                              ),
                            ),
                            if (widget.onSettings != null) ...[
                              const SizedBox(width: 8.0),
                              Expanded(
                                child: _buildMenuButton(
                                  label: 'SETTINGS',
                                  onTap: widget.onSettings!,
                                  index: 2,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8.0,
                                  ),
                                  fontSize: 11.5,
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (widget.onQuit != null)
                          _buildMenuButton(
                            label: 'CHAMBER MATRIX',
                            onTap: widget.onQuit!,
                            index: widget.onSettings != null ? 3 : 2,
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            fontSize: 11.5,
                          ),
                      ] else ...[
                        _buildMenuButton(
                          label: 'RESTART CHAMBER',
                          onTap: widget.onRestart,
                          index: 1,
                        ),
                        if (widget.onSettings != null)
                          _buildMenuButton(
                            label: 'SETTINGS',
                            onTap: widget.onSettings!,
                            index: 2,
                          ),
                        if (widget.onQuit != null)
                          _buildMenuButton(
                            label: 'CHAMBER MATRIX',
                            onTap: widget.onQuit!,
                            index: widget.onSettings != null ? 3 : 2,
                          ),
                      ],
                      SizedBox(height: isCompact ? 8.0 : 16.0),
                      Text(
                        AppPlatform.isTouchDevice(context)
                            ? 'TAP TO SELECT  \u2022  SWIPE TO DISMISS'
                            : '[ESC] RESUME  \u2022  [R] RESTART  \u2022  [ENTER] SELECT',
                        style: AppTypography.telemetryLabel.copyWith(
                          fontSize: 8.5,
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
