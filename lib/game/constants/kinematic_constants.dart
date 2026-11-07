abstract final class KinematicConstants {
  static const double virtualWidth = 560.0;
  static const double virtualHeight = 320.0;

  static const double tileSize = 16.0;
  static const double playerWidth = 14.0;
  static const double playerHeight = 18.0;

  static const double runSpeed = 180.0;
  static const double groundAcceleration = 1200.0;
  static const double groundFriction = 1400.0;
  static const double airAcceleration = 800.0;

  static const double gravityMagnitude = 980.0;
  static const double terminalVelocity = 480.0;
  static const double slingshotVelocityCap = 600.0;

  static const double jumpImpulseMagnitude = 340.0;
  static const double coyoteTime = 0.12;
  static const double jumpBufferTime = 0.10;
  static const double variableJumpCut = 0.5;

  static const double apexVelocityThreshold = 40.0;
  static const double apexGravityMultiplier = 0.65;

  static const double wallSlideSpeed = 80.0;
  static const double wallJumpHorizontalImpulse = 220.0;
  static const double wallJumpVerticalImpulse = 300.0;
}
