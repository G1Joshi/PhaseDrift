import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/audio/audio.dart';
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

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
        event.logicalKey == LogicalKeyboardKey.keyS) {
      setState(() => _focusedIndex = (_focusedIndex + 1) % 4);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
        event.logicalKey == LogicalKeyboardKey.keyW) {
      setState(() => _focusedIndex = (_focusedIndex - 1 + 4) % 4);
    } else if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.space) {
      _activateFocused();
    } else if (event.logicalKey == LogicalKeyboardKey.keyM) {
      MilestonesDialog.show(context);
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
        MilestonesDialog.show(context);
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
      padding: const EdgeInsets.symmetric(vertical: 13.0),
      fontSize: 13.5,
    );
  }

  @override
  Widget build(BuildContext context) {
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
            child: Center(
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
                      // Top Bar: Version & Mute
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 3.0,
                            ),
                            decoration: AppDecorations.hudModule(),
                            child: Text(
                              'v0.1.0 // STABLE',
                              style: AppTypography.telemetryLabel.copyWith(
                                fontSize: 9.0,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              _audio.isMuted
                                  ? Icons.volume_off
                                  : Icons.volume_up,
                              color: _audio.isMuted
                                  ? AppColors.hazardRed
                                  : AppColors.onSurfaceVariant,
                              size: 20.0,
                            ),
                            onPressed: () {
                              setState(() => _audio.toggleMute());
                            },
                          ),
                        ],
                      ),

                      // Center Hero: Logo, Title & Tagline
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Dual Reality Monogram Icon
                          Container(
                            width: 64.0,
                            height: 64.0,
                            decoration: ShapeDecoration(
                              color: AppColors.cardSurface,
                              shape: AppDecorations.chamferShape(
                                chamfer: AppDecorations.chamferMd,
                                borderColor: AppColors.border,
                              ),
                              shadows: [
                                BoxShadow(
                                  color: AppColors.voidCyan.withValues(
                                    alpha: 0.2,
                                  ),
                                  blurRadius: 24.0,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                Icons.change_circle,
                                size: 38.0,
                                color: AppColors.solarAmber,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20.0),

                          // Title
                          Text(
                            'PHASEDRIFT',
                            style: AppTypography.displayHero.copyWith(
                              fontSize: 44.0,
                              letterSpacing: -1.0,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 6.0),

                          // Tagline
                          Text(
                            'TWO REALITIES. ONE MOMENTUM.',
                            style: AppTypography.telemetryLabel.copyWith(
                              color: AppColors.voidCyan,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2.0,
                            ),
                          ),
                          const SizedBox(height: 16.0),

                          // Signature Handover Accent Line
                          const AmberCyanProgressBar(
                            value: 1.0,
                            height: 3.0,
                            width: 180.0,
                            showGlint: false,
                          ),
                        ],
                      ),

                      // Actions Menu
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildMenuButton(
                            label: 'ENTER THE DRIFT',
                            onTap: widget.onStartGame,
                            index: 0,
                            isPrimary: true,
                          ),
                          _buildMenuButton(
                            label: 'CHAMBER MATRIX',
                            onTap: widget.onOpenChamberSelect,
                            index: 1,
                          ),
                          _buildMenuButton(
                            label: 'TACTICAL MILESTONES',
                            onTap: () => MilestonesDialog.show(context),
                            index: 2,
                          ),
                          _buildMenuButton(
                            label: 'SYSTEM SETTINGS',
                            onTap: widget.onOpenSettings,
                            index: 3,
                          ),
                          const SizedBox(height: 14.0),

                          // Tactical Copyright & Key Hints
                          Text(
                            '[WASD / ARROWS] NAVIGATE  \u2022  [SPACE/ENTER] SELECT  \u2022  [M] BADGES',
                            style: AppTypography.telemetryLabel.copyWith(
                              fontSize: 8.5,
                              color: AppColors.onSurfaceVariant.withValues(
                                alpha: 0.7,
                              ),
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
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
