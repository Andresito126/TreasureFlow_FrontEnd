import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_theme_extension.dart';

class DarkTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      scaffoldBackgroundColor: AppColors.backgroundDark,

      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryDark,
        secondary: AppColors.secondaryDark,

        background: AppColors.backgroundDark,
        surface: AppColors.backgroundBoxDark,

        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textColorDark,

        outline: AppColors.strokeDark,
        error: AppColors.errorDark,
      ),

      textTheme: TextTheme(

        // Titulos principales
        headlineLarge: const TextStyle(
          fontSize: 32.0,
          letterSpacing: 1.5,
          color: AppColors.textColorDark,
        ),

        // Titulos secundarios
        titleLarge: const TextStyle(
          fontSize: 20.0,
          letterSpacing: 1.2,
          color: AppColors.textColorDark,
        ),

        // Texto normal
        bodyMedium: const TextStyle(
          fontSize: 16.0,
          color: AppColors.textColorDark,
        ),

        // Texto pequeño
        bodySmall: const TextStyle(
          fontSize: 14.0,
          color: AppColors.textColorDark,
        ),
      ),


      extensions: const [
        AppThemeExtension(
          yellowComplete: AppColors.yellowCompleteDark,
          blueHold: AppColors.blueHoldDark,
          redExpired: AppColors.redExpiredDark,
        ),
      ],
    );
  }
  
}