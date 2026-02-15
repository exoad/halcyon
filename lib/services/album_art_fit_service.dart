import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AlbumArtFit {
  cover('Cover', BoxFit.cover),
  zoom('Zoom', BoxFit.fill),
  stretch('Stretch', BoxFit.fill);

  final String displayName;
  final BoxFit boxFit;

  const AlbumArtFit(this.displayName, this.boxFit);

  static AlbumArtFit fromString(String? value) {
    return AlbumArtFit.values.firstWhere(
      (fit) {
        return fit.name == value;
      },
      orElse: () {
        return AlbumArtFit.cover;
      },
    );
  }

  AlbumArtFit get next {
    return AlbumArtFit.values[(AlbumArtFit.values.indexOf(this) + 1) %
        AlbumArtFit.values.length];
  }
}

class AlbumArtFitService {
  static const String _key = 'album_art_fit';

  static final ValueNotifier<AlbumArtFit> currentFitNotifier = ValueNotifier(
    AlbumArtFit.cover,
  );

  AlbumArtFitService._();

  static AlbumArtFit get currentFit {
    return currentFitNotifier.value;
  }

  static Future<void> init() async {
    currentFitNotifier.value = AlbumArtFit.fromString(
      (await SharedPreferences.getInstance()).getString(_key),
    );
  }

  static Future<void> cycleFit() async {
    currentFitNotifier.value = currentFitNotifier.value.next;
    await (await SharedPreferences.getInstance()).setString(
      _key,
      currentFitNotifier.value.name,
    );
  }
}
