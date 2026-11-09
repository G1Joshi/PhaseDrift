import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/domain.dart';

class PersistenceService {
  PersistenceService([SharedPreferences? preferences])
    : _preferences = preferences;

  static PersistenceService? _instance;
  static PersistenceService get instance => _instance ??= PersistenceService();

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

  List<ChamberRecord> getAllChamberRecords({int totalChambers = 100}) {
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

  static const String _milestonesKey = 'phasedrift_milestones';
  static const String _masterVolKey = 'phasedrift_master_volume';
  static const String _musicVolKey = 'phasedrift_music_volume';
  static const String _sfxVolKey = 'phasedrift_sfx_volume';
  static const String _mutedKey = 'phasedrift_audio_muted';
  static const String _hapticsKey = 'phasedrift_haptics_enabled';
  static const String _reduceMotionKey = 'phasedrift_reduce_motion';

  Future<bool> saveAudioSettings({
    required double master,
    required double music,
    required double sfx,
    required bool muted,
  }) async {
    await _prefs.setDouble(_masterVolKey, master);
    await _prefs.setDouble(_musicVolKey, music);
    await _prefs.setDouble(_sfxVolKey, sfx);
    return _prefs.setBool(_mutedKey, muted);
  }

  (double master, double music, double sfx, bool muted) getAudioSettings() {
    if (_preferences == null) return (0.8, 0.7, 0.9, false);
    final master = _prefs.getDouble(_masterVolKey) ?? 0.8;
    final music = _prefs.getDouble(_musicVolKey) ?? 0.7;
    final sfx = _prefs.getDouble(_sfxVolKey) ?? 0.9;
    final muted = _prefs.getBool(_mutedKey) ?? false;
    return (master, music, sfx, muted);
  }

  Future<bool> saveHapticsEnabled(bool enabled) async {
    return _prefs.setBool(_hapticsKey, enabled);
  }

  bool getHapticsEnabled() {
    if (_preferences == null) return true;
    return _prefs.getBool(_hapticsKey) ?? true;
  }

  Future<bool> saveReduceMotion(bool reduceMotion) async {
    return _prefs.setBool(_reduceMotionKey, reduceMotion);
  }

  bool getReduceMotion() {
    if (_preferences == null) return false;
    return _prefs.getBool(_reduceMotionKey) ?? false;
  }

  Future<bool> saveMilestones(Map<String, dynamic> data) async {
    final raw = jsonEncode(data);
    return _prefs.setString(_milestonesKey, raw);
  }

  Map<String, dynamic> getMilestones() {
    if (_preferences == null) return {};
    final raw = _prefs.getString(_milestonesKey);
    if (raw == null) return {};
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  Future<bool> resetProgressionTelemetry() async {
    if (_preferences == null) return true;
    final keys = _prefs
        .getKeys()
        .where(
          (k) =>
              k.startsWith(_chamberPrefix) ||
              k == _statsKey ||
              k == _milestonesKey,
        )
        .toList();

    var allSuccess = true;
    for (final key in keys) {
      final success = await _prefs.remove(key);
      if (!success) allSuccess = false;
    }
    return allSuccess;
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
