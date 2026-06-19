import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Light palette ──────────────────────────────────────────────────────────
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFE9EBF8);
  static const Color surfaceMuted = Color(0xFFF1F2FA);

  static const Color textPrimary = Color(0xFF1C2238);
  static const Color textSecondary = Color(0xFF8A8FA3);

  static const Color accent = Color(0xFF5B6BF0);
  static const Color accentDark = Color(0xFF3B49C7);

  static const Color path = Color(0xFFFF4D6A);
  static const Color pathMuted = Color(0xFFFFD3DA);

  static const Color heartFilled = Color(0xFFFF4D6A);
  static const Color heartEmpty = Color(0xFFD9DCEC);

  static const Color gridLine = Color(0xFFE3E5F2);
  static const Color cellDefault = Color(0xFF1C2238);
  static const Color cellLocked = Color(0xFFC3C6DA);

  static const Color success = Color(0xFF4CAF50);
  static const Color disabled = Color(0xFFC3C6DA);

  static const Color toggleOffTrack = Color(0xFF2E3550);

  // ── Dark palette ───────────────────────────────────────────────────────────
  // Background: deep navy exactly as in the screenshot
  static const Color darkBackground = Color(0xFF1C2035);
  // Cards / section containers: slightly lighter navy
  static const Color darkSurface = Color(0xFF252A40);
  // Bottom nav / muted surfaces
  static const Color darkSurfaceMuted = Color(0xFF20253C);

  static const Color darkTextPrimary = Color(0xFFD6DAEF);
  static const Color darkTextSecondary = Color(0xFF6B7099);

  // Arrow / game-piece color in dark mode: periwinkle lavender
  static const Color darkCellDefault = Color(0xFFA8B0D8);

  static const Color darkGridLine = Color(0xFF2E3452);
  static const Color darkToggleOff = Color(0xFF3A3F5C);

  // Hearts stay red in both modes
  static const Color darkHeartFilled = Color(0xFFFF4D6A);
  static const Color darkHeartEmpty = Color(0xFF3A3F5C);

  // ── Semantic helpers (context-aware) ───────────────────────────────────────
  static bool _isDark(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark;

  static Color bg(BuildContext ctx) =>
      _isDark(ctx) ? darkBackground : background;

  static Color surf(BuildContext ctx) => _isDark(ctx) ? darkSurface : surface;

  static Color surfMuted(BuildContext ctx) =>
      _isDark(ctx) ? darkSurfaceMuted : surfaceMuted;

  static Color textPrim(BuildContext ctx) =>
      _isDark(ctx) ? darkTextPrimary : textPrimary;

  static Color textSec(BuildContext ctx) =>
      _isDark(ctx) ? darkTextSecondary : textSecondary;

  static Color grid(BuildContext ctx) => _isDark(ctx) ? darkGridLine : gridLine;

  static Color cell(BuildContext ctx) =>
      _isDark(ctx) ? darkCellDefault : cellDefault;

  static Color toggleOff(BuildContext ctx) =>
      _isDark(ctx) ? darkToggleOff : toggleOffTrack;

  static Color heart(BuildContext ctx, {required bool filled}) {
    if (filled) return heartFilled; // same red in both modes
    return _isDark(ctx) ? darkHeartEmpty : heartEmpty;
  }
}
