import 'dart:math' as math;

import 'package:flame/components.dart';

class ScreenShake {
  ScreenShake({
    this.maxOffset = 12.0,
    this.maxAngle = 0.04,
    this.decayRate = 1.8,
    this.reduceMotion = false,
  });

  final double maxOffset;
  final double maxAngle;
  final double decayRate;
  bool reduceMotion;

  double _trauma = 0.0;
  double _time = 0.0;

  double get trauma => _trauma;

  void addTrauma(double amount) {
    if (reduceMotion) return;
    _trauma = (_trauma + amount).clamp(0.0, 1.0);
  }

  void reset() {
    _trauma = 0.0;
    _time = 0.0;
  }

  (Vector2 offset, double angle) update(double dt) {
    if (reduceMotion || _trauma <= 0.0) {
      _trauma = 0.0;
      return (Vector2.zero(), 0.0);
    }

    _time += dt * 35.0; // High frequency oscillation
    _trauma = math.max(0.0, _trauma - decayRate * dt);

    final shake = _trauma * _trauma; // Non-linear quadratic falloff
    final noiseX = math.sin(_time * 1.3) * math.cos(_time * 0.7);
    final noiseY = math.cos(_time * 1.1) * math.sin(_time * 0.9);
    final noiseAngle = math.sin(_time * 0.8);

    final offsetX = maxOffset * shake * noiseX;
    final offsetY = maxOffset * shake * noiseY;
    final angle = maxAngle * shake * noiseAngle;

    return (Vector2(offsetX, offsetY), angle);
  }
}
