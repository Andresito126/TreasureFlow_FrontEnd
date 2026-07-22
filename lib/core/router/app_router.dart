import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:treasureflow/core/router/onboarding_routes.dart';
import 'package:treasureflow/core/router/auth_routes.dart';
import 'package:treasureflow/core/router/home_routes.dart';
import 'package:treasureflow/core/router/posts_routes.dart';
import 'package:treasureflow/core/router/routes_routes.dart';
import 'package:treasureflow/core/router/sales_routes.dart';
import 'package:treasureflow/core/router/tracking_routes.dart';
import 'package:treasureflow/features/auth/presentation/providers/auth_provider.dart';

const _onboardingPaths = {
  '/onboardingStep1',
  '/onboardingStep2',
  '/onboardingStep3',
  '/onboardingStep4',
  '/onboardingStep5',
};

const _authPaths = {'/login', '/registerCitizen', '/registerLocalStep1'};

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

      // Las notificaciones push mandan /collectionDetail/:id para ambos roles;
      // se reescribe a la pantalla concreta según el tipo de usuario.
      final path = state.uri.path;
      if (path.startsWith('/collectionDetail/')) {
        final id = path.substring('/collectionDetail/'.length);
        return authProvider.userType == 'establishment'
            ? '/purchaseDetail/$id'
            : '/saleDetail/$id';
      }

      final isOnOnboarding = _onboardingPaths.contains(location);
      final isOnAuth = _authPaths.contains(location);

      // Si ya está autenticado y trata de ir a onboarding o login → home
      if (isAuthenticated && (isOnOnboarding || isOnAuth)) {
        final userType = authProvider.userType;
        return userType == 'establishment' ? '/homeLocal' : '/homeCitizen';
      }

      return null;
    },
    errorBuilder: (context, state) {
      final isAuthenticated = authProvider.isAuthenticated;
      final userType = authProvider.userType;
      final home = userType == 'establishment' ? '/homeLocal' : '/homeCitizen';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (isAuthenticated) context.go(home);
      });
      return const SizedBox.shrink();
    },
    routes: [
      ...onboardingRoutes,
      ...authRoutes,
      ...homeRoutes,
      ...postsRoutes,
      ...salesRoutes,
      ...routesRoutes,
      ...trackingRoutes,
    ],
  );
}
