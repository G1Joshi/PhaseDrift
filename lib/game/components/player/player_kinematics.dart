import '../../../core/domain/domain.dart';
import '../../constants/kinematic_constants.dart';

class PlayerKinematics {
  PlayerKinematics({
    this.x = 0.0,
    this.y = 0.0,
    this.vx = 0.0,
    this.vy = 0.0,
    this.phase = const SolarPhase(),
  });

  double x;
  double y;
  double vx;
  double vy;
  GamePhase phase;

  bool isGrounded = false;
  bool isTouchingWallLeft = false;
  bool isTouchingWallRight = false;

  double coyoteTimer = 0.0;
  double jumpBufferTimer = 0.0;

  bool get isSolar => phase is SolarPhase;

  void triggerShift() {
    phase = phase.toggle();
    isGrounded = false;
    coyoteTimer = 0.0;
  }

  void pressJump() {
    jumpBufferTimer = KinematicConstants.jumpBufferTime;
    _evaluateJump();
  }

  void releaseJump() {
    if (isSolar && vy < 0) {
      vy *= KinematicConstants.variableJumpCut;
    } else if (!isSolar && vy > 0) {
      vy *= KinematicConstants.variableJumpCut;
    }
  }

  void setGrounded(bool grounded) {
    isGrounded = grounded;
    if (grounded) {
      coyoteTimer = KinematicConstants.coyoteTime;
      if (jumpBufferTimer > 0) {
        _executeJump();
      }
    }
  }

  void update(double dt, {required double moveAxis}) {
    if (jumpBufferTimer > 0) {
      jumpBufferTimer -= dt;
      if (jumpBufferTimer < 0) jumpBufferTimer = 0;
    }

    if (!isGrounded && coyoteTimer > 0) {
      coyoteTimer -= dt;
      if (coyoteTimer < 0) coyoteTimer = 0;
    }

    _updateHorizontal(dt, moveAxis);
    _updateVertical(dt);

    x += vx * dt;
    y += vy * dt;
  }

  void _updateHorizontal(double dt, double moveAxis) {
    if (moveAxis != 0) {
      final targetVx = moveAxis.sign * KinematicConstants.runSpeed;
      final accel = isGrounded
          ? KinematicConstants.groundAcceleration
          : KinematicConstants.airAcceleration;

      if (vx < targetVx) {
        vx = (vx + accel * dt).clamp(-KinematicConstants.runSpeed, targetVx);
      } else if (vx > targetVx) {
        vx = (vx - accel * dt).clamp(targetVx, KinematicConstants.runSpeed);
      }
    } else {
      if (vx > 0) {
        vx = (vx - KinematicConstants.groundFriction * dt).clamp(0.0, vx);
      } else if (vx < 0) {
        vx = (vx + KinematicConstants.groundFriction * dt).clamp(vx, 0.0);
      }
    }
  }

  void _updateVertical(double dt) {
    final baseGravity =
        KinematicConstants.gravityMagnitude * phase.gravityMultiplier;
    final isAtApex = vy.abs() < KinematicConstants.apexVelocityThreshold;
    final effectiveGravity = isAtApex
        ? baseGravity * KinematicConstants.apexGravityMultiplier
        : baseGravity;

    vy += effectiveGravity * dt;

    if (isSolar) {
      vy = vy.clamp(
        -KinematicConstants.slingshotVelocityCap,
        KinematicConstants.terminalVelocity,
      );
    } else {
      vy = vy.clamp(
        -KinematicConstants.terminalVelocity,
        KinematicConstants.slingshotVelocityCap,
      );
    }
  }

  void _evaluateJump() {
    if (isGrounded || coyoteTimer > 0) {
      _executeJump();
    } else if (isTouchingWallLeft || isTouchingWallRight) {
      _executeWallJump();
    }
  }

  void _executeJump() {
    vy = isSolar
        ? -KinematicConstants.jumpImpulseMagnitude
        : KinematicConstants.jumpImpulseMagnitude;
    isGrounded = false;
    coyoteTimer = 0.0;
    jumpBufferTimer = 0.0;
  }

  void _executeWallJump() {
    final horizontalDir = isTouchingWallLeft ? 1.0 : -1.0;
    vx = horizontalDir * KinematicConstants.wallJumpHorizontalImpulse;
    vy = isSolar
        ? -KinematicConstants.wallJumpVerticalImpulse
        : KinematicConstants.wallJumpVerticalImpulse;
    isGrounded = false;
    coyoteTimer = 0.0;
    jumpBufferTimer = 0.0;
  }
}
