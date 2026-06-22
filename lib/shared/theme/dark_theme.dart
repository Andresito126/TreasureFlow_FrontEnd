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