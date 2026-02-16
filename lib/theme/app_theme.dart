import 'package:flutter/material.dart';
import 'package:halcyon/services/color_palette_service.dart';

/// Dracula color palette (IntelliJ-style / muted Darcula variant)
class AppColors {
  AppColors._();

  // Core background / foreground
  static const Color _background = Color(0xFF2B2B2B); // Darcula base
  static const Color _currentLine = Color(0xFF313335);
  static const Color _foreground = Color(
    0xFFA9B7C6,
  ); // IntelliJ light-gray text
  static const Color _comment = Color(0xFF808080); // muted comments

  // Accent palette (muted — not bright purple)
  static const Color _cyan = Color(0xFF4DB6AC);
  static const Color _green = Color(0xFF6A8759);
  static const Color _orange = Color(0xFFCC7832);
  static const Color _pink = Color(0xFFE6B0C0);
  static const Color _purple = Color(0xFF7B6FA3);
  static const Color _red = Color(0xFFBF616A);
  static const Color _yellow = Color(0xFFBFA756);

  // Derived / UI-specific shades tuned for a subtle, flat desktop look
  static const Color _surface = Color(0xFF313335);
  static const Color _surfaceLight = Color(0xFF3A3C3E);
  static const Color _border = Color(0xFF3C3F41);
  static const Color _textSecondary = Color(0xFF9AA0A6);
  static const Color _accent = Color(0xFFB6693A); // rustic/faded orange accent
  static const Color _accentHover = Color(0xFFC78B5E);
  static const Color _controlBg = Color(0xFF2F3133);
  static const Color _controlHover = Color(0xFF3E4042);
  static const Color _progressBg = Color(0xFF3C3F41);

  static PaletteColors? get _palette =>
      ColorPaletteService.currentPalette.value;

  static Color get background => _palette?.background ?? _background;
  static Color get currentLine => _palette?.surface ?? _currentLine;
  static Color get foreground => _palette?.textPrimary ?? _foreground;
  static Color get comment => _palette?.comment ?? _comment;

  static Color get cyan => _cyan;
  static Color get green => _green;
  static Color get orange => _orange;
  static Color get pink => _pink;
  static Color get purple => _purple;
  static Color get red => _red;
  static Color get yellow => _yellow;

  static Color get surface => _palette?.surface ?? _surface;
  static Color get surfaceLight => _palette?.surfaceLight ?? _surfaceLight;
  static Color get border => _palette?.border ?? _border;
  static Color get textPrimary => _palette?.textPrimary ?? _foreground;
  static Color get textSecondary => _palette?.textSecondary ?? _textSecondary;
  static Color get accent => _palette?.accent ?? _accent;
  static Color get accentHover => _palette?.accentHover ?? _accentHover;
  static Color get controlBg => _palette?.controlBg ?? _controlBg;
  static Color get controlHover => _palette?.controlHover ?? _controlHover;
  static Color get progressBg => _palette?.progressBg ?? _progressBg;
  static Color get progressFill => _palette?.progressFill ?? accent;
}

/// Text styles tuned for a desktop audio player
class HalcyonTextStyles {
  HalcyonTextStyles._();

  static TextStyle get trackTitle => const TextStyle(
    fontFamily: 'Segoe UI',
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.1,
    height: 1.3,
    shadows: [
      Shadow(color: Color(0x33000000), offset: Offset(0, 1), blurRadius: 2),
    ],
  ).copyWith(color: AppColors.textPrimary);

  static TextStyle get artistName => const TextStyle(
    fontFamily: 'Segoe UI',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.3,
  ).copyWith(color: AppColors.textSecondary);

  static TextStyle get trackMeta => const TextStyle(
    fontFamily: 'Segoe UI',
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.3,
  ).copyWith(color: AppColors.comment);

  static TextStyle get timeLabel => const TextStyle(
    fontFamily: 'Consolas',
    fontSize: 11,
    fontWeight: FontWeight.w400,
  ).copyWith(color: AppColors.textSecondary);
}

ThemeData buildDraculaTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.transparent,
    canvasColor: AppColors.background,
    primaryColor: AppColors.accent,
    colorScheme: ColorScheme.dark(
      primary: AppColors.accent,
      secondary: AppColors.pink,
      surface: AppColors.surface,
      error: AppColors.red,
      onPrimary: AppColors.background,
      onSecondary: AppColors.background,
      onSurface: AppColors.foreground,
      onError: AppColors.foreground,
    ),
    iconTheme: IconThemeData(color: AppColors.foreground, size: 18),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: AppColors.currentLine,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.border),
      ),
      textStyle: TextStyle(color: AppColors.foreground, fontSize: 11),
      waitDuration: const Duration(milliseconds: 400),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: AppColors.accent,
      inactiveTrackColor: AppColors.progressBg,
      thumbColor: AppColors.accent,
      overlayColor: AppColors.accent.withAlpha(40),
      trackHeight: 3,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
    ),
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStateProperty.all(AppColors.comment.withAlpha(120)),
      radius: const Radius.circular(2),
      thickness: WidgetStateProperty.all(6),
    ),
  );
}
