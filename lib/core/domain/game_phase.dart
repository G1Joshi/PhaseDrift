import 'package:material_ui/material_ui.dart';

import '../theme/theme.dart';

enum PhaseType { solar, voidPhase, universal }

sealed class GamePhase {
  const GamePhase();

  double get gravityMultiplier;
  Color get primaryColor;
  Color get accentColor;
  PhaseType get type;

  bool isPlatformSolid(PhaseType platformType) {
    return platformType == type || platformType == PhaseType.universal;
  }

  GamePhase toggle();
}

final class SolarPhase extends GamePhase {
  const SolarPhase();

  @override
  double get gravityMultiplier => 1.0;

  @override
  Color get primaryColor => AppColors.solarAmber;

  @override
  Color get accentColor => AppColors.solarGold;

  @override
  PhaseType get type => PhaseType.solar;

  @override
  GamePhase toggle() => const VoidPhase();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SolarPhase;

  @override
  int get hashCode => runtimeType.hashCode;
}

final class VoidPhase extends GamePhase {
  const VoidPhase();

  @override
  double get gravityMultiplier => -1.0;

  @override
  Color get primaryColor => AppColors.voidCyan;

  @override
  Color get accentColor => AppColors.neonTeal;

  @override
  PhaseType get type => PhaseType.voidPhase;

  @override
  GamePhase toggle() => const SolarPhase();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is VoidPhase;

  @override
  int get hashCode => runtimeType.hashCode;
}
