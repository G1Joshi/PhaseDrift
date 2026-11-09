import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/domain/domain.dart';
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
        event.logicalKey == LogicalKeyboardKey.space) {
      _activateFocused();
    } else if (event.logicalKey == LogicalKeyboardKey.escape ||
        event.logicalKey == LogicalKeyboardKey.keyP) {
      widget.onResume();
    } else if (event.logicalKey == LogicalKeyboardKey.keyR) {
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final chamberCode =
        'CHAMBER ${widget.chamberNumber.toString().padLeft(2, '0')}';
    final phaseColor = widget.phase.primaryColor;

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
                margin: const EdgeInsets.all(24.0),
                padding: const EdgeInsets.all(24.0),
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
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        '$chamberCode // ${widget.chamberName.toUpperCase()}',
                        style: AppTypography.telemetryLabel.copyWith(
                          color: phaseColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      _buildMenuButton(
                        label: 'RESUME',
                        onTap: widget.onResume,
                        index: 0,
                        isPrimary: true,
                      ),
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
                          label: 'MAIN MENU',
                          onTap: widget.onQuit!,
                          index: widget.onSettings != null ? 3 : 2,
                        ),
                      const SizedBox(height: 16.0),
                      Text(
                        '[ESC] RESUME  \u2022  [R] RESTART  \u2022  [ENTER] SELECT',
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
