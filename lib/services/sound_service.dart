import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:get_storage/get_storage.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  
  final GetStorage _storage = GetStorage();
  
  // Dedicated player for each sound type for concurrency and speed
  final Map<SoundType, AudioPlayer> _players = {};

  SoundService._internal() {
    // Initialize a player for each sound type
    for (var type in SoundType.values) {
      final player = AudioPlayer();
      // Set to low latency mode characteristics via AudioContext if needed
      // Default is usually fine, but preloading is key.
      _players[type] = player;
    }
  }

  // Helper to get asset path
  String _getSoundPath(SoundType type) {
    switch (type) {
      case SoundType.tap: return 'sounds/tap.mp3';
      case SoundType.success: return 'sounds/success.mp3';
      case SoundType.error: return 'sounds/error.mp3';
      case SoundType.complete: return 'sounds/complete.mp3';
      case SoundType.delete: return 'sounds/delete.mp3';
      case SoundType.switchToggle: return 'sounds/switch.mp3';
      case SoundType.addTask: return 'sounds/add_task.mp3';
      case SoundType.undo: return 'sounds/undo.mp3';
    }
  }

  // Call this at app startup to preload sounds into memory
  Future<void> preloadAllSounds() async {
    debugPrint('SoundService: Preloading sounds...');
    for (var type in SoundType.values) {
      try {
        final path = _getSoundPath(type);
        // Set the source. This prepares the player.
        await _players[type]?.setSource(AssetSource(path));
      } catch (e) {
        debugPrint('Error preloading sound $type: $e');
      }
    }
    debugPrint('SoundService: Sounds preloaded.');
  }
  
  // Check if sound effects are enabled
  bool get isEnabled {
    return _storage.read('sound_effects_enabled') ?? true; // Default to TRUE
  }

  // Set sound effects enabled/disabled
  Future<void> setSoundEnabled(bool enabled) async {
    await _storage.write('sound_effects_enabled', enabled);
  }

  // Play sound effect based on type
  Future<void> playSound(SoundType type) async {
    if (!isEnabled) {
      // debugPrint('SoundService: Sound disabled by user preference');
      return;
    }

    try {
      final player = _players[type];
      if (player != null) {
        if (player.state == PlayerState.playing) {
          await player.stop(); // Stop if already playing (re-trigger)
          // For rapid tapping, creating a temporary player might be better 
          // but for general UI, stop-restart is standard to avoid chaos.
        }
        await player.resume(); // Use resume because source is already set
      }
    } catch (e) {
      debugPrint('Sound playback error: $e');
      // Fallback: try setting source and play again
      try {
         final player = _players[type];
         final path = _getSoundPath(type);
         await player?.play(AssetSource(path));
      } catch (e2) {
         debugPrint('Retry failed: $e2');
      }
    }
  }

  // Dispose all players
  Future<void> dispose() async {
    for (var player in _players.values) {
      await player.dispose();
    }
    _players.clear();
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
