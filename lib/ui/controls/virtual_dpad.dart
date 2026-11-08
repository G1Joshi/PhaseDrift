import 'package:material_ui/material_ui.dart';

import '../../core/domain/domain.dart';
import '../../core/theme/theme.dart';

class VirtualDpad extends StatefulWidget {
  const VirtualDpad({
    super.key,
    required this.onMove,
    required this.onJumpPressed,
    required this.onJumpReleased,
    required this.onShiftPressed,
    this.phase = const SolarPhase(),
  });

  final ValueChanged<double> onMove;
  final VoidCallback onJumpPressed;
  final VoidCallback onJumpReleased;
  final VoidCallback onShiftPressed;
  final GamePhase phase;

  @override
  State<VirtualDpad> createState() => _VirtualDpadState();
}

class _VirtualDpadState extends State<VirtualDpad> {
  bool _leftPressed = false;
  bool _rightPressed = false;
  bool _jumpPressed = false;

  void _updateMove() {
    if (_leftPressed && !_rightPressed) {
      widget.onMove(-1.0);
    } else if (_rightPressed && !_leftPressed) {
      widget.onMove(1.0);
    } else {
      widget.onMove(0.0);
    }
  }

  Widget _buildDirectionalButton({
    required IconData icon,
    required bool isPressed,
    required ValueChanged<bool> onStateChange,
  }) {
    final activeColor = widget.phase.primaryColor;

    return Listener(
      onPointerDown: (_) {
        onStateChange(true);
        _updateMove();
      },
      onPointerUp: (_) {
        onStateChange(false);
        _updateMove();
      },
      onPointerCancel: (_) {
        onStateChange(false);
        _updateMove();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        width: 56.0,
        height: 56.0,
        decoration: ShapeDecoration(
          color: isPressed
              ? activeColor.withValues(alpha: 0.25)
              : AppColors.canvasDark.withValues(alpha: 0.70),
          shape: AppDecorations.chamferShape(
            chamfer: AppDecorations.chamferSm,
            borderColor: isPressed ? activeColor : AppColors.structuralSeam,
            borderWidth: isPressed ? 1.5 : 1.0,
          ),
        ),
        child: Center(
          child: Icon(
            icon,
            color: isPressed ? activeColor : AppColors.onSurface,
            size: 26.0,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onDown,
    VoidCallback? onUp,
    bool isPressed = false,
    bool isShift = false,
  }) {
    final activeColor = widget.phase.primaryColor;

    return Listener(
      onPointerDown: (_) => onDown(),
      onPointerUp: (_) => onUp?.call(),
      onPointerCancel: (_) => onUp?.call(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        width: 64.0,
        height: 64.0,
        decoration: ShapeDecoration(
          color: isPressed
              ? activeColor.withValues(alpha: 0.3)
              : (isShift
                    ? widget.phase.accentColor.withValues(alpha: 0.15)
                    : AppColors.canvasDark.withValues(alpha: 0.70)),
          shape: AppDecorations.chamferShape(
            chamfer: AppDecorations.chamferMd,
            borderColor: isPressed
                ? activeColor
                : (isShift ? activeColor : AppColors.border),
            borderWidth: isPressed ? 2.0 : 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isPressed ? activeColor : AppColors.onSurface,
              size: 24.0,
            ),
            const SizedBox(height: 2.0),
            Text(
              label,
              style: AppTypography.telemetryLabel.copyWith(
                fontSize: 9.0,
                color: isPressed ? activeColor : AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Left D-pad (Move Left / Right)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDirectionalButton(
                    icon: Icons.arrow_left,
                    isPressed: _leftPressed,
                    onStateChange: (pressed) =>
                        setState(() => _leftPressed = pressed),
                  ),
                  const SizedBox(width: 8.0),
                  _buildDirectionalButton(
                    icon: Icons.arrow_right,
                    isPressed: _rightPressed,
                    onStateChange: (pressed) =>
                        setState(() => _rightPressed = pressed),
                  ),
                ],
              ),

              // Right Action Buttons (Shift & Jump)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildActionButton(
                    label: 'SHIFT',
                    icon: Icons.swap_vert,
                    isShift: true,
                    onDown: widget.onShiftPressed,
                  ),
                  const SizedBox(width: 12.0),
                  _buildActionButton(
                    label: 'JUMP',
                    icon: Icons.keyboard_arrow_up,
                    isPressed: _jumpPressed,
                    onDown: () {
                      setState(() => _jumpPressed = true);
                      widget.onJumpPressed();
                    },
                    onUp: () {
                      setState(() => _jumpPressed = false);
                      widget.onJumpReleased();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
