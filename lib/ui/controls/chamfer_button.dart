import 'package:material_ui/material_ui.dart';

import '../../core/services/services.dart';
import '../../core/theme/theme.dart';

class ChamferButton extends StatefulWidget {
  const ChamferButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isFocused = false,
    this.isPrimary = false,
    this.accentColor,
    this.focusColor = AppColors.voidCyan,
    this.padding = const EdgeInsets.symmetric(vertical: 13.0, horizontal: 16.0),
    this.margin = const EdgeInsets.symmetric(vertical: 4.0),
    this.fontSize = 13.5,
    this.icon,
    this.minHeight = 46.0,
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
  final double minHeight;

  @override
  State<ChamferButton> createState() => _ChamferButtonState();
}

class _ChamferButtonState extends State<ChamferButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final primaryBg = widget.accentColor ?? AppColors.solarAmber;
    final borderColor = widget.isFocused
        ? widget.focusColor
        : (widget.isPrimary ? primaryBg : AppColors.structuralSeam);

    return Padding(
      padding: widget.margin,
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 60),
        curve: Curves.easeOutCubic,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            onTap: () {
              HapticsService.instance.triggerClick();
              widget.onTap();
            },
            customBorder: AppDecorations.chamferShape(
              chamfer: AppDecorations.chamferSm,
            ),
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(minHeight: widget.minHeight),
              padding: widget.padding,
              decoration: ShapeDecoration(
                color: widget.isPrimary
                    ? primaryBg
                    : (widget.isFocused
                          ? AppColors.interactiveModule.withValues(alpha: 0.95)
                          : AppColors.interactiveModule),
                shape: AppDecorations.chamferShape(
                  chamfer: AppDecorations.chamferSm,
                  borderColor: borderColor,
                  borderWidth: widget.isFocused
                      ? 2.2
                      : (widget.isPrimary ? 1.6 : 1.0),
                ),
                shadows: widget.isFocused
                    ? [
                        BoxShadow(
                          color: widget.focusColor.withValues(alpha: 0.45),
                          blurRadius: 18.0,
                          spreadRadius: 1.0,
                        ),
                      ]
                    : (widget.isPrimary
                          ? [
                              BoxShadow(
                                color: primaryBg.withValues(alpha: 0.40),
                                blurRadius: 20.0,
                                spreadRadius: 1.0,
                              ),
                            ]
                          : null),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.isFocused && !widget.isPrimary) ...[
                    Icon(
                      Icons.arrow_right,
                      color: widget.focusColor,
                      size: 18.0,
                    ),
                    const SizedBox(width: 4.0),
                  ],
                  if (widget.icon != null && widget.isPrimary) ...[
                    Icon(
                      widget.icon,
                      color: AppColors.obsidianVoid,
                      size: 18.0,
                    ),
                    const SizedBox(width: 6.0),
                  ],
                  Flexible(
                    child: Text(
                      widget.label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.button.copyWith(
                        color: widget.isPrimary
                            ? AppColors.obsidianVoid
                            : (widget.isFocused
                                  ? widget.focusColor
                                  : AppColors.onSurface),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        fontSize: widget.fontSize,
                      ),
                    ),
                  ),
                  if (widget.isFocused && !widget.isPrimary) ...[
                    const SizedBox(width: 4.0),
                    Icon(
                      Icons.arrow_left,
                      color: widget.focusColor,
                      size: 18.0,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
