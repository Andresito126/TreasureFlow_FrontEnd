import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_theme_extension.dart';

class LightTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      scaffoldBackgroundColor: AppColors.backgroundLight,

      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryLight,
        secondary: AppColors.secondaryLight,

        surface: AppColors.backgroundBoxLight,
        background: AppColors.backgroundLight,

        onSurface: AppColors.textColorLight,
        onPrimary: Colors.white,
        onSecondary: Colors.white,

        outline: AppColors.strokeLight,
        error: AppColors.errorLight,
      ),

      
      textTheme: TextTheme(

        // Titulos principales
        headlineLarge: const TextStyle(
          fontSize: 32.0,
          letterSpacing: 1.5,
          color: AppColors.textColorLight,
        ),

        // Titulos secundarios
        titleLarge: const TextStyle(
          fontSize: 20.0,
          letterSpacing: 1.2,
          color: AppColors.textColorLight,
        ),

        // Texto normal
        bodyMedium: const TextStyle(
          fontSize: 16.0,
          color: AppColors.textColorLight,
        ),

        // Texto pequeño
        bodySmall: const TextStyle(
          fontSize: 14.0,
          color: AppColors.textColorLight,
        ),
      ),


      extensions: const [
        AppThemeExtension(
          yellowComplete: AppColors.yellowCompleteLight,
          blueHold: AppColors.blueHoldLight,
          redExpired: AppColors.redExpiredLight,
        ),
      ],
    );
  }
}
