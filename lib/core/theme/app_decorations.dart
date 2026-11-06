import 'package:material_ui/material_ui.dart';

import 'app_colors.dart';

abstract final class AppDecorations {
  static const double chamferXs = 2.0;
  static const double chamferSm = 4.0;
  static const double chamferMd = 8.0;
  static const double chamferLg = 12.0;

  static OutlinedBorder chamferShape({
    double chamfer = chamferMd,
    Color borderColor = AppColors.border,
    double borderWidth = 1.0,
  }) {
    return BeveledRectangleBorder(
      borderRadius: BorderRadius.circular(chamfer),
      side: BorderSide(color: borderColor, width: borderWidth),
    );
  }

  static ShapeDecoration card({
    Color backgroundColor = AppColors.cardSurface,
    Color borderColor = AppColors.border,
    double chamfer = chamferMd,
    double borderWidth = 1.0,
  }) {
    return ShapeDecoration(
      color: backgroundColor,
      shape: BeveledRectangleBorder(
        borderRadius: BorderRadius.circular(chamfer),
        side: BorderSide(color: borderColor, width: borderWidth),
      ),
    );
  }

  static ShapeDecoration hudModule({
    Color backgroundColor = AppColors.interactiveModule,
    Color borderColor = AppColors.structuralSeam,
    double chamfer = chamferSm,
  }) {
    return ShapeDecoration(
      color: backgroundColor,
      shape: BeveledRectangleBorder(
        borderRadius: BorderRadius.circular(chamfer),
        side: BorderSide(color: borderColor, width: 1.0),
      ),
    );
  }

  static ShapeDecoration phaseActive({
    required Color phaseColor,
    Color backgroundColor = AppColors.interactiveModule,
    double chamfer = chamferSm,
  }) {
    return ShapeDecoration(
      color: backgroundColor,
      shape: BeveledRectangleBorder(
        borderRadius: BorderRadius.circular(chamfer),
        side: BorderSide(color: phaseColor, width: 1.5),
      ),
      shadows: [
        BoxShadow(
          color: phaseColor.withValues(alpha: 0.35),
          blurRadius: 10.0,
          spreadRadius: 1.0,
        ),
      ],
    );
  }
}
