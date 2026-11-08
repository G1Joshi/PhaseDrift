import 'package:material_ui/material_ui.dart';

import '../../core/domain/domain.dart';
import '../../core/services/services.dart';
import '../../core/theme/theme.dart';
import '../../game/levels/levels.dart';
import '../hud/split_stopwatch.dart';

class ChamberSelectScreen extends StatefulWidget {
  const ChamberSelectScreen({
    super.key,
    required this.onSelectChamber,
    this.onBack,
  });

  final ValueChanged<ChamberDefinition> onSelectChamber;
  final VoidCallback? onBack;

  @override
  State<ChamberSelectScreen> createState() => _ChamberSelectScreenState();
}

class _ChamberSelectScreenState extends State<ChamberSelectScreen> {
  final List<ChamberDefinition> _chambers = ChamberRegistry.allChambers;
  Map<int, ChamberRecord> _records = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final list = await ProgressionService.instance.loadAllRecords(
      _chambers.length,
    );
    if (!mounted) return;
    setState(() {
      _records = {for (final r in list) r.chamberId: r};
      _isLoading = false;
    });
  }

  Widget _buildChamberCard(ChamberDefinition chamber) {
    final record =
        _records[chamber.chamberId] ??
        ChamberRecord.initial(
          chamber.chamberId,
          isUnlocked: chamber.chamberId == 1,
        );
    final isUnlocked = record.isUnlocked || chamber.chamberId == 1;
    final isCleared = record.isCleared;

    ChamberRank? rank;
    if (isCleared && record.bestTimeMs != null) {
      rank = ChamberRank.calculate(
        completionTimeMs: record.bestTimeMs!,
        parTimeMs: chamber.parTimeMs,
        shardCount: record.shardCount,
      );
    }

    final borderColor = isCleared
        ? (rank?.color ?? AppColors.voidCyan)
        : (isUnlocked ? AppColors.border : AppColors.structuralSeam);

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
              borderWidth: isCleared ? 1.5 : 1.0,
            ),
            shadows: isCleared && rank != null
                ? [
                    BoxShadow(
                      color: rank.color.withValues(alpha: 0.15),
                      blurRadius: 16.0,
                    ),
                  ]
                : null,
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
                    ),
                  ),
                  if (!isUnlocked)
                    const Icon(
                      Icons.lock,
                      size: 16.0,
                      color: AppColors.structuralSeam,
                    )
                  else if (rank != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 2.0,
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
                        ),
                      ),
                    ),
                ],
              ),

              // Title and Description
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chamber.name.toUpperCase(),
                    style: AppTypography.sectionHeader.copyWith(
                      color: isUnlocked
                          ? AppColors.onSurface
                          : AppColors.onSurfaceVariant.withValues(alpha: 0.4),
                      fontWeight: FontWeight.w700,
                    ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidianVoid,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (widget.onBack != null)
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppColors.onSurface,
                      ),
                      onPressed: widget.onBack,
                    )
                  else
                    const SizedBox.shrink(),
                  Column(
                    children: [
                      Text(
                        'CHAMBER MATRIX',
                        style: AppTypography.titleChamber.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.0,
                        ),
                      ),
                      Text(
                        'SELECT DRIFT SECTOR // 8 CHAMBERS AVAILABLE',
                        style: AppTypography.telemetryLabel.copyWith(
                          color: AppColors.solarAmber,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 48.0),
                ],
              ),
              const SizedBox(height: 24.0),

              // Chambers Grid
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.solarAmber,
                        ),
                      )
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
                            itemCount: _chambers.length,
                            itemBuilder: (context, index) {
                              return _buildChamberCard(_chambers[index]);
                            },
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
}
