import 'package:material_ui/material_ui.dart';

import 'app_colors.dart';
import 'app_decorations.dart';
import 'app_typography.dart';
import 'phase_theme_extension.dart';

abstract final class AppTheme {
  static ThemeData get solarTheme => _buildTheme(isSolar: true);

  static ThemeData get voidTheme => _buildTheme(isSolar: false);

  static ThemeData _buildTheme({required bool isSolar}) {
    final primaryColor = isSolar ? AppColors.solarAmber : AppColors.voidCyan;
    final secondaryColor = isSolar ? AppColors.voidCyan : AppColors.solarAmber;
    final extension = isSolar
        ? const PhaseThemeExtension.solar()
        : const PhaseThemeExtension.voidPhase();

    final colorScheme = ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: AppColors.surface,
      error: AppColors.hazardRed,
      onPrimary: AppColors.obsidianVoid,
      onSecondary: AppColors.obsidianVoid,
      onSurface: AppColors.onSurface,
      outline: AppColors.border,
      outlineVariant: AppColors.structuralSeam,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.obsidianVoid,
      canvasColor: AppColors.cosmicAbyss,
      cardColor: AppColors.cardSurface,
      dividerColor: AppColors.structuralSeam,
      textTheme: AppTypography.textTheme,
      extensions: [extension],
      cardTheme: CardThemeData(
        color: AppColors.cardSurface,
        elevation: 0,
        shape: AppDecorations.chamferShape(),
        margin: EdgeInsets.zero,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.cardSurface,
        elevation: 0,
        shape: AppDecorations.chamferShape(chamfer: AppDecorations.chamferLg),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: AppColors.obsidianVoid,
          textStyle: AppTypography.button,
          elevation: 0,
          shape: AppDecorations.chamferShape(
            chamfer: AppDecorations.chamferSm,
            borderColor: Colors.transparent,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: AppTypography.button,
          side: BorderSide(color: primaryColor, width: 1.0),
          shape: AppDecorations.chamferShape(chamfer: AppDecorations.chamferSm),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
    );
  }
}
