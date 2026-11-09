import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:phasedrift/core/domain/domain.dart';
import 'package:phasedrift/game/game.dart';

void main() {
  group('PlayerKinematics Logic', () {
    test('momentum is preserved across phase shift causing slingshot deceleration', () {
      final kinematics = PlayerKinematics(
        vy: 450.0, // High-speed downward fall in Solar
      );

      expect(kinematics.isSolar, isTrue);
      expect(kinematics.vy, equals(450.0));

      kinematics.triggerShift();

      expect(kinematics.isSolar, isFalse);
      expect(kinematics.vy, equals(450.0)); // Momentum strictly conserved

      // After 0.5s under Void upward gravity (-980 px/s²), velocity decelerates
      kinematics.update(0.5, moveAxis: 0.0);
      expect(kinematics.vy, lessThan(0.0)); // Inverted slingshot launch
    });

    test(
      'coyote time allows jump execution within window after leaving ledge',
      () {
        final kinematics = PlayerKinematics();
        kinematics.setGrounded(true);

        // Walk off ledge
        kinematics.setGrounded(false);
        kinematics.update(0.08, moveAxis: 0.0); // 80ms elapsed (< 120ms coyote)

        kinematics.pressJump();
        expect(kinematics.vy, equals(-KinematicConstants.jumpImpulseMagnitude));
      },
    );

    test('coyote time expires after threshold preventing mid-air jump', () {
      final kinematics = PlayerKinematics();
      kinematics.setGrounded(true);

      // Walk off ledge and let coyote expire
      kinematics.setGrounded(false);
      kinematics.update(0.15, moveAxis: 0.0); // 150ms elapsed (> 120ms coyote)

      kinematics.pressJump();
      expect(
        kinematics.vy,
        greaterThan(0.0),
      ); // Continues falling under gravity
    });

    test('jump buffer executes jump upon touching ground', () {
      final kinematics = PlayerKinematics();
      kinematics.setGrounded(false);
      kinematics.coyoteTimer = 0.0;

      // Press jump in mid-air
      kinematics.pressJump();
      expect(kinematics.vy, equals(0.0)); // Cannot jump yet

      kinematics.update(0.05, moveAxis: 0.0); // 50ms elapsed (< 100ms buffer)

      // Land on surface
      kinematics.setGrounded(true);
      expect(kinematics.vy, equals(-KinematicConstants.jumpImpulseMagnitude));
    });

    test(
      'variable jump cut halves upward velocity when releasing key early',
      () {
        final kinematics = PlayerKinematics();
        kinematics.setGrounded(true);
        kinematics.pressJump();

        expect(kinematics.vy, equals(-KinematicConstants.jumpImpulseMagnitude));

        kinematics.releaseJump();
        expect(
          kinematics.vy,
          equals(
            -KinematicConstants.jumpImpulseMagnitude *
                KinematicConstants.variableJumpCut,
          ),
        );
      },
    );

    test('resolves landing collision and grounds player on floor obstacle', () {
      final kinematics = PlayerKinematics(x: 100.0, y: 190.0, vy: 100.0);
      const floor = Rect.fromLTWH(0.0, 200.0, 300.0, 32.0);

      kinematics.update(0.05, moveAxis: 0.0, solidObstacles: [floor]);

      expect(kinematics.isGrounded, isTrue);
      expect(kinematics.vy, equals(0.0));
      expect(kinematics.y, equals(191.0));
    });

    test(
      'resolves ceiling collision in Solar phase and resets upward velocity',
      () {
        final kinematics = PlayerKinematics(x: 100.0, y: 30.0, vy: -200.0);
        const ceiling = Rect.fromLTWH(0.0, 0.0, 300.0, 16.0);

        kinematics.update(0.05, moveAxis: 0.0, solidObstacles: [ceiling]);

        expect(kinematics.vy, equals(0.0));
        expect(kinematics.y, greaterThanOrEqualTo(25.0));
      },
    );

    test('resolves wall collision and stops horizontal movement', () {
      final kinematics = PlayerKinematics(x: 90.0, y: 191.0, vx: 180.0);
      const wall = Rect.fromLTWH(100.0, 150.0, 16.0, 100.0);

      kinematics.update(0.05, moveAxis: 1.0, solidObstacles: [wall]);

      expect(kinematics.isTouchingWallRight, isTrue);
      expect(kinematics.vx, equals(0.0));
      expect(kinematics.x, equals(93.0));
    });

    test('resolves inverted landing collision in Void phase onto ceiling', () {
      final kinematics = PlayerKinematics(
        x: 100.0,
        y: 30.0,
        vy: -200.0,
        phase: const VoidPhase(),
      );
      const ceilingBridge = Rect.fromLTWH(0.0, 0.0, 300.0, 16.0);

      kinematics.update(0.05, moveAxis: 0.0, solidObstacles: [ceilingBridge]);

      expect(kinematics.isGrounded, isTrue);
      expect(kinematics.vy, equals(0.0));
      expect(kinematics.y, equals(25.0));
    });

    test('ladder allows jump execution when player is on ladder', () {
      final kinematics = PlayerKinematics();
      kinematics.setGrounded(false);
      kinematics.coyoteTimer = 0.0;
      kinematics.isOnLadder = true;

      kinematics.pressJump();
      expect(kinematics.vy, equals(-KinematicConstants.jumpImpulseMagnitude));
    });
  });
}
