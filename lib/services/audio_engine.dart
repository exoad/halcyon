import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:halcyon/models/track_metadata.dart';
import 'package:halcyon/services/metadata_service.dart';

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
  final repeat = ValueNotifier(false);
  final trackTitle = ValueNotifier('No Track Loaded');
  final trackArtist = ValueNotifier('Unknown Artist');
  final trackAlbum = ValueNotifier('Unknown Album');
  final trackMeta = ValueNotifier('');
  final filePath = ValueNotifier<String?>(null);
  final albumArt = ValueNotifier<Uint8List?>(null);
  final metadata = ValueNotifier<TrackMetadata?>(null);

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
      looping: repeat.value,
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

  void toggleRepeat() {
    repeat.value = !repeat.value;
    if (_currentHandle != null) {
      _soloud.setLooping(_currentHandle!, repeat.value);
    }
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
    if (repeat.value && _currentSource != null) {
      play();
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
