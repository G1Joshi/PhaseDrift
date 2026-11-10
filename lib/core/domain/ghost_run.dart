import 'dart:convert';

class GhostFrame {
  const GhostFrame({
    required this.x,
    required this.y,
    required this.isSolar,
    this.squishX = 1.0,
    this.squishY = 1.0,
  });

  final double x;
  final double y;
  final bool isSolar;
  final double squishX;
  final double squishY;

  Map<String, dynamic> toJson() => {
    'x': double.parse(x.toStringAsFixed(1)),
    'y': double.parse(y.toStringAsFixed(1)),
    's': isSolar ? 1 : 0,
    'sx': double.parse(squishX.toStringAsFixed(2)),
    'sy': double.parse(squishY.toStringAsFixed(2)),
  };

  factory GhostFrame.fromJson(Map<String, dynamic> json) => GhostFrame(
    x: (json['x'] as num).toDouble(),
    y: (json['y'] as num).toDouble(),
    isSolar: (json['s'] as int? ?? 1) == 1,
    squishX: (json['sx'] as num?)?.toDouble() ?? 1.0,
    squishY: (json['sy'] as num?)?.toDouble() ?? 1.0,
  );
}

class GhostRun {
  const GhostRun({
    required this.chamberId,
    required this.clearTimeMs,
    required this.frames,
  });

  final int chamberId;
  final int clearTimeMs;
  final List<GhostFrame> frames;

  Map<String, dynamic> toJson() => {
    'c': chamberId,
    't': clearTimeMs,
    'f': frames.map((f) => f.toJson()).toList(),
  };

  factory GhostRun.fromJson(Map<String, dynamic> json) => GhostRun(
    chamberId: json['c'] as int,
    clearTimeMs: json['t'] as int,
    frames: (json['f'] as List<dynamic>)
        .map((e) => GhostFrame.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  String encode() => jsonEncode(toJson());

  static GhostRun? decode(String raw) {
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return GhostRun.fromJson(map);
    } catch (_) {
      return null;
    }
  }
}
