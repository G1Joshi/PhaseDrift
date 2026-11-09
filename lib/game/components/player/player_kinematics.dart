import 'dart:math' as math;
import 'dart:ui';

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
  bool isOnLadder = false;

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

  void update(
    double dt, {
    required double moveAxis,
    List<Rect> solidObstacles = const [],
  }) {
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

    if (solidObstacles.isEmpty) {
      x += vx * dt;
      y += vy * dt;
      return;
    }

    const halfW = KinematicConstants.playerWidth / 2;
    const halfH = KinematicConstants.playerHeight / 2;

    // 1. Horizontal Movement & Wall Collision Resolution
    final targetX = x + vx * dt;
    isTouchingWallLeft = false;
    isTouchingWallRight = false;

    if (vx != 0) {
      double resolvedX = targetX;
      final sweepXBox = Rect.fromLTWH(
        vx > 0 ? x - halfW : targetX - halfW,
        y - halfH + 1.0,
        halfW * 2 + (targetX - x).abs(),
        halfH * 2 - 2.0,
      );

      for (final obstacle in solidObstacles) {
        if (sweepXBox.overlaps(obstacle)) {
          if (vx > 0) {
            if (x + halfW <= obstacle.left + 2.0) {
              resolvedX = math.min(resolvedX, obstacle.left - halfW);
              isTouchingWallRight = true;
            }
          } else if (vx < 0) {
            if (x - halfW >= obstacle.right - 2.0) {
              resolvedX = math.max(resolvedX, obstacle.right + halfW);
              isTouchingWallLeft = true;
            }
          }
        }
      }

      x = resolvedX;
      if (isTouchingWallLeft || isTouchingWallRight) {
        vx = 0.0;
      }
    } else {
      const wallMargin = 1.5;
      final leftCheck = Rect.fromLTWH(
        x - halfW - wallMargin,
        y - halfH + 1.0,
        wallMargin,
        halfH * 2 - 2.0,
      );
      final rightCheck = Rect.fromLTWH(
        x + halfW,
        y - halfH + 1.0,
        wallMargin,
        halfH * 2 - 2.0,
      );
      for (final obstacle in solidObstacles) {
        if (leftCheck.overlaps(obstacle)) isTouchingWallLeft = true;
        if (rightCheck.overlaps(obstacle)) isTouchingWallRight = true;
      }
    }

    // 2. Wall Slide Handling
    if (!isGrounded && (isTouchingWallLeft || isTouchingWallRight)) {
      if (isSolar && vy > KinematicConstants.wallSlideSpeed) {
        vy = KinematicConstants.wallSlideSpeed;
      } else if (!isSolar && vy < -KinematicConstants.wallSlideSpeed) {
        vy = -KinematicConstants.wallSlideSpeed;
      }
    }

    // 3. Vertical Movement & Surface Collision Resolution
    final targetY = y + vy * dt;
    bool groundedThisFrame = false;

    if (vy != 0) {
      double resolvedY = targetY;
      final sweepYBox = Rect.fromLTWH(
        x - halfW + 1.0,
        vy > 0 ? y - halfH : targetY - halfH,
        halfW * 2 - 2.0,
        halfH * 2 + (targetY - y).abs(),
      );

      for (final obstacle in solidObstacles) {
        if (sweepYBox.overlaps(obstacle)) {
          if (isSolar) {
            if (vy > 0) {
              if (y + halfH <= obstacle.top + 4.0) {
                resolvedY = math.min(resolvedY, obstacle.top - halfH);
                groundedThisFrame = true;
              }
            } else if (vy < 0) {
              if (y - halfH >= obstacle.bottom - 4.0) {
                resolvedY = math.max(resolvedY, obstacle.bottom + halfH);
                vy = 0.0;
              }
            }
          } else {
            if (vy < 0) {
              if (y - halfH >= obstacle.bottom - 4.0) {
                resolvedY = math.max(resolvedY, obstacle.bottom + halfH);
                groundedThisFrame = true;
              }
            } else if (vy > 0) {
              if (y + halfH <= obstacle.top + 4.0) {
                resolvedY = math.min(resolvedY, obstacle.top - halfH);
                vy = 0.0;
              }
            }
          }
        }
      }

      y = resolvedY;
      if (groundedThisFrame) {
        vy = 0.0;
        setGrounded(true);
      } else {
        if (isGrounded) {
          isGrounded = false;
        }
      }
    } else {
      final checkGroundRect = isSolar
          ? Rect.fromLTWH(
              x - halfW + 1.0,
              y + halfH - 1.0,
              halfW * 2 - 2.0,
              3.0,
            )
          : Rect.fromLTWH(
              x - halfW + 1.0,
              y - halfH - 2.0,
              halfW * 2 - 2.0,
              3.0,
            );
      bool onSolid = false;
      for (final obstacle in solidObstacles) {
        if (checkGroundRect.overlaps(obstacle)) {
          onSolid = true;
          break;
        }
      }
      if (onSolid) {
        setGrounded(true);
      } else {
        isGrounded = false;
      }
    }
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
    if (isGrounded || coyoteTimer > 0 || isOnLadder) {
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
