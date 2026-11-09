import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../core/domain/domain.dart';
import '../../core/services/services.dart';
import '../../core/theme/theme.dart';

class MilestoneToastOverlay extends StatefulWidget {
  const MilestoneToastOverlay({super.key});

  @override
  State<MilestoneToastOverlay> createState() => _MilestoneToastOverlayState();
}

class _MilestoneToastOverlayState extends State<MilestoneToastOverlay>
    with SingleTickerProviderStateMixin {
  StreamSubscription<Milestone>? _sub;
  Milestone? _currentMilestone;
  Timer? _dismissTimer;
  late final AnimationController _animCtrl;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0.0, -1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));

    _sub = MilestoneService.instance.onMilestoneUnlocked.listen(_onMilestone);
  }

  void _onMilestone(Milestone milestone) {
    _dismissTimer?.cancel();
    setState(() {
      _currentMilestone = milestone;
    });
    _animCtrl.forward(from: 0.0);

    _dismissTimer = Timer(const Duration(milliseconds: 3500), () {
      if (mounted) {
        _animCtrl.reverse().then((_) {
          if (mounted) setState(() => _currentMilestone = null);
        });
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _dismissTimer?.cancel();
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentMilestone == null) return const SizedBox.shrink();
    final milestone = _currentMilestone!;

    return Align(
      alignment: Alignment.topCenter,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: SlideTransition(
            position: _slideAnim,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10.0,
              ),
              constraints: const BoxConstraints(maxWidth: 420.0),
              decoration: ShapeDecoration(
                color: AppColors.canvasDark.withValues(alpha: 0.95),
                shape: AppDecorations.chamferShape(
                  chamfer: AppDecorations.chamferMd,
                  borderColor: milestone.tier.color,
                  borderWidth: 1.5,
                ),
                shadows: [
                  BoxShadow(
                    color: milestone.tier.color.withValues(alpha: 0.35),
                    blurRadius: 20.0,
                    spreadRadius: 2.0,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6.0),
                    decoration: ShapeDecoration(
                      color: milestone.tier.color.withValues(alpha: 0.20),
                      shape: AppDecorations.chamferShape(
                        chamfer: AppDecorations.chamferXs,
                        borderColor: milestone.tier.color,
                      ),
                    ),
                    child: Icon(
                      Icons.emoji_events,
                      color: milestone.tier.color,
                      size: 20.0,
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'MILESTONE UNLOCKED // ',
                              style: AppTypography.telemetryLabel.copyWith(
                                color: milestone.tier.color,
                                fontSize: 9.0,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              milestone.tier.label,
                              style: AppTypography.telemetryLabel.copyWith(
                                color: AppColors.onSurface,
                                fontSize: 9.0,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          milestone.title,
                          style: AppTypography.button.copyWith(
                            color: AppColors.onSurface,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
