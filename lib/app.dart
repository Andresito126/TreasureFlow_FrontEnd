import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:treasureflow/core/maps/di/map_module.dart';
import 'package:treasureflow/core/maps/presentation/providers/map_provider.dart';
import 'package:treasureflow/features/auth/citizen/presentation/screens/login_citizen_screen.dart';
import 'package:treasureflow/features/auth/citizen/presentation/screens/register_citizen_screen.dart';
import 'package:treasureflow/features/auth/local/presentation/screens/register_local_screen.dart';
import 'package:treasureflow/features/onboarding/presentation/screens/select_role_step6_screen.dart';
import 'package:treasureflow/features/posts/waste/presentation/screens/management_waste_screen.dart';
import 'package:treasureflow/core/router/app_router.dart';
import 'package:treasureflow/shared/theme/dark_theme.dart';
import 'package:treasureflow/shared/theme/light_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MapProvider>(
          create: (_) => MapModule.createProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'TreasureFlow',
        theme: LightTheme.theme,
        darkTheme: DarkTheme.theme,
        themeMode: ThemeMode.system,
        initialRoute: '/step6',
        routes: {
          // onboarding
          '/step6': (context) => const SelectRoleStep6Screen(),
          // ciudadano
          '/login': (context) => const LoginCitizenScreen(),
          '/registerCitizen': (context) => const RegisterCitizenScreen(),
          // local
          '/registerLocalStep1': (context) => const RegisterLocalScreen(),
        },
      ),
    return MaterialApp.router(
      routerConfig: appRouter,

      debugShowCheckedModeBanner: false,
      title: 'TreasureFlow',
      theme: LightTheme.theme,
      darkTheme: DarkTheme.theme,
      themeMode: ThemeMode.system,

    );
  }
}