import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phasedrift/core/domain/domain.dart';
import 'package:phasedrift/ui/ui.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('SplitStopwatch Formatting Logic', () {
    test('formatTime formats zero and standard elapsed milliseconds', () {
      expect(SplitStopwatchView.formatTime(0), equals('00:00.000'));
      expect(SplitStopwatchView.formatTime(14825), equals('00:14.825'));
      expect(SplitStopwatchView.formatTime(65432), equals('01:05.432'));
      expect(SplitStopwatchView.formatTime(3600123), equals('60:00.123'));
    });

    test('formatTime gracefully handles negative values', () {
      expect(SplitStopwatchView.formatTime(-500), equals('00:00.000'));
    });

    test('formatDelta formats positive and negative time deltas', () {
      expect(SplitStopwatchView.formatDelta(-1240), equals('-01.240'));
      expect(SplitStopwatchView.formatDelta(850), equals('+00.850'));
      expect(SplitStopwatchView.formatDelta(-62400), equals('-1:02.400'));
      expect(SplitStopwatchView.formatDelta(65100), equals('+1:05.100'));
    });
  });

  group('InputController Logic', () {
    test('clamps and dispatches move axis changes', () {
      final dispatched = <double>[];
      final controller = InputController(
        onMoveChanged: (axis) => dispatched.add(axis),
      );

      controller.setMoveAxis(0.5);
      expect(controller.moveAxis, closeTo(0.5, 0.001));

      controller.setMoveAxis(1.5);
      expect(controller.moveAxis, equals(1.0));

      controller.setMoveAxis(-2.0);
      expect(controller.moveAxis, equals(-1.0));

      controller.setMoveAxis(-1.0); // Duplicate should not dispatch again
      expect(dispatched, equals([0.5, 1.0, -1.0]));
    });

    test('tracks jump state and dispatches callbacks', () {
      var jumped = false;
      var released = false;

      final controller = InputController(
        onJumpPressed: () => jumped = true,
        onJumpReleased: () => released = true,
      );

      expect(controller.isJumpHeld, isFalse);

      controller.pressJump();
      expect(controller.isJumpHeld, isTrue);
      expect(jumped, isTrue);

      controller.releaseJump();
      expect(controller.isJumpHeld, isFalse);
      expect(released, isTrue);
    });

    test('reset clears move axis and jump held states', () {
      double? lastMove;
      final controller = InputController(
        onMoveChanged: (axis) => lastMove = axis,
      );

      controller.setMoveAxis(1.0);
      controller.pressJump();
      expect(controller.moveAxis, equals(1.0));
      expect(controller.isJumpHeld, isTrue);

      controller.reset();
      expect(controller.moveAxis, equals(0.0));
      expect(controller.isJumpHeld, isFalse);
      expect(lastMove, equals(0.0));
    });

    test('dispatches shift, pause, and restart callbacks', () {
      var shifted = false;
      var paused = false;
      var restarted = false;

      final controller = InputController(
        onShiftPressed: () => shifted = true,
        onPausePressed: () => paused = true,
        onRestartPressed: () => restarted = true,
      );

      controller.triggerShift();
      controller.triggerPause();

      // Test R key down event triggers restart callback
      final keyEvent = KeyDownEvent(
        physicalKey: PhysicalKeyboardKey.keyR,
        logicalKey: LogicalKeyboardKey.keyR,
        timeStamp: Duration.zero,
      );
      final handled = controller.handleKeyEvent(keyEvent, {
        LogicalKeyboardKey.keyR,
      });

      expect(shifted, isTrue);
      expect(paused, isTrue);
      expect(restarted, isTrue);
      expect(handled, isTrue);
    });
  });

  group('HUD Component States', () {
    test('PhaseIndicator correctly identifies phase properties', () {
      const solarIndicator = PhaseIndicator(phase: SolarPhase());
      expect(solarIndicator.isSolar, isTrue);

      const voidIndicator = PhaseIndicator(phase: VoidPhase());
      expect(voidIndicator.isSolar, isFalse);
    });
  });
}
