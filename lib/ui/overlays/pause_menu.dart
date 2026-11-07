import 'dart:ui';

import 'package:material_ui/material_ui.dart';

import '../../core/domain/domain.dart';
import '../../core/theme/theme.dart';

class PauseMenu extends StatelessWidget {
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

  Widget _buildMenuButton({
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    final activeColor = phase.primaryColor;

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
              color: isPrimary ? activeColor : AppColors.interactiveModule,
              shape: AppDecorations.chamferShape(
                chamfer: AppDecorations.chamferSm,
                borderColor: isPrimary ? activeColor : AppColors.structuralSeam,
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
    final chamberCode = 'CHAMBER ${chamberNumber.toString().padLeft(2, '0')}';
    final phaseColor = phase.primaryColor;

    return Stack(
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
                    '$chamberCode // ${chamberName.toUpperCase()}',
                    style: AppTypography.telemetryLabel.copyWith(
                      color: phaseColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  _buildMenuButton(
                    label: 'RESUME',
                    onTap: onResume,
                    isPrimary: true,
                  ),
                  _buildMenuButton(label: 'RESTART CHAMBER', onTap: onRestart),
                  if (onSettings != null)
                    _buildMenuButton(label: 'SETTINGS', onTap: onSettings!),
                  if (onQuit != null)
                    _buildMenuButton(label: 'MAIN MENU', onTap: onQuit!),
                  const SizedBox(height: 16.0),
                  Text(
                    '[ESC] TO RESUME // [P] TO TOGGLE',
                    style: AppTypography.telemetryLabel.copyWith(
                      fontSize: 10.0,
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
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
