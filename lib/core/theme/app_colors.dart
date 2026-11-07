import 'package:material_ui/material_ui.dart';

abstract final class AppColors {
  static const Color obsidianVoid = Color(0xFF05060A);
  static const Color cosmicAbyss = Color(0xFF08080F);
  static const Color canvasDark = Color(0xFF0B0D14);
  static const Color deepCharcoal = Color(0xFF121217);
  static const Color surface = Color(0xFF121318);
  static const Color cardSurface = Color(0xFF161B2B);
  static const Color interactiveModule = Color(0xFF121622);
  static const Color border = Color(0xFF22283C);
  static const Color structuralSeam = Color(0xFF1A2030);
  static const Color onSurface = Color(0xFFE3E2E9);
  static const Color onSurfaceVariant = Color(0xFFD8C3AD);

  static const Color solarAmber = Color(0xFFF59E0B);
  static const Color solarGold = Color(0xFFFDE047);
  static const Color solarLight = Color(0xFFFFC174);
  static const Color solarDark = Color(0xFFD97706);
  static const Color solarSurface = Color(0xFF231505);
  static const Color solarAmbientGlow = Color(0x66F59E0B);

  static const Color voidCyan = Color(0xFF06B6D4);
  static const Color voidBright = Color(0xFF4CD7F6);
  static const Color neonTeal = Color(0xFF22D3EE);
  static const Color voidDark = Color(0xFF0891B2);
  static const Color voidSurface = Color(0xFF041924);
  static const Color voidAmbientGlow = Color(0x6606B6D4);

  static const Color universalPlatform = Color(0xFF272738);
  static const Color universalBorder = Color(0xFF4B5563);

  static const Color apexWhite = Color(0xFFFFFFFF);
  static const Color chronoShard = Color(0xFFFACC15);
  static const Color hazardRed = Color(0xFFEF4444);
  static const Color successGreen = Color(0xFF10B981);
  static const Color error = Color(0xFFFFB4AB);

  static const LinearGradient phaseHandoverGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [solarAmber, voidCyan],
  );

  static const RadialGradient solarGlow = RadialGradient(
    colors: [solarAmber, Colors.transparent],
  );

  static const RadialGradient voidGlow = RadialGradient(
    colors: [voidCyan, Colors.transparent],
  );
}
