import 'package:flutter/material.dart';
import 'package:treasureflow/features/auth/citizen/presentation/screens/login_citizen_screen.dart';
import 'package:treasureflow/features/auth/citizen/presentation/screens/register_citizen_screen.dart';
import 'package:treasureflow/features/auth/local/presentation/screens/register_local_screen.dart';
import 'package:treasureflow/features/onboarding/presentation/screens/select_role_step6_screen.dart';
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

      
      initialRoute: '/step6',
      routes: {

        //on boarding
        '/step6': (context) => const SelectRoleStep6Screen(),

        //ciudaano
        '/login': (context) => const LoginCitizenScreen(),
        '/registerCitizen': (context) => const RegisterCitizenScreen(),

        //local
        '/registerLocalStep1': (context) => const RegisterLocalScreen(),
        
      },

    );
  }
}