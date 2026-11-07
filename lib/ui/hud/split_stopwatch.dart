import 'package:material_ui/material_ui.dart';

import '../../core/theme/theme.dart';

class SplitStopwatchView extends StatelessWidget {
  const SplitStopwatchView({
    super.key,
    required this.elapsedMs,
    this.bestTimeMs,
    this.label = 'TIME',
  });

  final int elapsedMs;
  final int? bestTimeMs;
  final String label;

  static String formatTime(int ms) {
    if (ms < 0) ms = 0;
    final minutes = ms ~/ 60000;
    final seconds = (ms % 60000) ~/ 1000;
    final millis = ms % 1000;
    final mStr = minutes.toString().padLeft(2, '0');
    final sStr = seconds.toString().padLeft(2, '0');
    final msStr = millis.toString().padLeft(3, '0');
    return '$mStr:$sStr.$msStr';
  }

  static String formatDelta(int deltaMs) {
    final sign = deltaMs < 0 ? '-' : '+';
    final absMs = deltaMs.abs();
    final minutes = absMs ~/ 60000;
    final seconds = (absMs % 60000) ~/ 1000;
    final millis = absMs % 1000;
    final msStr = millis.toString().padLeft(3, '0');
    if (minutes > 0) {
      final sStr = seconds.toString().padLeft(2, '0');
      return '$sign$minutes:$sStr.$msStr';
    } else {
      final sStr = seconds.toString().padLeft(2, '0');
      return '$sign$sStr.$msStr';
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedTime = formatTime(elapsedMs);
    final int? delta = bestTimeMs != null ? elapsedMs - bestTimeMs! : null;

    Color? deltaColor;
    String? deltaText;
    if (delta != null) {
      deltaText = formatDelta(delta);
      if (delta < 0) {
        deltaColor = AppColors.successGreen;
      } else if (delta > 0) {
        deltaColor = AppColors.hazardRed;
      } else {
        deltaColor = AppColors.onSurfaceVariant;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      decoration: AppDecorations.hudModule(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: AppTypography.telemetryLabel),
              if (deltaText != null) ...[
                const SizedBox(width: 8.0),
                Text(
                  deltaText,
                  style: AppTypography.telemetryLabel.copyWith(
                    color: deltaColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 2.0),
          Text(formattedTime, style: AppTypography.telemetryValueSm),
        ],
      ),
    );
  }
}
