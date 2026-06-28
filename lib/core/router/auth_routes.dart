import 'package:go_router/go_router.dart';
import 'package:treasureflow/features/auth/citizen/presentation/screens/login_citizen_screen.dart';
import 'package:treasureflow/features/auth/citizen/presentation/screens/register_citizen_screen.dart';
import 'package:treasureflow/features/auth/local/presentation/screens/register_local_screen.dart';

final List<GoRoute> authRoutes = [
  GoRoute(
    path: '/login',
    builder: (context, state) => const LoginCitizenScreen(),
  ),
  GoRoute(
    path: '/registerCitizen',
    builder: (context, state) => const RegisterCitizenScreen(),
  ),
  GoRoute(
    path: '/registerLocalStep1',
    builder: (context, state) => const RegisterLocalScreen(),
  ),
];
