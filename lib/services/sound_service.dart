import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final GetStorage _storage = GetStorage();
  
  // Check if sound effects are enabled
  bool get isEnabled {
    return _storage.read('sound_effects_enabled') ?? false;
  }

  // Play haptic feedback (vibration) as sound effect
  // This works immediately without needing audio files
  Future<void> playSound(SoundType type) async {
    if (!isEnabled) return;

    try {
      switch (type) {
        case SoundType.tap:
          // Light haptic feedback for taps
          await HapticFeedback.selectionClick();
          break;
        case SoundType.success:
        case SoundType.complete:
          // Medium haptic feedback for success
          await HapticFeedback.mediumImpact();
          break;
        case SoundType.error:
          // Heavy haptic feedback for errors
          await HapticFeedback.heavyImpact();
          break;
        case SoundType.delete:
          // Heavy haptic feedback for delete
          await HapticFeedback.heavyImpact();
          break;
        case SoundType.switchToggle:
          // Light haptic feedback for switches
          await HapticFeedback.selectionClick();
          break;
      }
    } catch (e) {
      debugPrint('Haptic feedback error: $e');
    }
  }
}

enum SoundType {
  tap,
  success,
  error,
  complete,
  delete,
  switchToggle,
}

