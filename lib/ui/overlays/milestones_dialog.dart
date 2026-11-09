import 'dart:ui';

import 'package:material_ui/material_ui.dart';

import '../../core/domain/domain.dart';
import '../../core/services/services.dart';
import '../../core/theme/theme.dart';

class MilestonesDialog extends StatefulWidget {
  const MilestonesDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierColor: AppColors.obsidianVoid.withValues(alpha: 0.85),
      builder: (_) => const MilestonesDialog(),
    );
  }

  @override
  State<MilestonesDialog> createState() => _MilestonesDialogState();
}

class _MilestonesDialogState extends State<MilestonesDialog> {
  List<Milestone> _milestones = [];
  bool _isLoading = true;
  MilestoneTier? _filterTier;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await MilestoneService.instance.loadMilestones();
    if (mounted) {
      setState(() {
        _milestones = list;
        _isLoading = false;
      });
    }
  }

  IconData _resolveIcon(String iconName) {
    switch (iconName) {
      case 'swap_horiz':
        return Icons.swap_horiz;
      case 'play_arrow':
        return Icons.play_arrow;
      case 'check_circle':
        return Icons.check_circle_outline;
      case 'done_all':
        return Icons.done_all;
      case 'flash_on':
        return Icons.flash_on;
      case 'military_tech':
        return Icons.military_tech;
      case 'workspace_premium':
        return Icons.workspace_premium;
      case 'speed':
        return Icons.speed;
      case 'vertical_align_top':
        return Icons.vertical_align_top;
      case 'diamond':
        return Icons.diamond;
      case 'diamond_outlined':
        return Icons.diamond_outlined;
      case 'auto_awesome':
        return Icons.auto_awesome;
      case 'timer':
        return Icons.timer_outlined;
      case 'stars':
        return Icons.stars;
      case 'shield':
        return Icons.shield_outlined;
      case 'all_inclusive':
        return Icons.all_inclusive;
      default:
        return Icons.emoji_events_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final unlockedCount = _milestones.where((m) => m.isUnlocked).length;
    final totalCount = _milestones.length;
    final progress = totalCount > 0 ? unlockedCount / totalCount : 0.0;

    final displayed = _filterTier == null
        ? _milestones
        : _milestones.where((m) => m.tier == _filterTier).toList();

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 24.0,
          vertical: 32.0,
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 680.0, maxHeight: 600.0),
          decoration: ShapeDecoration(
            color: AppColors.canvasDark.withValues(alpha: 0.95),
            shape: AppDecorations.chamferShape(
              chamfer: AppDecorations.chamferLg,
              borderColor: AppColors.voidCyan,
              borderWidth: 1.5,
            ),
            shadows: [
              BoxShadow(
                color: AppColors.voidCyan.withValues(alpha: 0.20),
                blurRadius: 24.0,
              ),
            ],
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 16.0,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.voidCyan.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.emoji_events,
                          color: AppColors.solarAmber,
                          size: 24.0,
                        ),
                        const SizedBox(width: 12.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TACTICAL MILESTONES',
                              style: AppTypography.titleChamber.copyWith(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                              ),
                            ),
                            Text(
                              'OPERATOR BADGES // $unlockedCount/$totalCount SYNCHRONIZED',
                              style: AppTypography.telemetryLabel.copyWith(
                                color: AppColors.solarAmber,
                                fontSize: 10.0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.onSurface),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              // Progress Bar & Filter Chips
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 12.0,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2.0),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: AppColors.interactiveModule,
                              valueColor: const AlwaysStoppedAnimation(
                                AppColors.voidCyan,
                              ),
                              minHeight: 6.0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: AppTypography.telemetryLabel.copyWith(
                            color: AppColors.voidCyan,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12.0),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(null, 'ALL ($totalCount)'),
                          for (final tier in MilestoneTier.values) ...[
                            const SizedBox(width: 8.0),
                            _buildFilterChip(
                              tier,
                              '${tier.label} (${_milestones.where((m) => m.tier == tier).length})',
                              color: tier.color,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Milestones List
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.voidCyan,
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 8.0,
                        ),
                        itemCount: displayed.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8.0),
                        itemBuilder: (context, index) {
                          final milestone = displayed[index];
                          final isUnlocked = milestone.isUnlocked;
                          return Container(
                            padding: const EdgeInsets.all(12.0),
                            decoration: ShapeDecoration(
                              color: isUnlocked
                                  ? AppColors.cardSurface
                                  : AppColors.interactiveModule.withValues(
                                      alpha: 0.4,
                                    ),
                              shape: AppDecorations.chamferShape(
                                chamfer: AppDecorations.chamferSm,
                                borderColor: isUnlocked
                                    ? milestone.tier.color
                                    : AppColors.structuralSeam,
                                borderWidth: isUnlocked ? 1.0 : 0.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44.0,
                                  height: 44.0,
                                  decoration: ShapeDecoration(
                                    color: isUnlocked
                                        ? milestone.tier.color.withValues(
                                            alpha: 0.15,
                                          )
                                        : AppColors.canvasDark,
                                    shape: AppDecorations.chamferShape(
                                      chamfer: AppDecorations.chamferSm,
                                      borderColor: isUnlocked
                                          ? milestone.tier.color
                                          : AppColors.structuralSeam,
                                    ),
                                  ),
                                  child: Icon(
                                    isUnlocked
                                        ? _resolveIcon(milestone.iconName)
                                        : Icons.lock_outline,
                                    color: isUnlocked
                                        ? milestone.tier.color
                                        : AppColors.structuralSeam,
                                    size: 22.0,
                                  ),
                                ),
                                const SizedBox(width: 14.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            milestone.title,
                                            style: AppTypography.button
                                                .copyWith(
                                                  color: isUnlocked
                                                      ? AppColors.onSurface
                                                      : AppColors
                                                            .onSurfaceVariant
                                                            .withValues(
                                                              alpha: 0.5,
                                                            ),
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 13.0,
                                                ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6.0,
                                              vertical: 2.0,
                                            ),
                                            decoration: ShapeDecoration(
                                              color: milestone.tier.color
                                                  .withValues(alpha: 0.15),
                                              shape:
                                                  AppDecorations.chamferShape(
                                                    chamfer: AppDecorations
                                                        .chamferXs,
                                                    borderColor:
                                                        milestone.tier.color,
                                                  ),
                                            ),
                                            child: Text(
                                              milestone.tier.label,
                                              style: AppTypography
                                                  .telemetryLabel
                                                  .copyWith(
                                                    color: milestone.tier.color,
                                                    fontSize: 8.5,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 3.0),
                                      Text(
                                        milestone.description,
                                        style: AppTypography.telemetryLabel
                                            .copyWith(
                                              color: isUnlocked
                                                  ? AppColors.onSurfaceVariant
                                                  : AppColors.structuralSeam,
                                              fontSize: 11.0,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(MilestoneTier? tier, String label, {Color? color}) {
    final isSelected = _filterTier == tier;
    final activeColor = color ?? AppColors.voidCyan;

    return InkWell(
      onTap: () => setState(() => _filterTier = tier),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
        decoration: ShapeDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.20)
              : AppColors.interactiveModule,
          shape: AppDecorations.chamferShape(
            chamfer: AppDecorations.chamferXs,
            borderColor: isSelected ? activeColor : AppColors.structuralSeam,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.telemetryLabel.copyWith(
            color: isSelected ? activeColor : AppColors.onSurfaceVariant,
            fontSize: 10.0,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
