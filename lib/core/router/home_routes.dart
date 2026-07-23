import 'package:go_router/go_router.dart';
import 'package:treasureflow/features/auth/presentation/screens/change_password_screen.dart';
import 'package:treasureflow/features/establishments/presentation/screens/establishment_detail_screen.dart';
import 'package:treasureflow/features/establishments/presentation/screens/establishments_list_screen.dart';
import 'package:treasureflow/features/home/citizen/presentation/screens/home_citizen_screen.dart';
import 'package:treasureflow/features/home/local/presentation/screens/home_local_screen.dart';
import 'package:treasureflow/features/profile/citizen/presentation/screens/edit_citizen_profile_screen.dart';
import 'package:treasureflow/features/profile/citizen/presentation/screens/profile_screen.dart';
import 'package:treasureflow/features/profile/citizen/presentation/screens/settings_screen_citizen.dart';
import 'package:treasureflow/features/profile/local/presentation/screens/edit_establishment_profile_screen.dart';
import 'package:treasureflow/features/profile/local/presentation/screens/local_profile_screen.dart';
import 'package:treasureflow/features/profile/local/presentation/screens/settings_screen_local.dart';

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
    path: '/profileLocal',
    builder: (context, state) => const LocalProfileScreen(),
  ),
  GoRoute(
    path: '/settingsCitizen',
    builder: (context, state) => const SettingsScreenCitizen(),
  ),
  GoRoute(
    path: '/settingsLocal',
    builder: (context, state) => const SettingsScreenLocal(),
  ),
  GoRoute(
    path: '/editCitizenProfile',
    builder: (context, state) => const EditCitizenProfileScreen(),
  ),
  GoRoute(
    path: '/editEstablishmentProfile',
    builder: (context, state) => const EditEstablishmentProfileScreen(),
  ),
  GoRoute(
    path: '/changePassword',
    builder: (context, state) => const ChangePasswordScreen(),
  ),
  GoRoute(
    path: '/feed',
    builder: (context, state) => const EstablishmentsListScreen(),
  ),
  GoRoute(
    path: '/establishments',
    builder: (context, state) => const EstablishmentsListScreen(),
  ),
  GoRoute(
    path: '/establishmentDetail/:id',
    builder: (context, state) => EstablishmentDetailScreen(
      establishmentId: state.pathParameters['id']!,
    ),
  ),
];
