import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/audio/audio.dart';
import '../../core/services/services.dart';
import '../../core/theme/theme.dart';
import '../controls/chamfer_button.dart';
import '../hud/amber_cyan_progress_bar.dart';
import '../overlays/milestones_dialog.dart';

class TitleScreen extends StatefulWidget {
  const TitleScreen({
    super.key,
    required this.onStartGame,
    required this.onOpenChamberSelect,
    required this.onOpenSettings,
  });

  final VoidCallback onStartGame;
  final VoidCallback onOpenChamberSelect;
  final VoidCallback onOpenSettings;

  @override
  State<TitleScreen> createState() => _TitleScreenState();
}

class _TitleScreenState extends State<TitleScreen> {
  final AudioEngine _audio = AudioEngine.instance;
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

  void _ensureAudioStarted() {
    if (!_audio.isPlaying) {
      _audio.startMusic();
    }
  }

  void _openMilestones() {
    MilestonesDialog.show(context).then((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
        event.logicalKey == LogicalKeyboardKey.keyS) {
      setState(() => _focusedIndex = (_focusedIndex + 1) % 4);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
        event.logicalKey == LogicalKeyboardKey.keyW) {
      setState(() => _focusedIndex = (_focusedIndex - 1 + 4) % 4);
    } else if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.space ||
        event.logicalKey == LogicalKeyboardKey.gameButtonA ||
        event.logicalKey == LogicalKeyboardKey.gameButtonStart) {
      _activateFocused();
    } else if (event.logicalKey == LogicalKeyboardKey.keyM) {
      _openMilestones();
    }
  }

  void _activateFocused() {
    _ensureAudioStarted();
    switch (_focusedIndex) {
      case 0:
        widget.onStartGame();
        break;
      case 1:
        widget.onOpenChamberSelect();
        break;
      case 2:
        _openMilestones();
        break;
      case 3:
        widget.onOpenSettings();
        break;
    }
  }

  Widget _buildMenuButton({
    required String label,
    required VoidCallback onTap,
    required int index,
    bool isPrimary = false,
    bool compact = false,
  }) {
    return ChamferButton(
      label: label,
      onTap: () {
        setState(() => _focusedIndex = index);
        _ensureAudioStarted();
        onTap();
      },
      isFocused: _focusedIndex == index,
      isPrimary: isPrimary,
      padding: EdgeInsets.symmetric(
        vertical: compact ? 10.0 : 13.0,
        horizontal: 16.0,
      ),
      minHeight: compact ? 44.0 : 48.0,
      fontSize: compact ? 12.5 : 14.0,
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9.0, vertical: 4.0),
          decoration: AppDecorations.hudModule(),
          child: Text(
            'v0.1.0 // STABLE',
            style: AppTypography.telemetryLabel.copyWith(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
        IconButton(
          constraints: const BoxConstraints(minWidth: 44.0, minHeight: 44.0),
          icon: Icon(
            _audio.isMuted ? Icons.volume_off : Icons.volume_up,
            color: _audio.isMuted
                ? AppColors.hazardRed
                : AppColors.onSurfaceVariant,
            size: 22.0,
          ),
          onPressed: () {
            HapticsService.instance.triggerClick();
            setState(() => _audio.toggleMute());
          },
        ),
      ],
    );
  }

  Widget _buildBrandLogo({bool compact = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Dual Reality Monogram Icon
        Container(
          width: compact ? 52.0 : 68.0,
          height: compact ? 52.0 : 68.0,
          decoration: ShapeDecoration(
            color: AppColors.cardSurface,
            shape: AppDecorations.chamferShape(
              chamfer: compact
                  ? AppDecorations.chamferSm
                  : AppDecorations.chamferMd,
              borderColor: AppColors.border,
            ),
            shadows: [
              BoxShadow(
                color: AppColors.voidCyan.withValues(alpha: 0.25),
                blurRadius: compact ? 18.0 : 26.0,
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.change_circle,
              size: compact ? 30.0 : 42.0,
              color: AppColors.solarAmber,
            ),
          ),
        ),
        SizedBox(height: compact ? 10.0 : 20.0),

        // Title
        Text(
          'PHASEDRIFT',
          style: AppTypography.displayHero.copyWith(
            fontSize: compact ? 32.0 : 46.0,
            letterSpacing: -1.0,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4.0),

        // Tagline
        Text(
          'TWO REALITIES. ONE MOMENTUM.',
          style: AppTypography.telemetryLabel.copyWith(
            color: AppColors.voidCyan,
            fontWeight: FontWeight.w700,
            letterSpacing: compact ? 1.6 : 2.2,
            fontSize: compact ? 9.0 : 10.5,
          ),
        ),
        SizedBox(height: compact ? 10.0 : 16.0),

        // Signature Handover Accent Line
        AmberCyanProgressBar(
          value: 1.0,
          height: compact ? 3.0 : 3.5,
          width: compact ? 150.0 : 200.0,
          showGlint: false,
        ),
      ],
    );
  }

  Widget _buildMenuColumn({bool compact = false, required bool isTouch}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildMenuButton(
          label: 'ENTER THE DRIFT',
          onTap: widget.onStartGame,
          index: 0,
          isPrimary: true,
          compact: compact,
        ),
        _buildMenuButton(
          label: 'CHAMBER MATRIX',
          onTap: widget.onOpenChamberSelect,
          index: 1,
          compact: compact,
        ),
        _buildMenuButton(
          label: 'TACTICAL MILESTONES',
          onTap: _openMilestones,
          index: 2,
          compact: compact,
        ),
        _buildMenuButton(
          label: 'SYSTEM SETTINGS',
          onTap: widget.onOpenSettings,
          index: 3,
          compact: compact,
        ),
        SizedBox(height: compact ? 8.0 : 14.0),

        // Tactical Copyright & Key / Touch Hints
        Text(
          isTouch ? 'TAP TO ENTER  \u2022  DRAG TO EXPLORE' : '[WASD / ARROWS] NAVIGATE  \u2022  [SPACE/ENTER] SELECT  \u2022  [M] BADGES',
          style: AppTypography.telemetryLabel.copyWith(
            fontSize: 9.0,
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.75),
            letterSpacing: 1.2,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isLandscape = size.width > size.height;
    final isCompactLandscape = isLandscape && size.height <= 520.0;
    final isTouch = AppPlatform.isTouchDevice(context);

    final viewPadding = MediaQuery.viewPaddingOf(context);
    final safeLeft = math.max(
      viewPadding.left,
      isCompactLandscape ? 20.0 : 28.0,
    );
    final safeRight = math.max(
      viewPadding.right,
      isCompactLandscape ? 20.0 : 28.0,
    );

    return Scaffold(
      backgroundColor: AppColors.obsidianVoid,
      body: KeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: _handleKeyEvent,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTapDown: (_) => _ensureAudioStarted(),
          child: SafeArea(
            child: isLandscape
                ? Padding(
                    padding: EdgeInsets.only(
                      left: safeLeft,
                      right: safeRight,
                      top: 8.0,
                      bottom: 12.0,
                    ),
                    child: Column(
                      children: [
                        _buildTopBar(),
                        const SizedBox(height: 6.0),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                flex: 5,
                                child: Center(
                                  child: _buildBrandLogo(
                                    compact: isCompactLandscape,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 24.0),
                              Expanded(
                                flex: 6,
                                child: Center(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 360.0,
                                    ),
                                    child: _buildMenuColumn(
                                      compact: isCompactLandscape,
                                      isTouch: isTouch,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420.0),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 24.0,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildTopBar(),
                            _buildBrandLogo(compact: false),
                            _buildMenuColumn(compact: false, isTouch: isTouch),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
