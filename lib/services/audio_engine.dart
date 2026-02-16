import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:halcyon/models/track_metadata.dart';
import 'package:halcyon/services/metadata_service.dart';
import 'package:halcyon/services/playlist_service.dart';

/// Loop state enum: off, playlist loop, or song loop
enum LoopState {
  off, // No looping
  playlist, // Loop entire playlist
  song, // Loop current song
}

final class AudioEngine {
  static final instance = AudioEngine._();
  final _soloud = SoLoud.instance;
  AudioSource? _currentSource;
  SoundHandle? _currentHandle;
  Timer? _positionTimer;

  final isPlaying = ValueNotifier(false);
  final isPaused = ValueNotifier(false);
  final position = ValueNotifier(Duration.zero);
  final duration = ValueNotifier(Duration.zero);
  final volume = ValueNotifier(0.75);
  final shuffle = ValueNotifier(false);
  final loopState = ValueNotifier(LoopState.off);
  final trackTitle = ValueNotifier('No Track Loaded');
  final trackArtist = ValueNotifier('Unknown Artist');
  final trackAlbum = ValueNotifier('Unknown Album');
  final trackMeta = ValueNotifier('');
  final filePath = ValueNotifier<String?>(null);
  final albumArt = ValueNotifier<Uint8List?>(null);
  final metadata = ValueNotifier<TrackMetadata?>(null);
  final recentTracks = ValueNotifier<List<TrackEntry>>([]);

  // Track recently played songs to avoid repetition in shuffle
  final Set<String> _recentlyPlayed = {};
  int _playHistorySize = 0;

  AudioEngine._();

  bool get hasTrack {
    return _currentSource != null;
  }

  Future<void> init() async {
    if (_soloud.isInitialized) {
      return;
    }
    await _soloud.init();
    _soloud.setVisualizationEnabled(true);
  }

  Future<void> loadFile(String path) async {
    await stopPlayback();
    if (_currentSource != null) {
      await _soloud.disposeSource(_currentSource!);
      _currentSource = null;
    }
    _currentSource = await _soloud.loadFile(path);
    final len = _soloud.getLength(_currentSource!);
    duration.value = len;
    position.value = Duration.zero;
    filePath.value = path;
    final meta = await MetadataService.read(path);
    metadata.value = meta;
    trackTitle.value = meta.displayTitle;
    trackArtist.value = meta.displayArtist;
    trackAlbum.value = meta.displayAlbum;
    trackMeta.value = meta.metaLine;
    albumArt.value = meta.albumArt;
    final entry = TrackEntry(metadata: meta, duration: len);
    final existing = recentTracks.value;
    recentTracks.value = [
      entry,
      ...existing.where((item) => item.metadata.filePath != meta.filePath),
    ];

    // Add to recently played history
    _recentlyPlayed.add(path);
  }

  Future<void> play() async {
    if (_currentSource == null) {
      return;
    }
    if (_currentHandle != null && isPaused.value) {
      _soloud.setPause(_currentHandle!, false);
      isPaused.value = false;
      isPlaying.value = true;
      _startPositionPolling();
      return;
    }
    _currentHandle = await _soloud.play(
      _currentSource!,
      volume: volume.value,
      looping: loopState.value == LoopState.song,
    );
    isPlaying.value = true;
    isPaused.value = false;
    _startPositionPolling();
  }

  void pause() {
    if (_currentHandle == null || !isPlaying.value) {
      return;
    }
    _soloud.setPause(_currentHandle!, true);
    isPaused.value = true;
    isPlaying.value = false;
    _stopPositionPolling();
  }

  void togglePlayPause() {
    if (isPlaying.value) {
      pause();
    } else {
      play();
    }
  }

  Future<void> stopPlayback() async {
    if (_currentHandle != null) {
      await _soloud.stop(_currentHandle!);
      _currentHandle = null;
    }
    isPlaying.value = false;
    isPaused.value = false;
    position.value = Duration.zero;
    _stopPositionPolling();
  }

  void seek(Duration target) {
    if (_currentHandle == null) {
      return;
    }
    _soloud.seek(_currentHandle!, target);
    position.value = target;
  }

  void setVolume(double v) {
    volume.value = v.clamp(0.0, 1.0);
    if (_currentHandle != null) {
      _soloud.setVolume(_currentHandle!, volume.value);
    }
  }

  void toggleShuffle() {
    shuffle.value = !shuffle.value;
  }

  /// Cycle through loop states: off -> playlist -> song -> off
  void toggleLoop() {
    loopState.value = switch (loopState.value) {
      LoopState.off => LoopState.playlist,
      LoopState.playlist => LoopState.song,
      LoopState.song => LoopState.off,
    };

    // Update playback looping for song mode
    if (_currentHandle != null) {
      _soloud.setLooping(_currentHandle!, loopState.value == LoopState.song);
    }
  }

  /// Select next track, using shuffle if enabled
  Future<void> playNext() async {
    final entries = PlaylistService.playlist.value;
    if (entries.isEmpty) {
      return;
    }

    final currentPath = filePath.value;
    final nextIndex = shuffle.value
        ? _getNextShuffleIndex(entries, currentPath)
        : _getNextSequentialIndex(entries, currentPath);

    await _playFromPlaylist(entries, nextIndex);
  }

  /// Get next index in shuffle mode
  int _getNextShuffleIndex(List<PlaylistEntry> entries, String? currentPath) {
    if (entries.isEmpty) return 0;

    // Calculate history size (25% of playlist size, min 1)
    _playHistorySize = math.max(1, (entries.length * 0.25).ceil());

    // Get all indices except recently played
    final availableIndices = <int>[];
    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      if (!_recentlyPlayed.contains(entry.filePath)) {
        availableIndices.add(i);
      }
    }

    // If all songs have been played, clear history and try again
    if (availableIndices.isEmpty) {
      _recentlyPlayed.clear();
      return math.Random().nextInt(entries.length);
    }

    // Return random available index
    return availableIndices[math.Random().nextInt(availableIndices.length)];
  }

  /// Get next index in sequential mode
  int _getNextSequentialIndex(
    List<PlaylistEntry> entries,
    String? currentPath,
  ) {
    final currentIndex = entries.indexWhere(
      (entry) => entry.filePath == currentPath,
    );

    if (currentIndex == -1) {
      return 0;
    }

    final nextIndex = (currentIndex + 1) % entries.length;

    // Reset shuffle history when we loop back to start
    if (nextIndex == 0) {
      _recentlyPlayed.clear();
    }

    return nextIndex;
  }

  Future<void> playPrevious() async {
    final entries = PlaylistService.playlist.value;
    if (entries.isEmpty) {
      return;
    }
    final currentPath = filePath.value;
    final currentIndex = entries.indexWhere(
      (entry) => entry.filePath == currentPath,
    );
    final previousIndex = currentIndex == -1
        ? entries.length - 1
        : (currentIndex - 1 + entries.length) % entries.length;
    await _playFromPlaylist(entries, previousIndex);
  }

  Future<void> _playFromPlaylist(List<PlaylistEntry> entries, int index) async {
    if (index < 0 || index >= entries.length) {
      return;
    }
    final path = entries[index].filePath;
    await loadFile(path);
    await play();
  }

  void _startPositionPolling() {
    _stopPositionPolling();
    _positionTimer = Timer.periodic(const Duration(milliseconds: 33), (_) {
      _pollPosition();
    });
  }

  void _stopPositionPolling() {
    _positionTimer?.cancel();
    _positionTimer = null;
  }

  void _pollPosition() {
    if (_currentHandle == null) {
      return;
    }
    if (!_soloud.getIsValidVoiceHandle(_currentHandle!)) {
      _onTrackFinished();
      return;
    }
    position.value = _soloud.getPosition(_currentHandle!);
  }

  void _onTrackFinished() {
    _stopPositionPolling();
    _currentHandle = null;
    isPlaying.value = false;
    isPaused.value = false;
    position.value = Duration.zero;

    if (loopState.value == LoopState.song && _currentSource != null) {
      // Replay current song
      play();
    } else if (loopState.value == LoopState.playlist ||
        loopState.value == LoopState.off) {
      // Play next song, or stop if no loop and at end
      playNext();
    }
  }

  Future<void> dispose() async {
    await stopPlayback();
    if (_currentSource != null) {
      await _soloud.disposeSource(_currentSource!);
      _currentSource = null;
    }
    _soloud.deinit();
  }
}

class TrackEntry {
  final TrackMetadata metadata;
  final Duration duration;

  const TrackEntry({required this.metadata, required this.duration});
}
