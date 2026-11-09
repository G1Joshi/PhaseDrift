import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phasedrift/core/theme/theme.dart';

void main() {
  test('PhaseThemeExtension.lerp blends colors across phase transitions', () {
    const solar = PhaseThemeExtension.solar();
    const voidPhase = PhaseThemeExtension.voidPhase();

    final midway = solar.lerp(voidPhase, 0.5);
    expect(
      midway.activePhaseColor,
      equals(Color.lerp(AppColors.solarAmber, AppColors.voidCyan, 0.5)),
    );
    expect(midway.isPhaseAlpha, isTrue);

    final end = solar.lerp(voidPhase, 1.0);
    expect(end.activePhaseColor, equals(AppColors.voidCyan));
    expect(end.isPhaseAlpha, isFalse);
  });
}
