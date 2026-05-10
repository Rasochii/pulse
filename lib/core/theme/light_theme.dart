import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

/// Tema claro opcional mantendo hierarquia de tipografia alinhada ao escuro.
ThemeData buildPulseLightTheme() {
  const scaffoldBg = Color(0xFFE8ECF9);
  const scheme = ColorScheme.light(
    surface: Color(0xFFF1F4FC),
    surfaceContainerHighest: Color(0xFFDDE4F7),
    primary: PulseColors.accent,
    secondary: PulseColors.success,
    onSurface: Color(0xFF0F131C),
    outline: Color(0xFFB9C2D9),
    error: Color(0xFFB91C1C),
    onPrimary: Colors.white,
    onSecondary: Color(0xFF0F131C),
  );

  const onSurf = Color(0xFF0F131C);
  const muted = Color(0xFF55607A);

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: scheme,
    scaffoldBackgroundColor: scaffoldBg,
    dividerColor: const Color(0xFFC8D2E8),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: onSurf,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.15,
        color: onSurf,
      ),
      headlineSmall: TextStyle(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        color: onSurf,
      ),
      titleLarge: TextStyle(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: onSurf,
      ),
      titleMedium: TextStyle(
        fontWeight: FontWeight.w600,
        color: onSurf,
      ),
      titleSmall: TextStyle(
        fontWeight: FontWeight.w600,
        color: onSurf,
      ),
      bodyLarge: TextStyle(
        color: onSurf,
        height: 1.4,
      ),
      bodyMedium: TextStyle(
        color: muted,
        height: 1.4,
      ),
      bodySmall: TextStyle(
        color: muted,
      ),
      labelMedium: TextStyle(color: muted),
      labelSmall: TextStyle(color: muted),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surface.withValues(alpha: 0.95),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.85)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.65)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: PulseColors.accent, width: 1.2),
      ),
      labelStyle: const TextStyle(color: muted),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: PulseColors.accent,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: PulseColors.accent,
        elevation: 0,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      backgroundColor: const Color(0xFF2A3148),
      contentTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        height: 1.35,
        fontWeight: FontWeight.w500,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surface,
      indicatorColor: PulseColors.accent.withValues(alpha: 0.2),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 12,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          color: selected ? PulseColors.accent : muted,
        );
      }),
    ),
  );
}
