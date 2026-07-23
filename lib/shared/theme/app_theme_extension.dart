import 'package:flutter/material.dart';

@immutable
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final Color yellowComplete;
  final Color blueHold;
  final Color redExpired;

  const AppThemeExtension({
    required this.yellowComplete,
    required this.blueHold,
    required this.redExpired,
  });

  @override
  AppThemeExtension copyWith({
    Color? yellowComplete,
    Color? blueHold,
    Color? redExpired,
  }) {
    return AppThemeExtension(
      yellowComplete: yellowComplete ?? this.yellowComplete,
      blueHold: blueHold ?? this.blueHold,
      redExpired: redExpired ?? this.redExpired,
    );
  }

  @override
  AppThemeExtension lerp(ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) return this;
    return AppThemeExtension(
      yellowComplete: Color.lerp(yellowComplete, other.yellowComplete, t)!,
      blueHold: Color.lerp(blueHold, other.blueHold, t)!,
      redExpired: Color.lerp(redExpired, other.redExpired, t)!,
    );
  }
}