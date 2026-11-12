import 'package:material_ui/material_ui.dart';

import 'app_colors.dart';

abstract final class AppTypography {
  static const TextStyle displayHero = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontSize: 44,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.0,
    height: 1.1,
    color: AppColors.onSurface,
  );

  static const TextStyle titleChamber = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
    height: 1.2,
    color: AppColors.onSurface,
  );

  static const TextStyle sectionHeader = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.0,
    height: 1.3,
    color: AppColors.onSurface,
  );

  static const TextStyle body = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    height: 1.4,
    color: AppColors.onSurface,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    height: 1.4,
    color: AppColors.onSurfaceVariant,
  );

  static const TextStyle button = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
    height: 1.0,
    color: AppColors.onSurface,
  );

  static const TextStyle telemetryValue = TextStyle(
    fontFamily: 'JetBrainsMono',
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.1,
    color: AppColors.onSurface,
  );

  static const TextStyle telemetryValueSm = TextStyle(
    fontFamily: 'JetBrainsMono',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.2,
    color: AppColors.onSurface,
  );

  static const TextStyle telemetryLabel = TextStyle(
    fontFamily: 'JetBrainsMono',
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.2,
    height: 1.0,
    color: AppColors.onSurfaceVariant,
  );

  static const TextTheme textTheme = TextTheme(
    displayLarge: displayHero,
    headlineMedium: titleChamber,
    titleLarge: sectionHeader,
    bodyMedium: body,
    bodySmall: bodySmall,
    labelLarge: button,
    labelSmall: telemetryLabel,
  );
}
