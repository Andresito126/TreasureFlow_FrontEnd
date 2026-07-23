import 'package:go_router/go_router.dart';
import 'package:treasureflow/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:treasureflow/features/auth/presentation/screens/login_screen.dart';
import 'package:treasureflow/features/auth/presentation/screens/register_citizen_screen.dart';
import 'package:treasureflow/features/auth/presentation/screens/register_local_screen.dart';

final List<GoRoute> authRoutes = [
  GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
  GoRoute(
    path: '/forgotPassword',
    builder: (context, state) => const ForgotPasswordScreen(),
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
