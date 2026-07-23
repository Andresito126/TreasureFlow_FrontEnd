import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:treasureflow/core/di/app_container.dart';
import 'package:treasureflow/core/maps/di/map_module.dart';
import 'package:treasureflow/core/maps/presentation/providers/map_provider.dart';
import 'package:treasureflow/core/router/app_router.dart';
import 'package:treasureflow/core/notifications/services/notification_service.dart';
import 'package:treasureflow/features/auth/di/auth_module.dart';
import 'package:treasureflow/features/auth/di/citizen_auth_module.dart';
import 'package:treasureflow/features/auth/presentation/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:treasureflow/features/auth/presentation/providers/register_citizen_provider.dart';
import 'package:treasureflow/features/auth/di/local_auth_module.dart';
import 'package:treasureflow/features/auth/presentation/providers/register_local_provider.dart';
import 'package:treasureflow/features/establishments/di/establishments_module.dart';
import 'package:treasureflow/features/establishments/presentation/providers/establishments_list_provider.dart';
import 'package:treasureflow/features/feed/di/feed_module.dart';
import 'package:treasureflow/features/feed/presentation/providers/feed_provider.dart';
import 'package:treasureflow/features/home/citizen/di/citizen_home_module.dart';
import 'package:treasureflow/features/home/citizen/presentation/providers/citizen_home_provider.dart';
import 'package:treasureflow/features/home/local/di/local_home_module.dart';
import 'package:treasureflow/features/home/local/presentation/providers/local_home_feed_provider.dart';
import 'package:treasureflow/features/home/local/presentation/providers/local_home_summary_provider.dart';
import 'package:treasureflow/features/posts/waste/di/waste_post_module.dart';
import 'package:treasureflow/features/posts/waste/presentation/providers/create_waste_provider.dart';
import 'package:treasureflow/features/profile/citizen/di/profile_module.dart';
import 'package:treasureflow/features/profile/citizen/presentation/providers/profile_posts_provider.dart';
import 'package:treasureflow/shared/theme/dark_theme.dart';
import 'package:treasureflow/shared/theme/light_theme.dart';

class MyApp extends StatefulWidget {
  final AppContainer container;
  final String initialLocation;

  const MyApp({super.key, required this.container, required this.initialLocation});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthProvider _authProvider;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authProvider = AuthModule(widget.container).provideAuthProvider();
    _router = createRouter(
      initialLocation: widget.initialLocation,
      authProvider: _authProvider,
    );
    NotificationService().setRouter(_router);
    _authProvider.checkAuth();
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppContainer>.value(value: widget.container),
        ChangeNotifierProvider<MapProvider>(
          create: (_) => MapModule.createProvider(),
        ),
        ChangeNotifierProvider<AuthProvider>.value(value: _authProvider),
        ChangeNotifierProvider<RegisterCitizenProvider>(
          create: (_) => CitizenAuthModule(widget.container).provideRegisterProvider(),
        ),
        ChangeNotifierProvider<RegisterLocalProvider>(
          create: (_) => LocalAuthModule(widget.container).provideRegisterProvider(),
        ),
        ChangeNotifierProvider<CreateWasteProvider>(
          create: (_) => WastePostModule(widget.container).provideCreateWasteProvider(),
        ),
        ChangeNotifierProvider<ProfilePostsProvider>(
          create: (_) => ProfileModule(widget.container).provideProfilePostsProvider(),
        ),
        ChangeNotifierProvider<FeedProvider>(
          create: (_) => FeedModule(widget.container).provideFeedProvider(),
        ),
        ChangeNotifierProvider<CitizenHomeProvider>(
          create: (_) => CitizenHomeModule(widget.container).provideProvider(),
        ),
        ChangeNotifierProvider<LocalHomeFeedProvider>(
          create: (_) => LocalHomeModule(widget.container).provideProvider(),
        ),
        ChangeNotifierProvider<LocalHomeSummaryProvider>(
          create: (_) => LocalHomeModule(widget.container).provideLocalHomeSummaryProvider(),
        ),
        ChangeNotifierProvider<EstablishmentsListProvider>(
          create: (_) => EstablishmentsModule(widget.container).provideListProvider(),
        ),
      ],
      child: MaterialApp.router(
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
        title: 'TreasureFlow',
        theme: LightTheme.theme,
        darkTheme: DarkTheme.theme,
        themeMode: ThemeMode.system,
      ),
    );
  }
}
