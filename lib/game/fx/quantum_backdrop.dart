import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import '../../core/theme/theme.dart';
import '../levels/chamber_definition.dart';
import '../phasedrift_game.dart';

class QuantumBackdrop extends PositionComponent
    with HasGameReference<PhaseDriftGame> {
  QuantumBackdrop({
    required double width,
    required double height,
    this.tier = ChamberTier.veryEasy,
  }) : super(
         position: Vector2.zero(),
         size: Vector2(width, height),
         priority: -100,
       ) {
    final rng = math.Random(1337 + tier.index * 777);
    final count = (width / 20.0).clamp(24, 96).toInt();
    for (var i = 0; i < count; i++) {
      _particles.add(
        _AmbientParticle(
          x: rng.nextDouble() * width,
          y: rng.nextDouble() * height,
          speed: 12.0 + rng.nextDouble() * 28.0,
          radius: 1.0 + rng.nextDouble() * 1.8,
          phaseOffset: rng.nextDouble() * math.pi * 2,
        ),
      );
    }
  }

  final ChamberTier tier;
  final List<_AmbientParticle> _particles = [];
  double _phaseLerp = 0.0;
  double _elapsed = 0.0;

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;

    final targetLerp = game.isLoaded && !game.player.kinematics.isSolar
        ? 1.0
        : 0.0;
    _phaseLerp += (targetLerp - _phaseLerp) * (dt * 6.0);

    for (final p in _particles) {
      p.y -= p.speed * dt * (targetLerp > 0.5 ? -1.0 : 1.0);
      if (p.y < 0) p.y += size.y;
      if (p.y > size.y) p.y -= size.y;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // 1. Deep Space Base
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final bgPaint = Paint()..color = AppColors.obsidianVoid;
    canvas.drawRect(rect, bgPaint);

    // 2. Sector Ambient Glow Vignette
    final nebulaPaint = Paint()
      ..shader = Gradient.radial(
        Offset(size.x * 0.5, size.y * 0.5),
        size.x * 0.75,
        [tier.color.withValues(alpha: 0.07), const Color(0x00000000)],
      );
    canvas.drawRect(rect, nebulaPaint);

    // 3. High-Contrast Dual-Reality Grid
    final realityGrid = Color.lerp(
      AppColors.solarAmber.withValues(alpha: 0.06),
      AppColors.voidCyan.withValues(alpha: 0.06),
      _phaseLerp,
    )!;
    final gridColor = Color.lerp(
      realityGrid,
      tier.color.withValues(alpha: 0.05),
      0.35,
    )!;

    final gridPaint = Paint()
      ..color = gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const cellSize = 32.0;
    for (var x = 0.0; x <= size.x; x += cellSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.y), gridPaint);
    }
    for (var y = 0.0; y <= size.y; y += cellSize) {
      canvas.drawLine(Offset(0, y), Offset(size.x, y), gridPaint);
    }

    // 4. Ambient Drifting Quantum Embers
    final emberColor = Color.lerp(
      AppColors.solarAmber.withValues(alpha: 0.45),
      AppColors.voidCyan.withValues(alpha: 0.45),
      _phaseLerp,
    )!;
    final particleColor = Color.lerp(
      emberColor,
      tier.color.withValues(alpha: 0.60),
      0.25,
    )!;

    final particlePaint = Paint()..color = particleColor;
    for (final p in _particles) {
      final osc = math.sin(_elapsed * 2.0 + p.phaseOffset) * 2.0;
      canvas.drawCircle(Offset(p.x + osc, p.y), p.radius, particlePaint);
    }
  }
}

class _AmbientParticle {
  _AmbientParticle({
    required this.x,
    required this.y,
    required this.speed,
    required this.radius,
    required this.phaseOffset,
  });

  double x;
  double y;
  final double speed;
  final double radius;
  final double phaseOffset;
}
