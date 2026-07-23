import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:treasureflow/shared/widgets/primary_button_green_widget.dart';
import '../../../../shared/widgets/custom_back_button_widget.dart';

class OnboardingStep2Screen extends StatelessWidget {
  const OnboardingStep2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFF0A0F16);
    const Color bottomSheetColor = Color(0xFF11171E);
    const Color primaryGreen = Color(0xFF418939);

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

          SafeArea(
            bottom: false,
            child: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    children: [
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),

                            child: Image.asset(
                              'assets/auth/step2_diagram.png',
                              width: double.infinity,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Placeholder(
                                    color: Colors.white24,
                                    fallbackHeight: 300,
                                  ),
                            ),
                          ),
                        ),
                      ),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(
                          left: 24.0,
                          right: 24.0,
                          top: 32.0,
                          bottom: 48.0,
                        ),
                        decoration: const BoxDecoration(
                          color: bottomSheetColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(32),
                            topRight: Radius.circular(32),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white,
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                                children: const [
                                  TextSpan(text: 'Como '),
                                  TextSpan(
                                    text: 'CIUDADANO',
                                    style: TextStyle(
                                      color: primaryGreen,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        ', da segundas vidas a tus objetos y residuos.',
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            RichText(
                              text: TextSpan(
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white,
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                                children: const [
                                  TextSpan(text: 'Como '),
                                  TextSpan(
                                    text: 'ESTABLECIMIENTO',
                                    style: TextStyle(
                                      color: primaryGreen,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        ' , integra nuevos recursos y fortalece tu negocio.',
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 32),

                            Row(
                              children: [
                                _buildDot(
                                  isActive: true,
                                  isWide: true,
                                  color: primaryGreen,
                                ),
                                const SizedBox(width: 8),
                                _buildDot(
                                  isActive: true,
                                  isWide: true,
                                  color: primaryGreen,
                                ),
                                const SizedBox(width: 8),
                                _buildDot(
                                  isActive: false,
                                  isWide: false,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                _buildDot(
                                  isActive: false,
                                  isWide: false,
                                  color: Colors.white,
                                ),
                              ],
                            ),

                            const SizedBox(height: 32),

                            Row(
                              children: [
                                const CustomBackButtonWidget(),

                                const SizedBox(width: 16),

                                Expanded(
                                  child: PrimaryButtonGreenWidget(
                                    text: 'CONTINUAR',
                                    onPressed: () {
                                      context.push('/onboardingStep3');
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot({
    required bool isActive,
    required bool isWide,
    required Color color,
  }) {
    return Container(
      width: isWide ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? color : color.withOpacity(0.5),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
