import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:treasureflow/core/di/app_container.dart';
import 'package:treasureflow/core/maps/di/map_module.dart';
import 'package:treasureflow/core/maps/presentation/providers/map_provider.dart';
import 'package:treasureflow/core/router/app_router.dart';
import 'package:treasureflow/features/auth/di/auth_module.dart';
import 'package:treasureflow/features/auth/citizen/di/citizen_auth_module.dart';
import 'package:treasureflow/features/auth/citizen/presentation/providers/auth_provider.dart';
import 'package:treasureflow/features/auth/citizen/presentation/providers/register_citizen_provider.dart';
import 'package:treasureflow/features/auth/local/di/local_auth_module.dart';
import 'package:treasureflow/features/auth/local/presentation/providers/register_local_provider.dart';
import 'package:treasureflow/features/posts/waste/di/waste_post_module.dart';
import 'package:treasureflow/features/posts/waste/presentation/providers/create_waste_provider.dart';
import 'package:treasureflow/features/profile/di/profile_module.dart';
import 'package:treasureflow/features/profile/presentation/providers/profile_posts_provider.dart';
import 'package:treasureflow/shared/theme/dark_theme.dart';
import 'package:treasureflow/shared/theme/light_theme.dart';

class MyApp extends StatelessWidget {
  final AppContainer container;

  const MyApp({super.key, required this.container});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppContainer>.value(value: container),
        ChangeNotifierProvider<MapProvider>(
          create: (_) => MapModule.createProvider(),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthModule(container).provideAuthProvider(),
        ),
        ChangeNotifierProvider<RegisterCitizenProvider>(
          create: (_) => CitizenAuthModule(container).provideRegisterProvider(),
        ),
        ChangeNotifierProvider<RegisterLocalProvider>(
          create: (_) => LocalAuthModule(container).provideRegisterProvider(),
        ),
        ChangeNotifierProvider<CreateWasteProvider>(
          create: (_) => WastePostModule(container).provideCreateWasteProvider(),
        ),
        ChangeNotifierProvider<ProfilePostsProvider>(
          create: (_) => ProfileModule(container).provideProfilePostsProvider(),
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
