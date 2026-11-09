import 'package:material_ui/material_ui.dart';

enum MilestoneTier {
  bronze('BRONZE', Color(0xFFCD7F32)),
  silver('SILVER', Color(0xFFC0C0C0)),
  gold('GOLD', Color(0xFFFFD700)),
  platinum('PLATINUM', Color(0xFF00F5FF));

  const MilestoneTier(this.label, this.color);
  final String label;
  final Color color;
}

class Milestone {
  const Milestone({
    required this.id,
    required this.title,
    required this.description,
    required this.tier,
    required this.iconName,
    this.isUnlocked = false,
    this.unlockedAtEpochMs,
  });

  final String id;
  final String title;
  final String description;
  final MilestoneTier tier;
  final String iconName;
  final bool isUnlocked;
  final int? unlockedAtEpochMs;

  Milestone unlock() {
    if (isUnlocked) return this;
    return Milestone(
      id: id,
      title: title,
      description: description,
      tier: tier,
      iconName: iconName,
      isUnlocked: true,
      unlockedAtEpochMs: DateTime.now().millisecondsSinceEpoch,
    );
  }

  Milestone copyWith({
    String? id,
    String? title,
    String? description,
    MilestoneTier? tier,
    String? iconName,
    bool? isUnlocked,
    int? unlockedAtEpochMs,
  }) {
    return Milestone(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      tier: tier ?? this.tier,
      iconName: iconName ?? this.iconName,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAtEpochMs: unlockedAtEpochMs ?? this.unlockedAtEpochMs,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'isUnlocked': isUnlocked,
    'unlockedAtEpochMs': unlockedAtEpochMs,
  };

  factory Milestone.fromJson(Map<String, dynamic> json, Milestone template) {
    return template.copyWith(
      isUnlocked: (json['isUnlocked'] as bool?) ?? false,
      unlockedAtEpochMs: json['unlockedAtEpochMs'] as int?,
    );
  }
}
