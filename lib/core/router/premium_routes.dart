import 'package:go_router/go_router.dart';
import 'package:treasureflow/features/premium/citizen/presentation/screens/premium_citizen_screen.dart';
import 'package:treasureflow/features/premium/local/presentation/screens/premium_local_screen.dart';

final List<GoRoute> premiumRoutes = [
  GoRoute(
    path: '/premiumCitizen',
    builder: (context, state) => const PremiumCitizenScreen(),
  ),
  GoRoute(
    path: '/premiumLocal',
    builder: (context, state) => const PremiumLocalScreen(),
  ),
];
