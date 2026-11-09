import 'package:material_ui/material_ui.dart';

import '../../core/domain/domain.dart';

class RealityWarpFlash extends StatefulWidget {
  const RealityWarpFlash({super.key, required this.phase});

  final GamePhase phase;

  @override
  State<RealityWarpFlash> createState() => _RealityWarpFlashState();
}

class _RealityWarpFlashState extends State<RealityWarpFlash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _alphaAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _alphaAnim = Tween<double>(
      begin: 0.35,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutQuad));
  }

  @override
  void didUpdateWidget(covariant RealityWarpFlash oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.phase.runtimeType != widget.phase.runtimeType) {
      _ctrl.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _alphaAnim,
        builder: (context, _) {
          if (_alphaAnim.value <= 0.001) return const SizedBox.shrink();
          final flashColor = widget.phase.primaryColor;

          return Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.0,
                colors: [
                  Colors.transparent,
                  flashColor.withValues(alpha: _alphaAnim.value * 0.4),
                  flashColor.withValues(alpha: _alphaAnim.value),
                ],
                stops: const [0.4, 0.8, 1.0],
              ),
            ),
          );
        },
      ),
    );
  }
}
