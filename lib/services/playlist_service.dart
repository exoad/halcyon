import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlaylistEntry {
  final String filePath;
  final int durationMs;

  const PlaylistEntry({required this.filePath, required this.durationMs});

  Duration get duration => Duration(milliseconds: durationMs);

  Map<String, dynamic> toJson() {
    return {'filePath': filePath, 'durationMs': durationMs};
  }

  static PlaylistEntry? fromJson(Map<String, dynamic> json) {
    final path = json['filePath'];
    final duration = json['durationMs'];
    if (path is! String || path.isEmpty) {
      return null;
    }
    return PlaylistEntry(
      filePath: path,
      durationMs: duration is int ? duration : 0,
    );
  }
}

class PlaylistService {
  static const String _playlistKey = 'playlist_entries';

  static final ValueNotifier<List<PlaylistEntry>> playlist = ValueNotifier([]);

  PlaylistService._();

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final items = prefs.getStringList(_playlistKey) ?? [];
    final entries = <PlaylistEntry>[];
    for (final item in items) {
      try {
        final decoded = jsonDecode(item);
        if (decoded is Map<String, dynamic>) {
          final entry = PlaylistEntry.fromJson(decoded);
          if (entry != null) {
            entries.add(entry);
          }
        }
      } catch (_) {}
    }
    playlist.value = entries;
  }

  static Future<void> addEntry(String path, Duration duration) async {
    final entry = PlaylistEntry(
      filePath: path,
      durationMs: duration.inMilliseconds,
    );
    final existing = playlist.value;
    final updated = [entry, ...existing.where((item) => item.filePath != path)];
    playlist.value = updated;
    await _save(updated);
  }

  static Future<void> removeEntry(String path) async {
    final updated = playlist.value
        .where((item) => item.filePath != path)
        .toList();
    playlist.value = updated;
    await _save(updated);
  }

  static Future<void> clear() async {
    playlist.value = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_playlistKey);
  }

  static Future<void> reorderEntries(int oldIndex, int newIndex) async {
    final entries = List<PlaylistEntry>.from(playlist.value);

    // When dragging downward, newIndex is after removal, so adjust it
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final entry = entries.removeAt(oldIndex);
    entries.insert(newIndex, entry);
    playlist.value = entries;
    await _save(entries);
  }

  static Future<void> _save(List<PlaylistEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final items = entries.map((entry) => jsonEncode(entry.toJson())).toList();
    await prefs.setStringList(_playlistKey, items);
  }
}
