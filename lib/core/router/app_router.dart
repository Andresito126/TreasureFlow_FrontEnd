import 'package:go_router/go_router.dart';
import 'package:treasureflow/core/router/onboarding_routes.dart';
import 'package:treasureflow/core/router/auth_routes.dart';
import 'package:treasureflow/core/router/home_routes.dart';
import 'package:treasureflow/core/router/posts_routes.dart';
import 'package:treasureflow/features/auth/citizen/presentation/providers/auth_provider.dart';

const _onboardingPaths = {
  '/onboardingStep1',
  '/onboardingStep2',
  '/onboardingStep3',
  '/onboardingStep4',
  '/onboardingStep5',
};

const _authPaths = {
  '/login',
  '/registerCitizen',
  '/registerLocalStep1',
};

GoRouter createRouter({
  required String initialLocation,
  required AuthProvider authProvider,
}) {
  return GoRouter(
    initialLocation: initialLocation,
    refreshListenable: authProvider,
    redirect: (context, state) {
      final isAuthenticated = authProvider.isAuthenticated;
      final location = state.matchedLocation;

      final isOnOnboarding = _onboardingPaths.contains(location);
      final isOnAuth = _authPaths.contains(location);

      // Si ya está autenticado y trata de ir a onboarding o login → home
      if (isAuthenticated && (isOnOnboarding || isOnAuth)) {
        final userType = authProvider.userType;
        return userType == 'establishment' ? '/homeLocal' : '/homeCitizen';
      }

      return null;
    },
    routes: [
      ...onboardingRoutes,
      ...authRoutes,
      ...homeRoutes,
      ...postsRoutes,
    ],
  );
}
