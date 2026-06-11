import 'package:flutter/material.dart';

// ── ConsentLens Design Tokens ──────────────────────────────────────────────
class CLColors {
  static const pink        = Color(0xFFE91E8C);
  static const pinkLight   = Color(0xFFFFF0F7);
  static const pinkMid     = Color(0xFFF4C0D1);
  static const pinkDark    = Color(0xFF72243E);

  static const purple      = Color(0xFF7C4DFF);
  static const purpleLight = Color(0xFFEDE7FF);

  static const amber       = Color(0xFFF5A623);
  static const amberLight  = Color(0xFFFFF3DC);
  static const amberDark   = Color(0xFF633806);

  static const red         = Color(0xFFE24B4A);
  static const redLight    = Color(0xFFFCEBEB);
  static const redDark     = Color(0xFF791F1F);

  static const green       = Color(0xFF3B6D11);
  static const greenLight  = Color(0xFFEAF3DE);

  static const blue        = Color(0xFF1976D2);
  static const blueLight   = Color(0xFFE3F2FD);

  static const bg          = Color(0xFFF7F7F8);
  static const bgAlt       = Color(0xFFF0F0F4);
  static const border      = Color(0xFFEEEEEE);
  static const borderMid   = Color(0xFFE0E0E0);
  static const textPrimary = Color(0xFF111111);
  static const textSec     = Color(0xFF666666);
  static const textMuted   = Color(0xFF9E9E9E);
  static const white       = Color(0xFFFFFFFF);
}

class CLTextStyles {
  static const heading = TextStyle(
    fontSize: 17, fontWeight: FontWeight.w700, color: CLColors.textPrimary,
  );
  static const subheading = TextStyle(
    fontSize: 15, fontWeight: FontWeight.w600, color: CLColors.textPrimary,
  );
  static const body = TextStyle(
    fontSize: 13, fontWeight: FontWeight.w400, color: CLColors.textSec,
    height: 1.5,
  );
  static const label = TextStyle(
    fontSize: 11, fontWeight: FontWeight.w500, color: CLColors.textMuted,
    letterSpacing: 0.5,
  );
  static const chip = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w700,
  );
  static const siteTag = TextStyle(
    fontSize: 11, color: CLColors.textMuted,
  );
}

ThemeData consentLensTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: CLColors.bg,
    colorScheme: const ColorScheme.light(
      primary: CLColors.pink,
      secondary: CLColors.purple,
      surface: CLColors.white,
      background: CLColors.bg,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: CLColors.white,
      foregroundColor: CLColors.textPrimary,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        fontSize: 17, fontWeight: FontWeight.w700, color: CLColors.textPrimary,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: CLColors.white,
      selectedItemColor: CLColors.pink,
      unselectedItemColor: CLColors.textMuted,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 10),
    ),
    cardTheme: CardThemeData(
      color: CLColors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: CLColors.border),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: CLColors.pink,
        foregroundColor: CLColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: CLColors.textSec,
        side: const BorderSide(color: CLColors.borderMid),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    fontFamily: 'SF Pro Display', // Falls back to system font
  );
}
