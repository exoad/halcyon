import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SettingType {
  stringSelect('String Select', 'Select from predefined options'),
  bool('Boolean', 'Toggle true or false'),
  numeric('Numeric', 'Numeric value'),
  string('String', 'Text input');

  final String displayName;
  final String description;

  const SettingType(this.displayName, this.description);
}

enum AlbumArtFitMode {
  clickToChange(
    'Click to Change',
    'Double-click album art to cycle through fit modes',
  ),
  settingsMenu('Settings Menu', 'Change album art fit from the settings menu');

  final String displayName;
  final String description;

  const AlbumArtFitMode(this.displayName, this.description);

  static AlbumArtFitMode fromString(String? value) {
    return AlbumArtFitMode.values.firstWhere(
      (mode) {
        return mode.name == value;
      },
      orElse: () {
        return AlbumArtFitMode.clickToChange;
      },
    );
  }
}

class SettingEntry {
  final String key;
  final String displayName;
  final String description;
  final SettingType type;
  final dynamic value;
  final List<dynamic>? selectOptions;

  SettingEntry({
    required this.key,
    required this.displayName,
    required this.description,
    required this.type,
    required this.value,
    this.selectOptions,
  });
}

class SettingsService {
  static const String _albumArtFitModeKey = 'album_art_fit_mode';

  static final ValueNotifier<AlbumArtFitMode> albumArtFitMode = ValueNotifier(
    AlbumArtFitMode.clickToChange,
  );

  SettingsService._();

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    albumArtFitMode.value = AlbumArtFitMode.fromString(
      prefs.getString(_albumArtFitModeKey),
    );
  }

  static Future<void> setAlbumArtFitMode(AlbumArtFitMode mode) async {
    albumArtFitMode.value = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_albumArtFitModeKey, mode.name);
  }

  static List<SettingEntry> getDisplaySettings() {
    return [
      SettingEntry(
        key: 'album_art_interaction',
        displayName: 'Album Art Interaction',
        description: 'Choose how to change the album art fit mode',
        type: SettingType.stringSelect,
        value: albumArtFitMode.value.name,
        selectOptions: AlbumArtFitMode.values,
      ),
    ];
  }
}
