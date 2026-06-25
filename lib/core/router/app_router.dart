import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:treasureflow/features/onboarding/presentation/screens/onboarding_step1_screen.dart';
import 'package:treasureflow/features/onboarding/presentation/screens/onboarding_step2_screen.dart';
import 'package:treasureflow/features/onboarding/presentation/screens/onboarding_step3_screen.dart';
import 'package:treasureflow/features/onboarding/presentation/screens/onboarding_step4_screen.dart';
import 'package:treasureflow/features/onboarding/presentation/screens/select_role_step5_screen.dart';
import 'package:treasureflow/features/auth/citizen/presentation/screens/login_citizen_screen.dart';
import 'package:treasureflow/features/auth/citizen/presentation/screens/register_citizen_screen.dart';
import 'package:treasureflow/features/auth/local/presentation/screens/register_local_screen.dart';
import 'package:treasureflow/features/posts/waste/presentation/screens/management_waste_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/onboardingStep1',

  // cCOMO NAVEGAR:
  // Para siguietne: context.push('/onboardingStep2');
  // Para regresar: context.pop();
  // Quita la pantalla en la que esta y pone la nueva en su lugar: context.replace('/onboardingStep1');
  // Borrar toda la cola de navegación:  context.go('/home');
  routes: [
    // ----------------------- ON BOARDING -------------------
    GoRoute(
      path: '/onboardingStep1',
      builder: (context, state) => const OnboardingStep1Screen(),
    ),
    GoRoute(
      path: '/onboardingStep2',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const OnboardingStep2Screen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Aanimacion de fade
          return FadeTransition(
            opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    ),

    GoRoute(
      path: '/onboardingStep3',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const OnboardingStep3Screen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Aanimacion de fade
          return FadeTransition(
            opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    ),

        GoRoute(
      path: '/onboardingStep4',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const OnboardingStep4Screen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Aanimacion de fade
          return FadeTransition(
            opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    ),

    GoRoute(
      path: '/onboardingStep5',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const SelectRoleStep6Screen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    ),

    // ----------------------- CIUDADANO -------------------

    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginCitizenScreen(),
    ),
    GoRoute(
      path: '/registerCitizen',
      builder: (context, state) => const RegisterCitizenScreen(),
    ),
    GoRoute(
      path: '/managementWaste',
      builder: (context, state) => const ManagementWasteScreen(),
    ),

    // ----------------------- LOCAL -------------------
    
    GoRoute(
      path: '/registerLocalStep1',
      builder: (context, state) => const RegisterLocalScreen(),
    ),
  ],
);
