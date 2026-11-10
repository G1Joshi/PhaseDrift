import 'package:flutter/services.dart';

class HapticsService {
  HapticsService();

  static HapticsService? _instance;
  static HapticsService get instance => _instance ??= HapticsService();

  bool isEnabled = true;

  Future<void> triggerShift() async {
    if (!isEnabled) return;
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  Future<void> triggerJump() async {
    if (!isEnabled) return;
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }

  Future<void> triggerLand() async {
    if (!isEnabled) return;
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }

  Future<void> triggerShard() async {
    if (!isEnabled) return;
    try {
      await HapticFeedback.selectionClick();
    } catch (_) {}
  }

  Future<void> triggerDeath() async {
    if (!isEnabled) return;
    try {
      await HapticFeedback.heavyImpact();
    } catch (_) {}
  }

  Future<void> triggerTouchDown() async {
    if (!isEnabled) return;
    try {
      await HapticFeedback.selectionClick();
    } catch (_) {}
  }

  Future<void> triggerClick() async {
    if (!isEnabled) return;
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }

  Future<void> triggerSlingshot() async {
    if (!isEnabled) return;
    try {
      await HapticFeedback.heavyImpact();
    } catch (_) {}
  }

  Future<void> triggerWallSlide() async {
    if (!isEnabled) return;
    try {
      await HapticFeedback.selectionClick();
    } catch (_) {}
  }
}
