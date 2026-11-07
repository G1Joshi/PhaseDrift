import 'package:material_ui/material_ui.dart';

import '../../core/domain/domain.dart';
import '../../core/theme/theme.dart';

class PhaseIndicator extends StatelessWidget {
  const PhaseIndicator({super.key, required this.phase, this.compact = false});

  final GamePhase phase;
  final bool compact;

  bool get isSolar => phase is SolarPhase;

  @override
  Widget build(BuildContext context) {
    final phaseColor = phase.primaryColor;
    final accentColor = phase.accentColor;
    final title = isSolar ? 'PHASE ALPHA' : 'PHASE OMEGA';
    final subtitle = isSolar ? 'SOLAR // \u2193' : 'VOID // \u2191';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8.0 : 12.0,
        vertical: compact ? 4.0 : 6.0,
      ),
      decoration: AppDecorations.phaseActive(
        phaseColor: phaseColor,
        chamfer: AppDecorations.chamferSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 3.0,
            height: compact ? 16.0 : 22.0,
            decoration: BoxDecoration(
              color: accentColor,
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.6),
                  blurRadius: 4.0,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: AppTypography.telemetryLabel.copyWith(
                  color: phaseColor,
                  fontWeight: FontWeight.w700,
                  fontSize: compact ? 9.0 : 10.0,
                ),
              ),
              if (!compact) ...[
                const SizedBox(height: 2.0),
                Text(
                  subtitle,
                  style: AppTypography.telemetryValueSm.copyWith(
                    fontSize: 12.0,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
