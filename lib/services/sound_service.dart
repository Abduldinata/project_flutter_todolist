import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:get_storage/get_storage.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final GetStorage _storage = GetStorage();
  final AudioPlayer _audioPlayer = AudioPlayer(); // Single player is safer for now
  
  // Check if sound effects are enabled
  bool get isEnabled {
    return _storage.read('sound_effects_enabled') ?? true; 
  }

  // Set sound effects enabled/disabled
  Future<void> setSoundEnabled(bool enabled) async {
    await _storage.write('sound_effects_enabled', enabled);
  }

  // Play sound effect based on type
  Future<void> playSound(SoundType type) async {
    if (!isEnabled) {
      debugPrint('Sound disabled by user');
      return;
    }

    try {
      String soundPath;
      switch (type) {
        case SoundType.tap: soundPath = 'sounds/tap.mp3'; break;
        case SoundType.success: soundPath = 'sounds/success.mp3'; break;
        case SoundType.error: soundPath = 'sounds/error.mp3'; break;
        case SoundType.complete: soundPath = 'sounds/complete.mp3'; break;
        case SoundType.delete: soundPath = 'sounds/delete.mp3'; break;
        case SoundType.switchToggle: soundPath = 'sounds/switch.mp3'; break;
        case SoundType.addTask: soundPath = 'sounds/add_task.mp3'; break;
        case SoundType.undo: soundPath = 'sounds/undo.mp3'; break;
      }

      debugPrint('Playing sound: $soundPath');
      
      // Stop current sound to play new one immediately
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(soundPath));
      
    } catch (e, stackTrace) {
      // Catch any error tanpa crash aplikasi
      debugPrint('Sound playback error: $e');
      debugPrint('Stack trace: $stackTrace');
      // Jangan throw error, biarkan aplikasi lanjut
    }
  }

  // Dummy method agar main.dart tidak error, tapi kosongkan isinya
  Future<void> preloadAllSounds() async {
    // No-op for stability
  }

  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}

enum SoundType {
  tap,
  success,
  error,
  complete,
  delete,
  switchToggle,
  addTask,
  undo,
}
