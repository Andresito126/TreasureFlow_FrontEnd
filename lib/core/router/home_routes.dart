import 'package:go_router/go_router.dart';
import 'package:treasureflow/features/home/citizen/presentation/screens/home_citizen_screen.dart';
import 'package:treasureflow/features/home/local/presentation/screens/home_local_screen.dart';
import 'package:treasureflow/features/profile/presentation/screens/profile_screen.dart';
import 'package:treasureflow/features/profile/presentation/screens/settings_screen_citizen.dart';

final List<GoRoute> homeRoutes = [
  GoRoute(
    path: '/homeCitizen',
    builder: (context, state) => const HomeCitizenScreen(),
  ),
  GoRoute(
    path: '/homeLocal',
    builder: (context, state) => const HomeLocalScreen(),
  ),
  GoRoute(
    path: '/profile',
    builder: (context, state) => const ProfileScreen(),
  ),
  GoRoute(
    path: '/settingsCitizen',
    builder: (context, state) => const SettingsScreenCitizen(),
  ),
];
