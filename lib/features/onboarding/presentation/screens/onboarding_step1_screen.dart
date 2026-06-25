import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:treasureflow/shared/widgets/primary_button_green_widget.dart';

class OnboardingStep1Screen extends StatelessWidget {
  const OnboardingStep1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFF0A0F16);

    final screenSize = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: SvgPicture.asset(
              'assets/auth/bg_wave_top_left.svg',
              width: screenSize.width * 0.6,
              fit: BoxFit.cover,
            ),
          ),

          Positioned(
            bottom: 0,
            right: 0,
            child: SvgPicture.asset(
              'assets/auth/bg_wave_bottom_right.svg',
              width: screenSize.width * 0.7,
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 16.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(width: 12),
                            Text(
                              'SoftGenix',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(flex: 1),

                        Align(
                          alignment: Alignment.centerRight,
                          child: Transform.translate(
                            offset: const Offset(24, 0),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SvgPicture.asset(
                                  'assets/auth/welcome.svg',
                                  height: 48,
                                ),
                                const Text(
                                  '¡BIENVENIDO!',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const Spacer(flex: 1),

                        SizedBox(
                          height: screenSize.height * 0.30,
                          width: double.infinity,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Lottie.asset(
                                'assets/animations/basurita_saludando_white.json',
                                height: screenSize.height * 0.30,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Center(
                                      child: Icon(
                                        Icons.broken_image,
                                        color: Colors.white54,
                                        size: 48,
                                      ),
                                    ),
                              ),

                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 115,
                                  height: 40,
                                  color: bgColor,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(flex: 1),

                        Text(
                          '¡ TREASURE FLOW !',
                          style: theme.textTheme.headlineLarge?.copyWith(
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 16),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'Empecemos el viaje para dar\nuna segunda vida.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),

                        const Spacer(flex: 2),
                        PrimaryButtonGreenWidget(
                          text: 'EMPEZAR',
                          onPressed: () {
                            context.push('/onboardingStep2');
                          },
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
