import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTypography {
  static TextStyle get displayHero => GoogleFonts.spaceGrotesk(
    fontSize: 44,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.0,
    height: 1.1,
    color: AppColors.onSurface,
  );

  static TextStyle get titleChamber => GoogleFonts.spaceGrotesk(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
    height: 1.2,
    color: AppColors.onSurface,
  );

  static TextStyle get sectionHeader => GoogleFonts.spaceGrotesk(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.0,
    height: 1.3,
    color: AppColors.onSurface,
  );

  static TextStyle get body => GoogleFonts.spaceGrotesk(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    height: 1.4,
    color: AppColors.onSurface,
  );

  static TextStyle get bodySmall => GoogleFonts.spaceGrotesk(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    height: 1.4,
    color: AppColors.onSurfaceVariant,
  );

  static TextStyle get button => GoogleFonts.spaceGrotesk(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
    height: 1.0,
    color: AppColors.onSurface,
  );

  static TextStyle get telemetryValue => GoogleFonts.jetBrainsMono(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.1,
    color: AppColors.onSurface,
  );

  static TextStyle get telemetryValueSm => GoogleFonts.jetBrainsMono(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.2,
    color: AppColors.onSurface,
  );

  static TextStyle get telemetryLabel => GoogleFonts.jetBrainsMono(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.2,
    height: 1.0,
    color: AppColors.onSurfaceVariant,
  );

  static TextTheme get textTheme => TextTheme(
    displayLarge: displayHero,
    headlineMedium: titleChamber,
    titleLarge: sectionHeader,
    bodyMedium: body,
    bodySmall: bodySmall,
    labelLarge: button,
    labelSmall: telemetryLabel,
  );
}
