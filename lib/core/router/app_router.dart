import 'package:go_router/go_router.dart';
import 'package:treasureflow/core/router/onboarding_routes.dart';
import 'package:treasureflow/core/router/auth_routes.dart';
import 'package:treasureflow/core/router/home_routes.dart';
import 'package:treasureflow/core/router/posts_routes.dart';

final appRouter = GoRouter(
  initialLocation: '/onboardingStep1',

  // cCOMO NAVEGAR:
  // Para siguietne: context.push('/onboardingStep2');
  // Para regresar: context.pop();
  // Quita la pantalla en la que esta y pone la nueva en su lugar: context.replace('/onboardingStep1');
  // Borrar toda la cola de navegación:  context.go('/home');
  routes: [
    ...onboardingRoutes,
    ...authRoutes,
    ...homeRoutes,
    ...postsRoutes,
  ],
);
