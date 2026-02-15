import 'package:flutter/material.dart';

/// Dracula color palette (IntelliJ-style / muted Darcula variant)
class AppColors {
  AppColors._();

  // Core background / foreground
  static const Color background = Color(0xFF2B2B2B); // Darcula base
  static const Color currentLine = Color(0xFF313335);
  static const Color foreground = Color(0xFFA9B7C6); // IntelliJ light-gray text
  static const Color comment = Color(0xFF808080); // muted comments

  // Accent palette (muted — not bright purple)
  static const Color cyan = Color(0xFF4DB6AC);
  static const Color green = Color(0xFF6A8759);
  static const Color orange = Color(0xFFCC7832);
  static const Color pink = Color(0xFFE6B0C0);
  static const Color purple = Color(0xFF7B6FA3);
  static const Color red = Color(0xFFBF616A);
  static const Color yellow = Color(0xFFBFA756);

  // Derived / UI-specific shades tuned for a subtle, flat desktop look
  static const Color surface = Color(0xFF313335);
  static const Color surfaceLight = Color(0xFF3A3C3E);
  static const Color border = Color(0xFF3C3F41);
  static const Color textPrimary = foreground;
  static const Color textSecondary = Color(0xFF9AA0A6);
  static const Color accent = Color(0xFFB6693A); // rustic/faded orange accent
  static const Color accentHover = Color(0xFFC78B5E);
  static const Color controlBg = Color(0xFF2F3133);
  static const Color controlHover = Color(0xFF3E4042);
  static const Color progressBg = Color(0xFF3C3F41);
  static const Color progressFill = accent;
}

/// Text styles tuned for a desktop audio player
class HalcyonTextStyles {
  HalcyonTextStyles._();

  static const TextStyle trackTitle = TextStyle(
    fontFamily: 'Segoe UI',
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 0.1,
    height: 1.3,
  );

  static const TextStyle artistName = TextStyle(
    fontFamily: 'Segoe UI',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.3,
  );

  static const TextStyle trackMeta = TextStyle(
    fontFamily: 'Segoe UI',
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.comment,
    height: 1.3,
  );

  static const TextStyle timeLabel = TextStyle(
    fontFamily: 'Consolas',
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );
}

/// Build a full ThemeData in Dracula style with compact desktop sizing.
ThemeData buildDraculaTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.transparent,
    canvasColor: AppColors.background,
    primaryColor: AppColors.accent,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accent,
      secondary: AppColors.pink,
      surface: AppColors.surface,
      error: AppColors.red,
      onPrimary: AppColors.background,
      onSecondary: AppColors.background,
      onSurface: AppColors.foreground,
      onError: AppColors.foreground,
    ),
    iconTheme: const IconThemeData(color: AppColors.foreground, size: 18),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: AppColors.currentLine,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.border),
      ),
      textStyle: const TextStyle(color: AppColors.foreground, fontSize: 11),
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
