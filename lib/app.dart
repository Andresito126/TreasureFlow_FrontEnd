import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:treasureflow/core/maps/di/map_module.dart';
import 'package:treasureflow/core/maps/presentation/providers/map_provider.dart';
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
      child: MaterialApp.router(
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
        title: 'TreasureFlow',
        theme: LightTheme.theme,
        darkTheme: DarkTheme.theme,
        themeMode: ThemeMode.system,
      ),
    );
  }
}
