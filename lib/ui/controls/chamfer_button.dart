import 'package:material_ui/material_ui.dart';

import '../../core/services/services.dart';
import '../../core/theme/theme.dart';

class ChamferButton extends StatelessWidget {
  const ChamferButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isFocused = false,
    this.isPrimary = false,
    this.accentColor,
    this.focusColor = AppColors.voidCyan,
    this.padding = const EdgeInsets.symmetric(vertical: 12.0),
    this.margin = const EdgeInsets.symmetric(vertical: 4.0),
    this.fontSize = 13.0,
    this.icon,
  });

  final String label;
  final VoidCallback onTap;
  final bool isFocused;
  final bool isPrimary;
  final Color? accentColor;
  final Color focusColor;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double fontSize;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final primaryBg = accentColor ?? AppColors.solarAmber;
    final borderColor = isFocused
        ? focusColor
        : (isPrimary ? primaryBg : AppColors.structuralSeam);

    return Padding(
      padding: margin,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticsService.instance.triggerClick();
            onTap();
          },
          customBorder: AppDecorations.chamferShape(
            chamfer: AppDecorations.chamferSm,
          ),
          child: Container(
            width: double.infinity,
            padding: padding,
            decoration: ShapeDecoration(
              color: isPrimary
                  ? primaryBg
                  : (isFocused
                        ? AppColors.interactiveModule.withValues(alpha: 0.9)
                        : AppColors.interactiveModule),
              shape: AppDecorations.chamferShape(
                chamfer: AppDecorations.chamferSm,
                borderColor: borderColor,
                borderWidth: isFocused ? 2.0 : (isPrimary ? 1.5 : 1.0),
              ),
              shadows: isFocused
                  ? [
                      BoxShadow(
                        color: focusColor.withValues(alpha: 0.45),
                        blurRadius: 18.0,
                        spreadRadius: 1.0,
                      ),
                    ]
                  : (isPrimary
                        ? [
                            BoxShadow(
                              color: primaryBg.withValues(alpha: 0.35),
                              blurRadius: 20.0,
                            ),
                          ]
                        : null),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isFocused && !isPrimary) ...[
                  Icon(Icons.arrow_right, color: focusColor, size: 16.0),
                  const SizedBox(width: 4.0),
                ],
                if (icon != null && isPrimary) ...[
                  Icon(icon, color: AppColors.obsidianVoid, size: 16.0),
                  const SizedBox(width: 6.0),
                ],
                Flexible(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.button.copyWith(
                      color: isPrimary
                          ? AppColors.obsidianVoid
                          : (isFocused ? focusColor : AppColors.onSurface),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      fontSize: fontSize,
                    ),
                  ),
                ),
                if (isFocused && !isPrimary) ...[
                  const SizedBox(width: 4.0),
                  Icon(Icons.arrow_left, color: focusColor, size: 16.0),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
