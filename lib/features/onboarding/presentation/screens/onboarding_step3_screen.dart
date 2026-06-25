import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:treasureflow/shared/widgets/primary_button_green_widget.dart';
import '../../../../shared/widgets/custom_back_button_widget.dart';

class OnboardingStep3Screen extends StatelessWidget {
  const OnboardingStep3Screen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFF0A0F16);
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
                        Positioned.fill(
                          child: Image.asset(
                            'assets/onboarding/step3_map.png',
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                            errorBuilder: (context, error, stackTrace) =>
                                const Placeholder(color: Colors.white10),
                          ),
                        ),
                        Positioned(
                          top: 16,
                          left: 24,
                          right: 24,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: bottomSheetColor.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: primaryGreen.withOpacity(0.5),
                                width: 1,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black45,
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.3),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.location_on,
                                    color: primaryGreen,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                RichText(
                                  text: TextSpan(
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                    children: const [
                                      TextSpan(
                                        text: '2.- ',
                                        style: TextStyle(color: primaryGreen),
                                      ),
                                      TextSpan(text: 'Mapa y ofertas:'),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Ubica centros de acopio,\nrecibe ofertas y califica.',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        Positioned(
                          left: screenSize.width * 0.02,
                          top: screenSize.height * 0.24,
                          child: SvgPicture.asset(
                            'assets/basurini/basurini_surprised.svg',
                            height: 140,
                            placeholderBuilder: (context) => const SizedBox(
                              height: 140,
                              width: 100,
                              child: Placeholder(color: Colors.white24),
                            ),
                          ),
                        ),

                        Positioned(
                          right: -10,
                          bottom: 10,
                          child: SvgPicture.asset(
                            'assets/basurini/basurini_confused.svg',
                            height: 110,
                            placeholderBuilder: (context) => const SizedBox(
                              height: 110,
                              width: 80,
                              child: Placeholder(color: Colors.white24),
                            ),
                          ),
                        ),

                        Positioned(
                          right: screenSize.width * 0.08,
                          top: screenSize.height * 0.28,
                          child: Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              Positioned(
                                bottom: -8,
                                child: Transform.rotate(
                                  angle: 45 * 3.1415927 / 180,
                                  child: Container(
                                    width: 16,
                                    height: 16,
                                    decoration: const BoxDecoration(
                                      color: bottomSheetColor,
                                      border: Border(
                                        bottom: BorderSide(
                                          color: primaryGreen,
                                          width: 1.5,
                                        ),
                                        right: BorderSide(
                                          color: primaryGreen,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: bottomSheetColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: primaryGreen,
                                    width: 1.5,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black45,
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Icon(
                                        Icons.storefront,
                                        color: Colors.teal,
                                        size: 36,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Los hermanos',
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                        ),
                                        Text(
                                          'Recicladora',
                                          style: theme.textTheme.labelMedium
                                              ?.copyWith(color: Colors.white54),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: const [
                                            Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                              size: 14,
                                            ),
                                            Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                              size: 14,
                                            ),
                                            Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                              size: 14,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: primaryGreen,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: const Text(
                                            'Ver',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
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
                              fontWeight: FontWeight.w600,
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
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'UBICA, APROVECHA Y VALORA',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tu red personal de oportunidades.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
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
                                  context.push('/onboardingStep4');
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
