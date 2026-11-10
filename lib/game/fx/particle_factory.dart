import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/theme.dart';

class ChromaticShockwave extends PositionComponent {
  ChromaticShockwave({
    required Vector2 position,
    required this.primaryColor,
    required this.accentColor,
    this.speed = 600.0,
    this.lifetime = 0.15,
  }) : super(position: position, anchor: Anchor.center);

  final Color primaryColor;
  final Color accentColor;
  final double speed;
  final double lifetime;

  double _elapsed = 0.0;
  double _radius = 0.0;

  final Paint _innerPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0;

  final Paint _outerPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4.0;

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    _radius += speed * dt;

    if (_elapsed >= lifetime) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final alpha = (1.0 - (_elapsed / lifetime)).clamp(0.0, 1.0);

    _innerPaint.color = accentColor.withValues(alpha: alpha * 0.8);
    _outerPaint.color = primaryColor.withValues(alpha: alpha * 0.5);

    canvas.drawCircle(Offset.zero, _radius, _outerPaint);
    canvas.drawCircle(Offset.zero, _radius * 0.85, _innerPaint);
  }
}

class SparkParticle extends PositionComponent {
  SparkParticle({
    required Vector2 position,
    required this.velocity,
    required this.color,
    this.radius = 2.0,
    this.lifetime = 0.35,
    this.gravity = 300.0,
  }) : super(position: position, anchor: Anchor.center);

  final Vector2 velocity;
  final Color color;
  final double radius;
  final double lifetime;
  final double gravity;

  double _elapsed = 0.0;
  final Paint _paint = Paint()..style = PaintingStyle.fill;

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;

    velocity.y += gravity * dt;
    position += velocity * dt;

    if (_elapsed >= lifetime) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final progress = (_elapsed / lifetime).clamp(0.0, 1.0);
    final alpha = 1.0 - progress;
    final currentRadius = radius * (1.0 - 0.4 * progress);

    _paint.color = color.withValues(alpha: alpha);
    canvas.drawCircle(Offset.zero, currentRadius, _paint);
  }
}

abstract final class ParticleFactory {
  static final _rand = math.Random();

  static ChromaticShockwave createShockwave({
    required Vector2 center,
    required Color primaryColor,
    required Color accentColor,
  }) {
    return ChromaticShockwave(
      position: center,
      primaryColor: primaryColor,
      accentColor: accentColor,
    );
  }

  static List<SparkParticle> createLandingBurst({
    required Vector2 position,
    required Color color,
    int count = 8,
  }) {
    final list = <SparkParticle>[];
    for (var i = 0; i < count; i++) {
      final speed = 80.0 + _rand.nextDouble() * 120.0;
      final angle = -math.pi / 2 + (_rand.nextDouble() - 0.5) * 1.6;
      final vx = math.cos(angle) * speed;
      final vy = math.sin(angle) * speed;

      list.add(
        SparkParticle(
          position: position.clone(),
          velocity: Vector2(vx, vy),
          color: color,
          radius: 1.5 + _rand.nextDouble() * 1.5,
          lifetime: 0.2 + _rand.nextDouble() * 0.15,
          gravity: 400.0,
        ),
      );
    }
    return list;
  }

  static List<SparkParticle> createDeathBurst({
    required Vector2 position,
    int count = 24,
  }) {
    final list = <SparkParticle>[];
    for (var i = 0; i < count; i++) {
      final angle = _rand.nextDouble() * 2 * math.pi;
      final speed = 100.0 + _rand.nextDouble() * 220.0;
      final vx = math.cos(angle) * speed;
      final vy = math.sin(angle) * speed;
      final color = _rand.nextBool()
          ? AppColors.hazardRed
          : AppColors.solarGold;

      list.add(
        SparkParticle(
          position: position.clone(),
          velocity: Vector2(vx, vy),
          color: color,
          radius: 2.0 + _rand.nextDouble() * 2.0,
          lifetime: 0.35 + _rand.nextDouble() * 0.25,
          gravity: 200.0,
        ),
      );
    }
    return list;
  }

  static List<SparkParticle> createShardSparkles({
    required Vector2 position,
    int count = 12,
  }) {
    final list = <SparkParticle>[];
    for (var i = 0; i < count; i++) {
      final angle = _rand.nextDouble() * 2 * math.pi;
      final speed = 60.0 + _rand.nextDouble() * 100.0;
      final vx = math.cos(angle) * speed;
      final vy = math.sin(angle) * speed;

      list.add(
        SparkParticle(
          position: position.clone(),
          velocity: Vector2(vx, vy),
          color: AppColors.chronoShard,
          radius: 2.0,
          lifetime: 0.3 + _rand.nextDouble() * 0.2,
          gravity: 100.0,
        ),
      );
    }
    return list;
  }
}
