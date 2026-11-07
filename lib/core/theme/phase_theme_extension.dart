import 'package:material_ui/material_ui.dart';

import 'app_colors.dart';

class PhaseThemeExtension extends ThemeExtension<PhaseThemeExtension> {
  const PhaseThemeExtension({
    required this.activePhaseColor,
    required this.activePhaseGlow,
    required this.activePhaseSurface,
    required this.activePhaseAccent,
    required this.isPhaseAlpha,
  });

  const PhaseThemeExtension.solar()
    : activePhaseColor = AppColors.solarAmber,
      activePhaseGlow = AppColors.solarAmbientGlow,
      activePhaseSurface = AppColors.solarSurface,
      activePhaseAccent = AppColors.solarGold,
      isPhaseAlpha = true;

  const PhaseThemeExtension.voidPhase()
    : activePhaseColor = AppColors.voidCyan,
      activePhaseGlow = AppColors.voidAmbientGlow,
      activePhaseSurface = AppColors.voidSurface,
      activePhaseAccent = AppColors.neonTeal,
      isPhaseAlpha = false;

  final Color activePhaseColor;
  final Color activePhaseGlow;
  final Color activePhaseSurface;
  final Color activePhaseAccent;
  final bool isPhaseAlpha;

  @override
  PhaseThemeExtension copyWith({
    Color? activePhaseColor,
    Color? activePhaseGlow,
    Color? activePhaseSurface,
    Color? activePhaseAccent,
    bool? isPhaseAlpha,
  }) {
    return PhaseThemeExtension(
      activePhaseColor: activePhaseColor ?? this.activePhaseColor,
      activePhaseGlow: activePhaseGlow ?? this.activePhaseGlow,
      activePhaseSurface: activePhaseSurface ?? this.activePhaseSurface,
      activePhaseAccent: activePhaseAccent ?? this.activePhaseAccent,
      isPhaseAlpha: isPhaseAlpha ?? this.isPhaseAlpha,
    );
  }

  @override
  PhaseThemeExtension lerp(
    ThemeExtension<PhaseThemeExtension>? other,
    double t,
  ) {
    if (other is! PhaseThemeExtension) {
      return this;
    }

    return PhaseThemeExtension(
      activePhaseColor:
          Color.lerp(activePhaseColor, other.activePhaseColor, t) ??
          activePhaseColor,
      activePhaseGlow:
          Color.lerp(activePhaseGlow, other.activePhaseGlow, t) ??
          activePhaseGlow,
      activePhaseSurface:
          Color.lerp(activePhaseSurface, other.activePhaseSurface, t) ??
          activePhaseSurface,
      activePhaseAccent:
          Color.lerp(activePhaseAccent, other.activePhaseAccent, t) ??
          activePhaseAccent,
      isPhaseAlpha: t <= 0.5 ? isPhaseAlpha : other.isPhaseAlpha,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhaseThemeExtension &&
          runtimeType == other.runtimeType &&
          activePhaseColor == other.activePhaseColor &&
          activePhaseGlow == other.activePhaseGlow &&
          activePhaseSurface == other.activePhaseSurface &&
          activePhaseAccent == other.activePhaseAccent &&
          isPhaseAlpha == other.isPhaseAlpha;

  @override
  int get hashCode => Object.hash(
    activePhaseColor,
    activePhaseGlow,
    activePhaseSurface,
    activePhaseAccent,
    isPhaseAlpha,
  );
}

extension PhaseThemeContextX on BuildContext {
  PhaseThemeExtension get phaseTheme =>
      Theme.of(this).extension<PhaseThemeExtension>() ??
      const PhaseThemeExtension.solar();
}
