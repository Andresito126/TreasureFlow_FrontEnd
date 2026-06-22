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