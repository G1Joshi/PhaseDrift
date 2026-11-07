import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/domain.dart';

class PersistenceService {
  PersistenceService([SharedPreferences? preferences])
    : _preferences = preferences;

  static const String _chamberPrefix = 'phasedrift_chamber_';
  static const String _statsKey = 'phasedrift_player_stats';

  SharedPreferences? _preferences;

  Future<void> init() async {
    _preferences ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get _prefs {
    final prefs = _preferences;
    if (prefs == null) {
      throw StateError(
        'PersistenceService must be initialized via init() before use.',
      );
    }
    return prefs;
  }

  Future<bool> saveChamberRecord(ChamberRecord record) async {
    final key = '$_chamberPrefix${record.chamberId}';
    final raw = jsonEncode(record.toJson());
    return _prefs.setString(key, raw);
  }

  ChamberRecord getChamberRecord(int chamberId) {
    final key = '$_chamberPrefix$chamberId';
    final raw = _prefs.getString(key);
    if (raw == null) {
      return ChamberRecord.initial(chamberId, isUnlocked: chamberId == 1);
    }

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return ChamberRecord.fromJson(map);
    } catch (_) {
      return ChamberRecord.initial(chamberId, isUnlocked: chamberId == 1);
    }
  }

  List<ChamberRecord> getAllChamberRecords({int totalChambers = 8}) {
    return List.generate(totalChambers, (index) => getChamberRecord(index + 1));
  }

  Future<bool> savePlayerStats(PlayerStats stats) async {
    final raw = jsonEncode(stats.toJson());
    return _prefs.setString(_statsKey, raw);
  }

  PlayerStats getPlayerStats() {
    final raw = _prefs.getString(_statsKey);
    if (raw == null) {
      return const PlayerStats.initial();
    }

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return PlayerStats.fromJson(map);
    } catch (_) {
      return const PlayerStats.initial();
    }
  }

  Future<bool> resetAllProgress() async {
    final keys = _prefs
        .getKeys()
        .where((k) => k.startsWith('phasedrift_'))
        .toList();

    var allSuccess = true;
    for (final key in keys) {
      final success = await _prefs.remove(key);
      if (!success) allSuccess = false;
    }
    return allSuccess;
  }
}
