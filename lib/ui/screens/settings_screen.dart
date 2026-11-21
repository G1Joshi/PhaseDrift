import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/audio/audio.dart';
import '../../core/services/services.dart';
import '../../core/theme/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    this.onBack,
    this.reduceMotion = false,
    this.onReduceMotionChanged,
    this.touchOpacity = 0.85,
    this.onTouchOpacityChanged,
    this.touchScale = 1.0,
    this.onTouchScaleChanged,
    this.southpaw = false,
    this.onSouthpawChanged,
  });

  final VoidCallback? onBack;
  final bool reduceMotion;
  final ValueChanged<bool>? onReduceMotionChanged;
  final double touchOpacity;
  final ValueChanged<double>? onTouchOpacityChanged;
  final double touchScale;
  final ValueChanged<double>? onTouchScaleChanged;
  final bool southpaw;
  final ValueChanged<bool>? onSouthpawChanged;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AudioEngine _audio = AudioEngine.instance;
  final HapticsService _haptics = HapticsService.instance;
  final PersistenceService _persistence = PersistenceService.instance;
  final FocusNode _focusNode = FocusNode();

  late double _masterVol;
  late double _musicVol;
  late double _sfxVol;
  late bool _isMuted;
  late bool _hapticsEnabled;
  late bool _reduceMotion;
  late bool _ghostEnabled;
  late double _touchOpacity;
  late double _touchScale;
  late bool _southpaw;

  @override
  void initState() {
    super.initState();
    _masterVol = _audio.masterVolume;
    _musicVol = _audio.musicVolume;
    _sfxVol = _audio.sfxVolume;
    _isMuted = _audio.isMuted;
    _hapticsEnabled = _haptics.isEnabled;
    _reduceMotion = widget.reduceMotion;
    _ghostEnabled = _persistence.getGhostEnabled();
    final (opacity, scale, southpaw) = _persistence.getTouchSettings();
    _touchOpacity = opacity;
    _touchScale = scale;
    _southpaw = southpaw;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  void _saveTouchSettings() {
    _persistence.saveTouchSettings(
      opacity: _touchOpacity,
      scale: _touchScale,
      southpaw: _southpaw,
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _saveAudio() {
    _persistence.saveAudioSettings(
      master: _masterVol,
      music: _musicVol,
      sfx: _sfxVol,
      muted: _isMuted,
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 18.0, bottom: 8.0),
      child: Text(
        title,
        style: AppTypography.telemetryLabel.copyWith(
          color: AppColors.solarAmber,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
          fontSize: 11.5,
        ),
      ),
    );
  }

  Widget _buildSliderRow({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
      constraints: const BoxConstraints(minHeight: 48.0),
      decoration: AppDecorations.hudModule(),
      child: Row(
        children: [
          SizedBox(
            width: 105.0,
            child: Text(
              label,
              style: AppTypography.telemetryLabel.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: const SliderThemeData(
                activeTrackColor: AppColors.solarAmber,
                inactiveTrackColor: AppColors.structuralSeam,
                thumbColor: AppColors.solarGold,
                trackHeight: 4.0,
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.0),
                overlayShape: RoundSliderOverlayShape(overlayRadius: 18.0),
              ),
              child: Slider(
                value: value,
                min: 0.0,
                max: 1.0,
                onChanged: onChanged,
              ),
            ),
          ),
          SizedBox(
            width: 46.0,
            child: Text(
              '${(value * 100).toInt()}%',
              textAlign: TextAlign.end,
              style: AppTypography.telemetryValueSm.copyWith(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow({
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      constraints: const BoxConstraints(minHeight: 52.0),
      decoration: AppDecorations.hudModule(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppTypography.button.copyWith(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  subtitle,
                  style: AppTypography.telemetryLabel.copyWith(
                    fontSize: 10.5,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12.0),
          Switch(
            value: value,
            activeThumbColor: AppColors.solarAmber,
            activeTrackColor: AppColors.solarAmber.withValues(alpha: 0.45),
            inactiveTrackColor: AppColors.structuralSeam,
            onChanged: (val) {
              HapticsService.instance.triggerClick();
              onChanged(val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildScaleChip(String label, double scaleVal) {
    final isSelected = (_touchScale - scaleVal).abs() < 0.05;
    return InkWell(
      onTap: () {
        HapticsService.instance.triggerClick();
        setState(() => _touchScale = scaleVal);
        _saveTouchSettings();
        widget.onTouchScaleChanged?.call(scaleVal);
      },
      child: Container(
        constraints: const BoxConstraints(minHeight: 36.0, minWidth: 50.0),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        alignment: Alignment.center,
        decoration: ShapeDecoration(
          color: isSelected
              ? AppColors.solarAmber.withValues(alpha: 0.25)
              : AppColors.canvasDark,
          shape: AppDecorations.chamferShape(
            chamfer: AppDecorations.chamferXs,
            borderColor: isSelected
                ? AppColors.solarAmber
                : AppColors.structuralSeam,
            borderWidth: isSelected ? 1.8 : 1.0,
          ),
          shadows: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.solarAmber.withValues(alpha: 0.35),
                    blurRadius: 10.0,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: AppTypography.telemetryLabel.copyWith(
            color: isSelected
                ? AppColors.solarAmber
                : AppColors.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            fontSize: 10.5,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final safeLeft = math.max(viewPadding.left, 20.0);
    final safeRight = math.max(viewPadding.right, 20.0);

    return Scaffold(
      backgroundColor: AppColors.obsidianVoid,
      body: KeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: (event) {
          if (event is KeyDownEvent &&
              (event.logicalKey == LogicalKeyboardKey.escape ||
                  event.logicalKey == LogicalKeyboardKey.backspace ||
                  event.logicalKey == LogicalKeyboardKey.gameButtonB)) {
            widget.onBack?.call();
          }
        },
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 580.0),
              child: Padding(
                padding: EdgeInsets.only(
                  left: safeLeft,
                  right: safeRight,
                  top: 10.0,
                  bottom: 12.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Navigation Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (widget.onBack != null)
                          IconButton(
                            iconSize: 26.0,
                            padding: const EdgeInsets.all(8.0),
                            constraints: const BoxConstraints(
                              minWidth: 48.0,
                              minHeight: 48.0,
                            ),
                            icon: const Icon(
                              Icons.arrow_back,
                              color: AppColors.onSurface,
                            ),
                            onPressed: () {
                              HapticsService.instance.triggerClick();
                              widget.onBack?.call();
                            },
                          )
                        else
                          const SizedBox(width: 48.0),
                        Expanded(
                          child: Text(
                            'SYSTEM SETTINGS',
                            textAlign: TextAlign.center,
                            style: AppTypography.sectionHeader.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2.0,
                              fontSize: 17.0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48.0),
                      ],
                    ),
                    const SizedBox(height: 8.0),

                    Expanded(
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        children: [
                          // Audio Section
                          _buildSectionHeader('AUDIO TELEMETRY'),
                          _buildSliderRow(
                            label: 'MASTER',
                            value: _masterVol,
                            onChanged: (val) {
                              setState(() => _masterVol = val);
                              _audio.setMasterVolume(val);
                              _saveAudio();
                            },
                          ),
                          _buildSliderRow(
                            label: 'MUSIC',
                            value: _musicVol,
                            onChanged: (val) {
                              setState(() => _musicVol = val);
                              _audio.setMusicVolume(val);
                              _saveAudio();
                            },
                          ),
                          _buildSliderRow(
                            label: 'SFX',
                            value: _sfxVol,
                            onChanged: (val) {
                              setState(() => _sfxVol = val);
                              _audio.setSfxVolume(val);
                              _saveAudio();
                            },
                          ),
                          _buildToggleRow(
                            label: 'MUTE ALL AUDIO',
                            subtitle:
                                'Instantly silences stems and sound effects',
                            value: _isMuted,
                            onChanged: (val) {
                              setState(() => _isMuted = val);
                              _audio.toggleMute();
                              _saveAudio();
                            },
                          ),

                          // Haptics Section
                          _buildSectionHeader('TACTILE FEEDBACK'),
                          _buildToggleRow(
                            label: 'HAPTIC VIBRATION',
                            subtitle: 'Tactile pulses on jump, land, and shift',
                            value: _hapticsEnabled,
                            onChanged: (val) {
                              setState(() => _hapticsEnabled = val);
                              _haptics.isEnabled = val;
                              _persistence.saveHapticsEnabled(val);
                            },
                          ),

                          // Mobile Touch Controls Section
                          _buildSectionHeader('MOBILE TOUCH CONTROLS'),
                          _buildSliderRow(
                            label: 'TOUCH OPACITY',
                            value: _touchOpacity,
                            onChanged: (val) {
                              setState(
                                () => _touchOpacity = val.clamp(0.2, 1.0),
                              );
                              _saveTouchSettings();
                              widget.onTouchOpacityChanged?.call(_touchOpacity);
                            },
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 4.0),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14.0,
                              vertical: 12.0,
                            ),
                            constraints: const BoxConstraints(minHeight: 52.0),
                            decoration: AppDecorations.hudModule(),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'CONTROLLER SCALE',
                                        style: AppTypography.button.copyWith(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 2.0),
                                      Text(
                                        'Rocker & action button hit size',
                                        style: AppTypography.telemetryLabel
                                            .copyWith(fontSize: 10.5),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildScaleChip('0.9x', 0.9),
                                    const SizedBox(width: 6.0),
                                    _buildScaleChip('1.0x', 1.0),
                                    const SizedBox(width: 6.0),
                                    _buildScaleChip('1.15x', 1.15),
                                    const SizedBox(width: 6.0),
                                    _buildScaleChip('1.3x', 1.3),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          _buildToggleRow(
                            label: 'SOUTHPAW MODE',
                            subtitle: 'Left-handed layout: swaps D-pad and action buttons',
                            value: _southpaw,
                            onChanged: (val) {
                              setState(() => _southpaw = val);
                              _saveTouchSettings();
                              widget.onSouthpawChanged?.call(val);
                            },
                          ),

                          // Accessibility Section
                          _buildSectionHeader('ACCESSIBILITY & TELEMETRY'),
                          _buildToggleRow(
                            label: 'REDUCE MOTION',
                            subtitle: 'Disables camera trauma shake and chromatic shockwaves',
                            value: _reduceMotion,
                            onChanged: (val) {
                              setState(() => _reduceMotion = val);
                              _persistence.saveReduceMotion(val);
                              widget.onReduceMotionChanged?.call(val);
                            },
                          ),
                          _buildToggleRow(
                            label: 'QUANTUM GHOST RUNNER',
                            subtitle: 'Holographic shadow replay of your Personal Best run',
                            value: _ghostEnabled,
                            onChanged: (val) {
                              setState(() => _ghostEnabled = val);
                              _persistence.saveGhostEnabled(val);
                            },
                          ),

                          // Data Management Section
                          _buildSectionHeader('DATA MANAGEMENT'),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 4.0),
                            padding: const EdgeInsets.all(14.0),
                            decoration: AppDecorations.hudModule(),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'RESET PROGRESSION',
                                        style: AppTypography.telemetryLabel
                                            .copyWith(
                                              color: AppColors.error,
                                              fontWeight: FontWeight.w800,
                                            ),
                                      ),
                                      const SizedBox(height: 2.0),
                                      Text(
                                        'Purges chamber records, best split times, and milestone badges',
                                        style: AppTypography.bodySmall.copyWith(
                                          color: AppColors.onSurfaceVariant,
                                          fontSize: 10.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12.0),
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.error,
                                    side: const BorderSide(
                                      color: AppColors.error,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 12.0,
                                    ),
                                    shape: AppDecorations.chamferShape(
                                      chamfer: AppDecorations.chamferXs,
                                      borderColor: AppColors.error,
                                    ),
                                  ),
                                  onPressed: _showResetConfirmation,
                                  child: const Text('PURGE'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18.0),
                          Center(
                            child: Text(
                              AppPlatform.isTouchDevice(context)
                                  ? 'TAP BACK ARROW TO RETURN'
                                  : '[ESC / BACKSPACE] RETURN TO MAIN MENU',
                              style: AppTypography.telemetryLabel.copyWith(
                                fontSize: 9.5,
                                color: AppColors.onSurfaceVariant.withValues(
                                  alpha: 0.75,
                                ),
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24.0),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showResetConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.canvasDark,
        shape: AppDecorations.chamferShape(
          chamfer: AppDecorations.chamferMd,
          borderColor: AppColors.error,
          borderWidth: 2.0,
        ),
        title: Text(
          'PURGE ALL PROGRESS?',
          style: AppTypography.sectionHeader.copyWith(
            color: AppColors.error,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
        content: Text(
          'This will permanently reset all cleared chambers, best split times, and tactical milestone badges back to default. This action cannot be undone.',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'CANCEL',
              style: AppTypography.button.copyWith(color: AppColors.onSurface),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error.withValues(alpha: 0.2),
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error, width: 1.5),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('CONFIRM PURGE'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ProgressionService.instance.resetProgression();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.canvasDark,
            content: Text(
              'PROGRESS & MILESTONE TELEMETRY RESET',
              style: AppTypography.telemetryLabel.copyWith(
                color: AppColors.solarAmber,
              ),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
