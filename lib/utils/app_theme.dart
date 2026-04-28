import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF6200EE);
  static const Color primaryDark = Color(0xFF3700B3);
  static const Color accent = Color(0xFF03DAC6);
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color error = Color(0xFFCF6679);

  // Exercise specific colors
  static const Color activeExercise = Color(0xFF4CAF50);
  static const Color inactiveExercise = Color(0xFF424242);
  static const Color exerciseCardBackground = Color(0xFF2D2D2D);

  // Pose detection colors
  static const Color leftSidePose = Color(0xFFFFEB3B);  // Yellow
  static const Color rightSidePose = Color(0xFF2196F3); // Blue
  static const Color poseLandmark = Color(0xFF4CAF50);  // Green
}

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primary,
    primaryColorDark: AppColors.primaryDark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.surface,
      background: AppColors.background,
      error: AppColors.error,
    ),
    scaffoldBackgroundColor: AppColors.background,
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 4,
      margin: EdgeInsets.all(8),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: AppColors.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      elevation: 0,
      centerTitle: true,
    ),
  );
}