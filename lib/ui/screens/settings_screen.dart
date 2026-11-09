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
  });

  final VoidCallback? onBack;
  final bool reduceMotion;
  final ValueChanged<bool>? onReduceMotionChanged;

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

  @override
  void initState() {
    super.initState();
    _masterVol = _audio.masterVolume;
    _musicVol = _audio.musicVolume;
    _sfxVol = _audio.sfxVolume;
    _isMuted = _audio.isMuted;
    _hapticsEnabled = _haptics.isEnabled;
    _reduceMotion = widget.reduceMotion;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
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
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: AppTypography.telemetryLabel.copyWith(
          color: AppColors.solarAmber,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
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
      decoration: AppDecorations.hudModule(),
      child: Row(
        children: [
          SizedBox(
            width: 100.0,
            child: Text(label, style: AppTypography.telemetryLabel),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: AppColors.solarAmber,
                inactiveTrackColor: AppColors.structuralSeam,
                thumbColor: AppColors.solarGold,
                trackHeight: 3.0,
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 6.0,
                ),
                overlayShape: const RoundSliderOverlayShape(
                  overlayRadius: 14.0,
                ),
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
            width: 44.0,
            child: Text(
              '${(value * 100).toInt()}%',
              textAlign: TextAlign.end,
              style: AppTypography.telemetryValueSm.copyWith(fontSize: 12.0),
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
      decoration: AppDecorations.hudModule(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.button.copyWith(fontSize: 13.0),
                ),
                const SizedBox(height: 2.0),
                Text(
                  subtitle,
                  style: AppTypography.telemetryLabel.copyWith(fontSize: 10.0),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12.0),
          Switch(
            value: value,
            activeThumbColor: AppColors.solarAmber,
            activeTrackColor: AppColors.solarAmber.withValues(alpha: 0.4),
            inactiveTrackColor: AppColors.structuralSeam,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidianVoid,
      body: KeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: (event) {
          if (event is KeyDownEvent &&
              (event.logicalKey == LogicalKeyboardKey.escape ||
                  event.logicalKey == LogicalKeyboardKey.backspace)) {
            widget.onBack?.call();
          }
        },
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
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
                            icon: const Icon(
                              Icons.arrow_back,
                              color: AppColors.onSurface,
                            ),
                            onPressed: widget.onBack,
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
                            ),
                          ),
                        ),
                        const SizedBox(width: 48.0),
                      ],
                    ),
                    const SizedBox(height: 16.0),

                    Expanded(
                      child: ListView(
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

                          // Accessibility Section
                          _buildSectionHeader('ACCESSIBILITY'),
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
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      const SizedBox(height: 2.0),
                                      Text(
                                        'Purges chamber records, best split times, and milestone badges',
                                        style: AppTypography.bodySmall.copyWith(
                                          color: AppColors.onSurfaceVariant,
                                          fontSize: 10.0,
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
                                      vertical: 10.0,
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
