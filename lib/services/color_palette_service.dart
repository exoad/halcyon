import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:halcyon/services/audio_engine.dart';

class PaletteColors {
  final Color background;
  final Color surface;
  final Color surfaceLight;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color comment;
  final Color accent;
  final Color accentHover;
  final Color controlBg;
  final Color controlHover;
  final Color progressBg;
  final Color progressFill;

  const PaletteColors({
    required this.background,
    required this.surface,
    required this.surfaceLight,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.comment,
    required this.accent,
    required this.accentHover,
    required this.controlBg,
    required this.controlHover,
    required this.progressBg,
    required this.progressFill,
  });

  static PaletteColors lerp(PaletteColors a, PaletteColors b, double t) {
    return PaletteColors(
      background: Color.lerp(a.background, b.background, t)!,
      surface: Color.lerp(a.surface, b.surface, t)!,
      surfaceLight: Color.lerp(a.surfaceLight, b.surfaceLight, t)!,
      border: Color.lerp(a.border, b.border, t)!,
      textPrimary: Color.lerp(a.textPrimary, b.textPrimary, t)!,
      textSecondary: Color.lerp(a.textSecondary, b.textSecondary, t)!,
      comment: Color.lerp(a.comment, b.comment, t)!,
      accent: Color.lerp(a.accent, b.accent, t)!,
      accentHover: Color.lerp(a.accentHover, b.accentHover, t)!,
      controlBg: Color.lerp(a.controlBg, b.controlBg, t)!,
      controlHover: Color.lerp(a.controlHover, b.controlHover, t)!,
      progressBg: Color.lerp(a.progressBg, b.progressBg, t)!,
      progressFill: Color.lerp(a.progressFill, b.progressFill, t)!,
    );
  }

  static const Color _baseBackground = Color(0xFF2B2B2B);
  static const Color _baseSurface = Color(0xFF313335);
  static const Color _baseSurfaceLight = Color(0xFF3A3C3E);
  static const Color _baseBorder = Color(0xFF3C3F41);
  static const Color _baseTextPrimary = Color(0xFFA9B7C6);
  static const Color _baseTextSecondary = Color(0xFF9AA0A6);
  static const Color _baseComment = Color(0xFF808080);
  static const Color _baseControlBg = Color(0xFF2F3133);
  static const Color _baseControlHover = Color(0xFF3E4042);
  static const Color _baseProgressBg = Color(0xFF3C3F41);

  static Future<PaletteColors?> fromAlbumArt(Uint8List bytes) async {
    final image = await decodeImageFromList(bytes);
    final byteData = await image.toByteData(format: ImageByteFormat.rawRgba);
    if (byteData == null) {
      return null;
    }
    final data = byteData.buffer.asUint8List();
    final width = image.width;
    final height = image.height;
    if (width == 0 || height == 0) {
      return null;
    }

    final step = math.max(1, math.min(width, height) ~/ 40);
    double totalWeight = 0;
    double rAcc = 0;
    double gAcc = 0;
    double bAcc = 0;

    for (var y = 0; y < height; y += step) {
      for (var x = 0; x < width; x += step) {
        final idx = (y * width + x) * 4;
        if (idx + 3 >= data.length) {
          continue;
        }
        final r = data[idx];
        final g = data[idx + 1];
        final b = data[idx + 2];
        final a = data[idx + 3];
        if (a < 20) {
          continue;
        }
        final color = Color.fromARGB(255, r, g, b);
        final hsl = HSLColor.fromColor(color);
        final weight =
            (hsl.saturation * 0.7 + 0.3) *
            (1 - (0.5 - hsl.lightness).abs()).clamp(0.2, 1.0);
        rAcc += r * weight;
        gAcc += g * weight;
        bAcc += b * weight;
        totalWeight += weight;
      }
    }

    if (totalWeight == 0) {
      return null;
    }

    final avgColor = Color.fromARGB(
      255,
      (rAcc / totalWeight).round().clamp(0, 255),
      (gAcc / totalWeight).round().clamp(0, 255),
      (bAcc / totalWeight).round().clamp(0, 255),
    );

    final baseHsl = HSLColor.fromColor(avgColor);
    var accent = baseHsl
        .withSaturation(baseHsl.saturation.clamp(0.45, 1.0))
        .withLightness((0.55).clamp(0.50, 0.72))
        .toColor();

    final background = _blend(_baseBackground, accent, 0.1);
    accent = _ensureContrast(
      accent,
      background,
      fallback: accent,
      minRatio: 3.2,
    );
    final accentHover = HSLColor.fromColor(
      accent,
    ).withLightness((baseHsl.lightness + 0.12).clamp(0.45, 0.8)).toColor();

    final surface = _blend(_baseSurface, accent, 0.16);
    final surfaceLight = _blend(_baseSurfaceLight, accent, 0.2);
    final border = _blend(_baseBorder, accent, 0.18);
    final controlBg = _blend(_baseControlBg, accent, 0.2);
    final controlHover = _blend(_baseControlHover, accent, 0.24);
    final progressBg = _blend(_baseProgressBg, accent, 0.2);

    var textPrimary = _blend(_baseTextPrimary, accent, 0.24);
    var textSecondary = _blend(_baseTextSecondary, accent, 0.2);
    var comment = _blend(_baseComment, accent, 0.18);

    textPrimary = _ensureContrast(
      textPrimary,
      background,
      fallback: _baseTextPrimary,
      minRatio: 5.0,
    );
    textSecondary = _ensureContrast(
      textSecondary,
      background,
      fallback: _baseTextSecondary,
      minRatio: 3.8,
    );
    comment = _ensureContrast(
      comment,
      background,
      fallback: _baseComment,
      minRatio: 3.0,
    );

    return PaletteColors(
      background: background,
      surface: surface,
      surfaceLight: surfaceLight,
      border: border,
      textPrimary: textPrimary,
      textSecondary: textSecondary,
      comment: comment,
      accent: accent,
      accentHover: accentHover,
      controlBg: controlBg,
      controlHover: controlHover,
      progressBg: progressBg,
      progressFill: accent,
    );
  }

  static Color _blend(Color a, Color b, double t) {
    final clamped = t.clamp(0.0, 1.0);
    return Color.fromARGB(
      255,
      (a.red + (b.red - a.red) * clamped).round(),
      (a.green + (b.green - a.green) * clamped).round(),
      (a.blue + (b.blue - a.blue) * clamped).round(),
    );
  }

  static Color _ensureContrast(
    Color candidate,
    Color background, {
    required Color fallback,
    required double minRatio,
  }) {
    if (_contrastRatio(candidate, background) >= minRatio) {
      return candidate;
    }
    if (_contrastRatio(fallback, background) >= minRatio) {
      return fallback;
    }
    final hsl = HSLColor.fromColor(candidate);
    final adjusted = hsl.withLightness(0.74).toColor();
    return _contrastRatio(adjusted, background) >= minRatio
        ? adjusted
        : fallback;
  }

  static double _contrastRatio(Color a, Color b) {
    final l1 = a.computeLuminance();
    final l2 = b.computeLuminance();
    final lighter = math.max(l1, l2);
    final darker = math.min(l1, l2);
    return (lighter + 0.05) / (darker + 0.05);
  }
}

class ColorPaletteService {
  static final ValueNotifier<PaletteColors?> palette = ValueNotifier(null);
  static final ValueNotifier<PaletteColors?> currentPalette = ValueNotifier(
    null,
  );
  static VoidCallback? _listener;
  static int _token = 0;

  ColorPaletteService._();

  static Future<void> init() async {
    _listener ??= () {
      _updateFromAlbumArt();
    };
    AudioEngine.instance.albumArt.addListener(_listener!);
    _updateFromAlbumArt();
  }

  static void dispose() {
    if (_listener != null) {
      AudioEngine.instance.albumArt.removeListener(_listener!);
      _listener = null;
    }
  }

  static Future<void> _updateFromAlbumArt() async {
    final art = AudioEngine.instance.albumArt.value;
    final currentToken = ++_token;
    if (art == null || art.isEmpty) {
      palette.value = null;
      return;
    }
    try {
      final colors = await PaletteColors.fromAlbumArt(art);
      if (currentToken != _token) {
        return;
      }
      palette.value = colors;
    } catch (_) {
      if (currentToken == _token) {
        palette.value = null;
      }
    }
  }
}
