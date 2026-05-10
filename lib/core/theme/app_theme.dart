import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

ThemeData buildPulseDarkTheme() {
  const scheme = ColorScheme.dark(
    surface: PulseColors.surface,
    primary: PulseColors.accent,
    secondary: PulseColors.success,
    onSurface: PulseColors.textPrimary,
    outline: PulseColors.borderSubtle,
    error: Color(0xFFFF6B6B),
    onPrimary: PulseColors.background,
    onSecondary: PulseColors.background,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: PulseColors.background,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: PulseColors.textPrimary,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.15,
        color: PulseColors.textPrimary,
      ),
      titleLarge: TextStyle(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: PulseColors.textPrimary,
      ),
      bodyLarge: TextStyle(
        color: PulseColors.textPrimary,
        height: 1.4,
      ),
      bodyMedium: TextStyle(
        color: PulseColors.textSecondary,
        height: 1.4,
      ),
    ),
    dividerColor: PulseColors.borderSubtle,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: PulseColors.surfaceMuted.withValues(alpha: 0.6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: PulseColors.borderSubtle),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide:
            BorderSide(color: PulseColors.borderSubtle.withValues(alpha: 0.8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: PulseColors.accent, width: 1.2),
      ),
      labelStyle: const TextStyle(color: PulseColors.textSecondary),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: PulseColors.background,
        backgroundColor: PulseColors.accent,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: PulseColors.textPrimary,
        side: BorderSide(color: PulseColors.borderSubtle.withValues(alpha: 0.9)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      backgroundColor: PulseColors.snackNeutralBg,
      contentTextStyle: const TextStyle(
        color: PulseColors.snackNeutralFg,
        fontSize: 14,
        height: 1.35,
        fontWeight: FontWeight.w500,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surface,
      indicatorColor: PulseColors.accent.withValues(alpha: 0.22),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 12,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          color:
              selected ? PulseColors.accent : PulseColors.textSecondary,
        );
      }),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}
