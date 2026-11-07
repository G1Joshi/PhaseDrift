import 'package:material_ui/material_ui.dart';

import '../../core/theme/theme.dart';

class AmberCyanProgressBar extends StatelessWidget {
  const AmberCyanProgressBar({
    super.key,
    required this.value,
    this.height = 8.0,
    this.width,
    this.showGlint = true,
    this.backgroundColor = AppColors.canvasDark,
    this.borderColor = AppColors.structuralSeam,
    this.chamfer = AppDecorations.chamferXs,
  });

  final double value;
  final double height;
  final double? width;
  final bool showGlint;
  final Color backgroundColor;
  final Color borderColor;
  final double chamfer;

  @override
  Widget build(BuildContext context) {
    final clampedValue = value.clamp(0.0, 1.0);

    return Container(
      width: width,
      height: height,
      decoration: ShapeDecoration(
        color: backgroundColor,
        shape: AppDecorations.chamferShape(
          chamfer: chamfer,
          borderColor: borderColor,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final barWidth = constraints.maxWidth;
          final fillWidth = barWidth * clampedValue;

          return Stack(
            children: [
              if (fillWidth > 0)
                Container(
                  width: fillWidth,
                  height: height,
                  decoration: const BoxDecoration(
                    gradient: AppColors.phaseHandoverGradient,
                  ),
                ),
              if (showGlint && fillWidth > 2.0 && clampedValue < 1.0)
                Positioned(
                  left: fillWidth - 2.0,
                  top: 0,
                  bottom: 0,
                  width: 2.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.apexWhite,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.apexWhite.withValues(alpha: 0.8),
                          blurRadius: 4.0,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
