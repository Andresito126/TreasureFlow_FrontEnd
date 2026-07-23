import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:treasureflow/features/onboarding/presentation/screens/onboarding_step1_screen.dart';
import 'package:treasureflow/features/onboarding/presentation/screens/onboarding_step2_screen.dart';
import 'package:treasureflow/features/onboarding/presentation/screens/onboarding_step3_screen.dart';
import 'package:treasureflow/features/onboarding/presentation/screens/onboarding_step4_screen.dart';
import 'package:treasureflow/features/onboarding/presentation/screens/select_role_step5_screen.dart';

final List<GoRoute> onboardingRoutes = [
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
];
