import 'package:material_ui/material_ui.dart';

import '../../core/audio/audio.dart';
import '../../core/theme/theme.dart';
import '../hud/amber_cyan_progress_bar.dart';

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

  void _ensureAudioStarted() {
    if (!_audio.isPlaying) {
      _audio.startMusic();
    }
  }

  Widget _buildMenuButton({
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _ensureAudioStarted();
            onTap();
          },
          customBorder: AppDecorations.chamferShape(
            chamfer: AppDecorations.chamferSm,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14.0),
            decoration: ShapeDecoration(
              color: isPrimary
                  ? AppColors.solarAmber
                  : AppColors.interactiveModule,
              shape: AppDecorations.chamferShape(
                chamfer: AppDecorations.chamferSm,
                borderColor: isPrimary
                    ? AppColors.solarGold
                    : AppColors.structuralSeam,
                borderWidth: isPrimary ? 1.5 : 1.0,
              ),
              shadows: isPrimary
                  ? [
                      BoxShadow(
                        color: AppColors.solarAmber.withValues(alpha: 0.35),
                        blurRadius: 20.0,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                label,
                style: AppTypography.button.copyWith(
                  color: isPrimary
                      ? AppColors.obsidianVoid
                      : AppColors.onSurface,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  fontSize: 14.0,
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
    return Scaffold(
      backgroundColor: AppColors.obsidianVoid,
      body: GestureDetector(
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
                            _audio.isMuted ? Icons.volume_off : Icons.volume_up,
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
                          isPrimary: true,
                        ),
                        _buildMenuButton(
                          label: 'CHAMBER MATRIX',
                          onTap: widget.onOpenChamberSelect,
                        ),
                        _buildMenuButton(
                          label: 'SYSTEM SETTINGS',
                          onTap: widget.onOpenSettings,
                        ),
                        const SizedBox(height: 16.0),

                        // Tactical Copyright
                        Text(
                          '\u00A9 2026 G1 // DEV.G1JOSHI.PHASEDRIFT',
                          style: AppTypography.telemetryLabel.copyWith(
                            fontSize: 9.0,
                            color: AppColors.structuralSeam,
                            letterSpacing: 1.0,
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
    );
  }
}
