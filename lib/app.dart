import 'package:flutter/material.dart';
import 'package:treasureflow/features/auth/citizen/presentation/screens/login_citizen_screen.dart';
import 'package:treasureflow/shared/theme/dark_theme.dart';
import 'package:treasureflow/shared/theme/light_theme.dart';


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'TreasureFlow',

      theme: LightTheme.theme,
      darkTheme: DarkTheme.theme,
      themeMode: ThemeMode.system,

      home:  LoginSCitizencreen(),
    );
  }
}