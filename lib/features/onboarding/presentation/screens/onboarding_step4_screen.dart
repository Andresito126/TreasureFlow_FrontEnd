import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:treasureflow/shared/widgets/primary_button_green_widget.dart';
import '../../../../shared/widgets/custom_back_button_widget.dart';

class OnboardingStep4Screen extends StatelessWidget {
  const OnboardingStep4Screen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFF0A0F16);
    const Color gridPanelColor = Color(0xFF1E2733);
    const Color bottomSheetColor = Color(0xFF11171E);
    const Color primaryGreen = Color(0xFF418939);

    final screenSize = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                children: [
                  Expanded(
                    child: Stack(
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
                          right: screenSize.width * 0.05,
                          bottom: 0,
                          child: SvgPicture.asset(
                            'assets/basurini/basurini_confused.svg',
                            height: 150,
                            placeholderBuilder: (context) => const SizedBox(
                              height: 150,
                              width: 120,
                              child: Placeholder(color: Colors.white24),
                            ),
                          ),
                        ),

                        Positioned(
                          right: screenSize.width * 0.35,
                          bottom: 110,
                          child: Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              Positioned(
                                bottom: -6,
                                right: 24,
                                child: Transform.rotate(
                                  angle: 45 * 3.1415927 / 180,
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),

                                child: Image.asset(
                                  'assets/onboarding/house_green.png',
                                  height: 48,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                        Icons.storefront,
                                        color: Colors.teal,
                                        size: 48,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    width: double.infinity,
                    height: screenSize.height * 0.28,
                    padding: const EdgeInsets.only(
                      left: 24.0,
                      right: 24.0,
                      top: 32.0,
                      bottom: 24.0,
                    ),
                    decoration: const BoxDecoration(
                      color: gridPanelColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),

                    child: Image.asset(
                      'assets/onboarding/tabla_materiales.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(
                            child: CircularProgressIndicator(
                              color: primaryGreen,
                            ),
                          ),
                    ),
                  ),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(
                      left: 24.0,
                      right: 24.0,
                      top: 24.0,
                      bottom: 48.0,
                    ),
                    decoration: const BoxDecoration(
                      color: bottomSheetColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AHORA COMO UN',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'ESTABLECIMIENTO',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Puedes comprar productos\ny configurar tu local',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                            height: 1.5,
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
                                  context.push('/onboardingStep5');
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