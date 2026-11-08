import 'package:flutter/services.dart';

class InputController {
  InputController({
    this.onMoveChanged,
    this.onJumpPressed,
    this.onJumpReleased,
    this.onShiftPressed,
    this.onPausePressed,
  });

  final void Function(double axis)? onMoveChanged;
  final void Function()? onJumpPressed;
  final void Function()? onJumpReleased;
  final void Function()? onShiftPressed;
  final void Function()? onPausePressed;

  double _moveAxis = 0.0;
  bool _isJumpHeld = false;

  double get moveAxis => _moveAxis;
  bool get isJumpHeld => _isJumpHeld;

  void setMoveAxis(double axis) {
    final clamped = axis.clamp(-1.0, 1.0);
    if ((clamped - _moveAxis).abs() > 0.001) {
      _moveAxis = clamped;
      onMoveChanged?.call(_moveAxis);
    }
  }

  void pressJump() {
    _isJumpHeld = true;
    onJumpPressed?.call();
  }

  void releaseJump() {
    _isJumpHeld = false;
    onJumpReleased?.call();
  }

  void triggerShift() {
    onShiftPressed?.call();
  }

  void triggerPause() {
    onPausePressed?.call();
  }

  void reset() {
    _moveAxis = 0.0;
    _isJumpHeld = false;
    onMoveChanged?.call(0.0);
  }

  bool handleKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final isLeft =
        keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
        keysPressed.contains(LogicalKeyboardKey.keyA);
    final isRight =
        keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
        keysPressed.contains(LogicalKeyboardKey.keyD);

    if (isLeft && !isRight) {
      setMoveAxis(-1.0);
    } else if (isRight && !isLeft) {
      setMoveAxis(1.0);
    } else {
      setMoveAxis(0.0);
    }

    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      if (event.logicalKey == LogicalKeyboardKey.space ||
          event.logicalKey == LogicalKeyboardKey.arrowUp ||
          event.logicalKey == LogicalKeyboardKey.keyW) {
        if (event is KeyDownEvent) pressJump();
        return true;
      } else if (event.logicalKey == LogicalKeyboardKey.shiftLeft ||
          event.logicalKey == LogicalKeyboardKey.shiftRight ||
          event.logicalKey == LogicalKeyboardKey.keyE) {
        if (event is KeyDownEvent) triggerShift();
        return true;
      } else if (event.logicalKey == LogicalKeyboardKey.escape ||
          event.logicalKey == LogicalKeyboardKey.keyP) {
        if (event is KeyDownEvent) triggerPause();
        return true;
      } else if (isLeft || isRight) {
        return true;
      }
    } else if (event is KeyUpEvent) {
      if (event.logicalKey == LogicalKeyboardKey.space ||
          event.logicalKey == LogicalKeyboardKey.arrowUp ||
          event.logicalKey == LogicalKeyboardKey.keyW) {
        releaseJump();
        return true;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
          event.logicalKey == LogicalKeyboardKey.keyA ||
          event.logicalKey == LogicalKeyboardKey.arrowRight ||
          event.logicalKey == LogicalKeyboardKey.keyD) {
        return true;
      }
    }

    return false;
  }
}
