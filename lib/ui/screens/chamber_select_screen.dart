import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/domain/domain.dart';
import '../../core/services/services.dart';
import '../../core/theme/theme.dart';
import '../../game/levels/levels.dart';
import '../hud/split_stopwatch.dart';
import '../overlays/milestones_dialog.dart';

class ChamberSelectScreen extends StatefulWidget {
  const ChamberSelectScreen({
    super.key,
    required this.onSelectChamber,
    this.onBack,
    this.initialSector,
  });

  final ValueChanged<ChamberDefinition> onSelectChamber;
  final VoidCallback? onBack;
  final ChamberTier? initialSector;

  @override
  State<ChamberSelectScreen> createState() => _ChamberSelectScreenState();
}

class _ChamberSelectScreenState extends State<ChamberSelectScreen> {
  final List<ChamberDefinition> _chambers = ChamberRegistry.allChambers;
  final FocusNode _focusNode = FocusNode();
  Map<int, ChamberRecord> _records = {};
  ChamberTier? _selectedSector;
  int _unlockedMilestonesCount = 0;
  int _focusedSector = 0;
  int _focusedChamberIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedSector = widget.initialSector;
    _loadProgress();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadProgress() async {
    final list = await ProgressionService.instance.loadAllRecords(
      _chambers.length,
    );
    final count = await MilestoneService.instance.getUnlockedCount();
    if (!mounted) return;
    setState(() {
      _records = {for (final r in list) r.chamberId: r};
      _unlockedMilestonesCount = count;
      _isLoading = false;
    });
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    if (event.logicalKey == LogicalKeyboardKey.keyM) {
      MilestonesDialog.show(context);
      return;
    }

    if (_selectedSector == null) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
          event.logicalKey == LogicalKeyboardKey.keyS) {
        setState(() => _focusedSector = (_focusedSector + 2).clamp(0, 5));
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
          event.logicalKey == LogicalKeyboardKey.keyW) {
        setState(() => _focusedSector = (_focusedSector - 2).clamp(0, 5));
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
          event.logicalKey == LogicalKeyboardKey.keyD) {
        setState(() => _focusedSector = (_focusedSector + 1).clamp(0, 5));
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
          event.logicalKey == LogicalKeyboardKey.keyA) {
        setState(() => _focusedSector = (_focusedSector - 1).clamp(0, 5));
      } else if (event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.space) {
        setState(() {
          _selectedSector = _focusedSector == 5
              ? ChamberTier.endless
              : ChamberTier.values[_focusedSector];
          _focusedChamberIndex = 0;
        });
      } else if (event.logicalKey == LogicalKeyboardKey.escape ||
          event.logicalKey == LogicalKeyboardKey.backspace) {
        widget.onBack?.call();
      }
    } else {
      final displayed = _chambers
          .where((c) => c.tier == _selectedSector)
          .toList();
      final showQuantum = _selectedSector == ChamberTier.endless;
      final totalItems = displayed.length + (showQuantum ? 1 : 0);

      if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
          event.logicalKey == LogicalKeyboardKey.keyD) {
        setState(
          () => _focusedChamberIndex = (_focusedChamberIndex + 1).clamp(
            0,
            totalItems - 1,
          ),
        );
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
          event.logicalKey == LogicalKeyboardKey.keyA) {
        setState(
          () => _focusedChamberIndex = (_focusedChamberIndex - 1).clamp(
            0,
            totalItems - 1,
          ),
        );
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
          event.logicalKey == LogicalKeyboardKey.keyS) {
        setState(
          () => _focusedChamberIndex = (_focusedChamberIndex + 2).clamp(
            0,
            totalItems - 1,
          ),
        );
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
          event.logicalKey == LogicalKeyboardKey.keyW) {
        setState(
          () => _focusedChamberIndex = (_focusedChamberIndex - 2).clamp(
            0,
            totalItems - 1,
          ),
        );
      } else if (event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.space) {
        if (_focusedChamberIndex < displayed.length) {
          final c = displayed[_focusedChamberIndex];
          final firstInSector = ProgressionService.isFirstChamberOfSector(
            c.chamberId,
          );
          final isUnlocked =
              (_records[c.chamberId]?.isUnlocked ?? false) || firstInSector;
          if (isUnlocked) {
            widget.onSelectChamber(c);
          }
        } else if (showQuantum) {
          widget.onSelectChamber(ChamberRegistry.getRandomChamber());
        }
      } else if (event.logicalKey == LogicalKeyboardKey.escape ||
          event.logicalKey == LogicalKeyboardKey.backspace) {
        setState(() => _selectedSector = null);
      }
    }
  }

  int _getSectorClearedCount(ChamberTier tier) {
    final sectorChambers = _chambers.where((c) => c.tier == tier);
    return sectorChambers
        .where((c) => _records[c.chamberId]?.isCleared ?? false)
        .length;
  }

  int _getSectorShardsCount(ChamberTier tier) {
    final sectorChambers = _chambers.where((c) => c.tier == tier);
    return sectorChambers.fold(
      0,
      (sum, c) => sum + (_records[c.chamberId]?.shardCount ?? 0),
    );
  }

  Widget _buildSectorCard(ChamberTier tier, {bool isFocused = false}) {
    final clearedCount = _getSectorClearedCount(tier);
    final shardsCount = _getSectorShardsCount(tier);
    final sectorNumber = tier.index + 1;
    final firstChamberId = (tier.index * 10) + 1;
    final lastChamberId = (tier.index + 1) * 10;

    final (sectorTitle, sectorTagline) = switch (tier) {
      ChamberTier.veryEasy => ('SOLAR DAWN', 'Induction & Acceleration'),
      ChamberTier.easy => ('VOID CHASM', 'Inversion & Ceiling Strides'),
      ChamberTier.medium => ('TACHYON SURGE', 'Momentum & Slingshots'),
      ChamberTier.hard => ('PULSAR RIFT', 'Polarity Chains & Gauntlets'),
      ChamberTier.veryHard => ('GRAND SINGULARITY', 'Apex Mastery & Finale'),
      ChamberTier.endless => ('QUANTUM DRIFT', 'Infinite Procedural Synthesis'),
    };

    final isFullyCleared = clearedCount == 10;
    final borderColor = isFocused
        ? AppColors.voidCyan
        : (isFullyCleared ? tier.color : AppColors.border);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedSector = tier;
            _focusedChamberIndex = 0;
          });
        },
        customBorder: AppDecorations.chamferShape(
          chamfer: AppDecorations.chamferMd,
        ),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: ShapeDecoration(
            color: AppColors.cardSurface,
            shape: AppDecorations.chamferShape(
              chamfer: AppDecorations.chamferMd,
              borderColor: borderColor,
              borderWidth: isFocused ? 2.0 : (isFullyCleared ? 1.5 : 1.0),
            ),
            shadows: isFocused
                ? [
                    BoxShadow(
                      color: AppColors.voidCyan.withValues(alpha: 0.45),
                      blurRadius: 20.0,
                      spreadRadius: 1.0,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: tier.color.withValues(alpha: 0.12),
                      blurRadius: 16.0,
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Row: Sector Code & First Chamber Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'SECTOR 0$sectorNumber',
                    style: AppTypography.telemetryLabel.copyWith(
                      color: tier.color,
                      fontWeight: FontWeight.w700,
                      fontSize: 10.0,
                    ),
                  ),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5.0,
                        vertical: 1.5,
                      ),
                      decoration: ShapeDecoration(
                        color: AppColors.interactiveModule,
                        shape: AppDecorations.chamferShape(
                          chamfer: AppDecorations.chamferXs,
                          borderColor: AppColors.solarAmber,
                        ),
                      ),
                      child: Text(
                        'CH ${firstChamberId.toString().padLeft(2, '0')}',
                        style: AppTypography.telemetryLabel.copyWith(
                          color: AppColors.solarAmber,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),

              // Title and Tagline
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4.0,
                          vertical: 1.0,
                        ),
                        margin: const EdgeInsets.only(right: 6.0),
                        decoration: ShapeDecoration(
                          color: tier.color.withValues(alpha: 0.15),
                          shape: AppDecorations.chamferShape(
                            chamfer: AppDecorations.chamferXs,
                            borderColor: tier.color,
                          ),
                        ),
                        child: Text(
                          tier.label,
                          style: AppTypography.telemetryLabel.copyWith(
                            color: tier.color,
                            fontSize: 7.0,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          sectorTitle,
                          style: AppTypography.sectionHeader.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3.0),
                  Text(
                    sectorTagline,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 10.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    'CHAMBERS ${firstChamberId.toString().padLeft(3, '0')}–${lastChamberId.toString().padLeft(3, '0')}',
                    style: AppTypography.telemetryLabel.copyWith(
                      color: tier.color.withValues(alpha: 0.8),
                      fontSize: 9.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              // Bottom Stats / Progress Bar
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$clearedCount/10 CLEARED',
                        style: AppTypography.telemetryLabel.copyWith(
                          color: isFullyCleared
                              ? tier.color
                              : AppColors.onSurface,
                          fontWeight: FontWeight.w700,
                          fontSize: 9.5,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.diamond,
                            size: 12.0,
                            color: AppColors.chronoShard,
                          ),
                          const SizedBox(width: 3.0),
                          Text(
                            '$shardsCount/30',
                            style: AppTypography.telemetryLabel.copyWith(
                              color: AppColors.chronoShard,
                              fontWeight: FontWeight.w700,
                              fontSize: 9.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4.0),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(1.5),
                    child: LinearProgressIndicator(
                      value: clearedCount / 10.0,
                      backgroundColor: AppColors.interactiveModule,
                      valueColor: AlwaysStoppedAnimation<Color>(tier.color),
                      minHeight: 3.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChamberCard(
    ChamberDefinition chamber, {
    bool isFocused = false,
  }) {
    final firstInSector = ProgressionService.isFirstChamberOfSector(
      chamber.chamberId,
    );
    final record =
        _records[chamber.chamberId] ??
        ChamberRecord.initial(chamber.chamberId, isUnlocked: firstInSector);
    final isUnlocked = record.isUnlocked || firstInSector;
    final isCleared = record.isCleared;

    ChamberRank? rank;
    if (isCleared && record.bestTimeMs != null) {
      rank = ChamberRank.calculate(
        completionTimeMs: record.bestTimeMs!,
        parTimeMs: chamber.parTimeMs,
        shardCount: record.shardCount,
      );
    }

    final borderColor = isFocused
        ? AppColors.voidCyan
        : (isCleared
              ? (rank?.color ?? AppColors.voidCyan)
              : (isUnlocked ? AppColors.border : AppColors.structuralSeam));

    final chamberCode =
        'CHAMBER ${chamber.chamberId.toString().padLeft(2, '0')}';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isUnlocked ? () => widget.onSelectChamber(chamber) : null,
        customBorder: AppDecorations.chamferShape(
          chamfer: AppDecorations.chamferMd,
        ),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: ShapeDecoration(
            color: isUnlocked
                ? AppColors.cardSurface
                : AppColors.canvasDark.withValues(alpha: 0.5),
            shape: AppDecorations.chamferShape(
              chamfer: AppDecorations.chamferMd,
              borderColor: borderColor,
              borderWidth: isFocused ? 2.0 : (isCleared ? 1.5 : 1.0),
            ),
            shadows: isFocused
                ? [
                    BoxShadow(
                      color: AppColors.voidCyan.withValues(alpha: 0.45),
                      blurRadius: 20.0,
                      spreadRadius: 1.0,
                    ),
                  ]
                : (isCleared && rank != null
                      ? [
                          BoxShadow(
                            color: rank.color.withValues(alpha: 0.15),
                            blurRadius: 16.0,
                          ),
                        ]
                      : null),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Row: Chamber Code & Status/Rank
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    chamberCode,
                    style: AppTypography.telemetryLabel.copyWith(
                      color: isUnlocked
                          ? AppColors.onSurfaceVariant
                          : AppColors.structuralSeam,
                      fontWeight: FontWeight.w700,
                      fontSize: 10.0,
                    ),
                  ),
                  if (!isUnlocked)
                    const Icon(
                      Icons.lock,
                      size: 14.0,
                      color: AppColors.structuralSeam,
                    )
                  else if (rank != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6.0,
                        vertical: 1.5,
                      ),
                      decoration: ShapeDecoration(
                        color: AppColors.interactiveModule,
                        shape: AppDecorations.chamferShape(
                          chamfer: AppDecorations.chamferXs,
                          borderColor: rank.color,
                        ),
                      ),
                      child: Text(
                        'RANK ${rank.label}',
                        style: AppTypography.telemetryLabel.copyWith(
                          color: rank.color,
                          fontWeight: FontWeight.w800,
                          fontSize: 9.0,
                        ),
                      ),
                    ),
                ],
              ),

              // Title and Topology Archetype Badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4.0,
                          vertical: 1.0,
                        ),
                        margin: const EdgeInsets.only(right: 6.0),
                        decoration: ShapeDecoration(
                          color: chamber.tier.color.withValues(alpha: 0.15),
                          shape: AppDecorations.chamferShape(
                            chamfer: AppDecorations.chamferXs,
                            borderColor: chamber.tier.color,
                          ),
                        ),
                        child: Text(
                          chamber.topologyName,
                          style: AppTypography.telemetryLabel.copyWith(
                            color: chamber.tier.color,
                            fontSize: 7.0,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          chamber.name.toUpperCase(),
                          style: AppTypography.sectionHeader.copyWith(
                            color: isUnlocked
                                ? AppColors.onSurface
                                : AppColors.onSurfaceVariant.withValues(
                                    alpha: 0.4,
                                  ),
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    chamber.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmall.copyWith(
                      color: isUnlocked
                          ? AppColors.onSurfaceVariant
                          : AppColors.structuralSeam,
                      fontSize: 11.0,
                    ),
                  ),
                ],
              ),

              // Bottom Stats / Best Time & Shards
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: isCleared && record.bestTimeMs != null
                        ? Text(
                            SplitStopwatchView.formatTime(record.bestTimeMs!),
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.telemetryValueSm.copyWith(
                              color: rank?.color ?? AppColors.onSurface,
                            ),
                          )
                        : Text(
                            'PAR ${SplitStopwatchView.formatTime(chamber.parTimeMs)}',
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.telemetryLabel.copyWith(
                              color: AppColors.structuralSeam,
                            ),
                          ),
                  ),
                  if (isUnlocked)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(3, (index) {
                        final hasShard = record.hasShard(index);
                        return Padding(
                          padding: const EdgeInsets.only(left: 3.0),
                          child: Icon(
                            Icons.diamond,
                            size: 14.0,
                            color: hasShard
                                ? AppColors.chronoShard
                                : AppColors.structuralSeam,
                          ),
                        );
                      }),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuantumDriftCard({bool isFocused = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => widget.onSelectChamber(ChamberRegistry.getRandomChamber()),
        customBorder: AppDecorations.chamferShape(
          chamfer: AppDecorations.chamferMd,
        ),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: ShapeDecoration(
            color: AppColors.cardSurface,
            shape: AppDecorations.chamferShape(
              chamfer: AppDecorations.chamferMd,
              borderColor: AppColors.voidCyan,
              borderWidth: isFocused ? 2.0 : 1.5,
            ),
            shadows: isFocused
                ? [
                    BoxShadow(
                      color: AppColors.voidCyan.withValues(alpha: 0.45),
                      blurRadius: 20.0,
                      spreadRadius: 1.0,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: AppColors.voidCyan.withValues(alpha: 0.20),
                      blurRadius: 16.0,
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6.0,
                      vertical: 2.0,
                    ),
                    decoration: ShapeDecoration(
                      color: AppColors.voidCyan.withValues(alpha: 0.15),
                      shape: AppDecorations.chamferShape(
                        chamfer: AppDecorations.chamferSm,
                        borderColor: AppColors.voidCyan,
                      ),
                    ),
                    child: Text(
                      'ENDLESS ANOMALY',
                      style: AppTypography.telemetryLabel.copyWith(
                        fontSize: 9.0,
                        fontWeight: FontWeight.w700,
                        color: AppColors.voidCyan,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.all_inclusive,
                    size: 16.0,
                    color: AppColors.voidCyan,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'QUANTUM DRIFT',
                    style: AppTypography.button.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    'Procedural Infinite Sector',
                    style: AppTypography.telemetryLabel.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 10.0,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'DYNAMIC SEED',
                    style: AppTypography.telemetryLabel.copyWith(
                      color: AppColors.voidCyan,
                    ),
                  ),
                  const Icon(
                    Icons.play_circle_fill,
                    size: 16.0,
                    color: AppColors.voidCyan,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectorSwitchChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color? color,
  }) {
    final activeColor = color ?? AppColors.voidCyan;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
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

  @override
  Widget build(BuildContext context) {
    final totalShards = _records.values.fold<int>(
      0,
      (sum, r) => sum + r.shardCount,
    );
    final clearedCount = _records.values.where((r) => r.isCleared).length;

    final inSectorView = _selectedSector != null;

    final displayedChambers = inSectorView
        ? _chambers.where((c) => c.tier == _selectedSector).toList()
        : const <ChamberDefinition>[];
    final showQuantumCard = _selectedSector == ChamberTier.endless;
    final chamberGridCount =
        displayedChambers.length + (showQuantumCard ? 1 : 0);

    return Scaffold(
      backgroundColor: AppColors.obsidianVoid,
      body: KeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: _handleKeyEvent,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppColors.onSurface,
                      ),
                      onPressed: () {
                        if (inSectorView) {
                          setState(() => _selectedSector = null);
                        } else {
                          widget.onBack?.call();
                        }
                      },
                    ),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            inSectorView
                                ? _selectedSector!.sectorName
                                : 'CHAMBER MATRIX // SECTOR DIRECTORY',
                            style: AppTypography.titleChamber.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2.0,
                              fontSize: 16.0,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            inSectorView
                                ? 'SECTOR // ${_getSectorClearedCount(_selectedSector!)}/10 CLEARED // ${_getSectorShardsCount(_selectedSector!)}/30 SHARDS'
                                : 'CAMPAIGN // $clearedCount/${_chambers.length} CLEARED // $totalShards/${_chambers.length * 3} SHARDS',
                            style: AppTypography.telemetryLabel.copyWith(
                              color: inSectorView
                                  ? _selectedSector!.color
                                  : AppColors.solarAmber,
                              fontSize: 10.0,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => MilestonesDialog.show(context).then((_) {
                          if (mounted) _loadProgress();
                        }),
                        customBorder: AppDecorations.chamferShape(
                          chamfer: AppDecorations.chamferXs,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 5.0,
                          ),
                          decoration: ShapeDecoration(
                            color: AppColors.cardSurface,
                            shape: AppDecorations.chamferShape(
                              chamfer: AppDecorations.chamferXs,
                              borderColor: AppColors.voidCyan,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.emoji_events,
                                size: 14.0,
                                color: AppColors.solarGold,
                              ),
                              const SizedBox(width: 4.0),
                              Text(
                                '$_unlockedMilestonesCount/16',
                                style: AppTypography.telemetryLabel.copyWith(
                                  color: AppColors.voidCyan,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 9.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),

                // Sector Quick-Switcher Tabs
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildSectorSwitchChip(
                        label: 'ALL SECTORS',
                        isSelected: _selectedSector == null,
                        onTap: () => setState(() => _selectedSector = null),
                      ),
                      for (final tier in [
                        ChamberTier.veryEasy,
                        ChamberTier.easy,
                        ChamberTier.medium,
                        ChamberTier.hard,
                        ChamberTier.veryHard,
                      ]) ...[
                        const SizedBox(width: 8.0),
                        _buildSectorSwitchChip(
                          label: 'SEC 0${tier.index + 1}: ${tier.label}',
                          isSelected: _selectedSector == tier,
                          onTap: () => setState(() => _selectedSector = tier),
                          color: tier.color,
                        ),
                      ],
                      const SizedBox(width: 8.0),
                      _buildSectorSwitchChip(
                        label: 'QUANTUM DRIFT',
                        isSelected: _selectedSector == ChamberTier.endless,
                        onTap: () => setState(
                          () => _selectedSector = ChamberTier.endless,
                        ),
                        color: ChamberTier.endless.color,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),

                // Content Area: Either Sector Cards OR Chamber Cards
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.solarAmber,
                          ),
                        )
                      : inSectorView
                      // LEVEL 2: CHAMBER GRID FOR SELECTED SECTOR
                      ? LayoutBuilder(
                          builder: (context, constraints) {
                            final crossAxisCount = constraints.maxWidth > 900
                                ? 4
                                : (constraints.maxWidth > 600 ? 3 : 2);
                            return GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: 16.0,
                                    mainAxisSpacing: 16.0,
                                    childAspectRatio: 1.25,
                                  ),
                              itemCount: chamberGridCount,
                              itemBuilder: (context, index) {
                                if (showQuantumCard &&
                                    index == displayedChambers.length) {
                                  return _buildQuantumDriftCard(
                                    isFocused: index == _focusedChamberIndex,
                                  );
                                }
                                final chamber = displayedChambers[index];
                                return _buildChamberCard(
                                  chamber,
                                  isFocused: index == _focusedChamberIndex,
                                );
                              },
                            );
                          },
                        )
                      // LEVEL 1: SECTORS DIRECTORY (EQUAL GRID)
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            final crossAxisCount = constraints.maxWidth > 900
                                ? 4
                                : (constraints.maxWidth > 600 ? 3 : 2);
                            return GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: 16.0,
                                    mainAxisSpacing: 16.0,
                                    childAspectRatio: 1.25,
                                  ),
                              itemCount: 6,
                              itemBuilder: (context, index) {
                                if (index == 5) {
                                  return _buildQuantumDriftCard(
                                    isFocused: index == _focusedSector,
                                  );
                                }
                                final tier = ChamberTier.values[index];
                                return _buildSectorCard(
                                  tier,
                                  isFocused: index == _focusedSector,
                                );
                              },
                            );
                          },
                        ),
                ),
                const SizedBox(height: 10.0),
                Center(
                  child: Text(
                    '[WASD / ARROWS] NAVIGATE  \u2022  [SPACE/ENTER] SELECT  \u2022  [ESC] RETURN  \u2022  [M] BADGES',
                    style: AppTypography.telemetryLabel.copyWith(
                      fontSize: 8.5,
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
