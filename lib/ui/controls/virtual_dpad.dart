import 'package:material_ui/material_ui.dart';

import '../../core/domain/domain.dart';
import '../../core/services/services.dart';
import '../../core/theme/theme.dart';

class VirtualDpad extends StatefulWidget {
  const VirtualDpad({
    super.key,
    required this.onMove,
    required this.onJumpPressed,
    required this.onJumpReleased,
    required this.onShiftPressed,
    this.phase = const SolarPhase(),
    this.opacity = 0.85,
    this.scale = 1.0,
    this.southpaw = false,
  });

  final ValueChanged<double> onMove;
  final VoidCallback onJumpPressed;
  final VoidCallback onJumpReleased;
  final VoidCallback onShiftPressed;
  final GamePhase phase;
  final double opacity;
  final double scale;
  final bool southpaw;

  @override
  State<VirtualDpad> createState() => _VirtualDpadState();
}

class _VirtualDpadState extends State<VirtualDpad> {
  double _currentMoveAxis = 0.0;
  int? _rockerPointerId;
  int? _jumpPointerId;
  int? _shiftPointerId;
  bool _jumpHeld = false;
  bool _shiftPressed = false;

  void _setDirection(double axis) {
    if ((_currentMoveAxis - axis).abs() > 0.01) {
      if (mounted) {
        setState(() => _currentMoveAxis = axis);
      }
      widget.onMove(axis);
    }
  }

  @override
  void dispose() {
    if (_currentMoveAxis != 0.0) {
      widget.onMove(0.0);
    }
    if (_jumpHeld) {
      widget.onJumpReleased();
    }
    super.dispose();
  }

  Widget _buildDirectionButton({
    required IconData icon,
    required bool isActive,
    required Color activeColor,
    required double width,
    required double height,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 50),
      width: width,
      height: height,
      decoration: ShapeDecoration(
        color: isActive
            ? activeColor.withValues(alpha: 0.35)
            : AppColors.canvasDark.withValues(alpha: 0.75),
        shape: AppDecorations.chamferShape(
          chamfer: AppDecorations.chamferSm * widget.scale,
          borderColor: isActive ? activeColor : AppColors.structuralSeam,
          borderWidth: isActive ? 2.0 : 1.5,
        ),
        shadows: isActive
            ? [
                BoxShadow(
                  color: activeColor.withValues(alpha: 0.40),
                  blurRadius: 16.0 * widget.scale,
                  spreadRadius: 1.0,
                ),
              ]
            : null,
      ),
      child: Center(
        child: Icon(
          icon,
          color: isActive ? activeColor : AppColors.onSurface,
          size: 28.0 * widget.scale,
        ),
      ),
    );
  }

  Widget _buildDirectionalRocker() {
    final activeColor = widget.phase.primaryColor;
    final btnWidth = 66.0 * widget.scale;
    final btnHeight = 60.0 * widget.scale;
    final gap = 10.0 * widget.scale;
    final totalWidth = (btnWidth * 2) + gap;

    final isLeftActive = _currentMoveAxis < -0.1;
    final isRightActive = _currentMoveAxis > 0.1;

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (event) {
        _rockerPointerId = event.pointer;
        final mid = totalWidth / 2;
        final newDir = event.localPosition.dx < mid ? -1.0 : 1.0;
        _setDirection(newDir);
        HapticsService.instance.triggerTouchDown();
      },
      onPointerMove: (event) {
        if (event.pointer != _rockerPointerId) return;
        final mid = totalWidth / 2;
        final newDir = event.localPosition.dx < mid ? -1.0 : 1.0;
        _setDirection(newDir);
      },
      onPointerUp: (event) {
        if (event.pointer == _rockerPointerId) {
          _rockerPointerId = null;
          _setDirection(0.0);
        }
      },
      onPointerCancel: (event) {
        if (event.pointer == _rockerPointerId) {
          _rockerPointerId = null;
          _setDirection(0.0);
        }
      },
      child: SizedBox(
        width: totalWidth,
        height: btnHeight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDirectionButton(
              icon: Icons.chevron_left,
              isActive: isLeftActive,
              activeColor: activeColor,
              width: btnWidth,
              height: btnHeight,
            ),
            SizedBox(width: gap),
            _buildDirectionButton(
              icon: Icons.chevron_right,
              isActive: isRightActive,
              activeColor: activeColor,
              width: btnWidth,
              height: btnHeight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShiftButton() {
    final activeColor = widget.phase.accentColor;
    final size = 54.0 * widget.scale;

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (event) {
        _shiftPointerId = event.pointer;
        setState(() => _shiftPressed = true);
        HapticsService.instance.triggerTouchDown();
        widget.onShiftPressed();
      },
      onPointerUp: (event) {
        if (event.pointer == _shiftPointerId) {
          _shiftPointerId = null;
          if (mounted) setState(() => _shiftPressed = false);
        }
      },
      onPointerCancel: (event) {
        if (event.pointer == _shiftPointerId) {
          _shiftPointerId = null;
          if (mounted) setState(() => _shiftPressed = false);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 50),
        width: size,
        height: size,
        decoration: ShapeDecoration(
          color: _shiftPressed
              ? activeColor.withValues(alpha: 0.40)
              : AppColors.canvasDark.withValues(alpha: 0.75),
          shape: AppDecorations.chamferShape(
            chamfer: AppDecorations.chamferMd * widget.scale,
            borderColor: _shiftPressed ? activeColor : AppColors.border,
            borderWidth: _shiftPressed ? 2.0 : 1.5,
          ),
          shadows: _shiftPressed
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.45),
                    blurRadius: 18.0 * widget.scale,
                    spreadRadius: 1.0,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.swap_vert,
              color: _shiftPressed ? activeColor : AppColors.onSurface,
              size: 22.0 * widget.scale,
            ),
            const SizedBox(height: 1.0),
            Text(
              'SHIFT',
              style: AppTypography.telemetryLabel.copyWith(
                fontSize: 8.5 * widget.scale,
                color: _shiftPressed ? activeColor : AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJumpButton() {
    final activeColor = widget.phase.primaryColor;
    final size = 64.0 * widget.scale;

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (event) {
        _jumpPointerId = event.pointer;
        setState(() => _jumpHeld = true);
        HapticsService.instance.triggerTouchDown();
        widget.onJumpPressed();
      },
      onPointerUp: (event) {
        if (event.pointer == _jumpPointerId) {
          _jumpPointerId = null;
          if (mounted) setState(() => _jumpHeld = false);
          widget.onJumpReleased();
        }
      },
      onPointerCancel: (event) {
        if (event.pointer == _jumpPointerId) {
          _jumpPointerId = null;
          if (mounted) setState(() => _jumpHeld = false);
          widget.onJumpReleased();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 50),
        width: size,
        height: size,
        decoration: ShapeDecoration(
          color: _jumpHeld
              ? activeColor.withValues(alpha: 0.40)
              : AppColors.canvasDark.withValues(alpha: 0.75),
          shape: AppDecorations.chamferShape(
            chamfer: AppDecorations.chamferMd * widget.scale,
            borderColor: _jumpHeld ? activeColor : AppColors.border,
            borderWidth: _jumpHeld ? 2.2 : 1.5,
          ),
          shadows: _jumpHeld
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.50),
                    blurRadius: 22.0 * widget.scale,
                    spreadRadius: 1.5,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.keyboard_arrow_up,
              color: _jumpHeld ? activeColor : AppColors.onSurface,
              size: 26.0 * widget.scale,
            ),
            const SizedBox(height: 1.0),
            Text(
              'JUMP',
              style: AppTypography.telemetryLabel.copyWith(
                fontSize: 9.5 * widget.scale,
                color: _jumpHeld ? activeColor : AppColors.onSurface,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rocker = _buildDirectionalRocker();
    final actionCluster = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 10.0 * widget.scale),
          child: _buildShiftButton(),
        ),
        SizedBox(width: 12.0 * widget.scale),
        _buildJumpButton(),
      ],
    );

    final size = MediaQuery.sizeOf(context);
    final isCompact = size.height <= 480.0;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Opacity(
        opacity: widget.opacity.clamp(0.2, 1.0),
        child: SafeArea(
          top: false,
          maintainBottomViewPadding: true,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 16.0 : 24.0,
              vertical: isCompact ? 10.0 : 16.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: widget.southpaw
                  ? [actionCluster, rocker]
                  : [rocker, actionCluster],
            ),
          ),
        ),
      ),
    );
  }
}
