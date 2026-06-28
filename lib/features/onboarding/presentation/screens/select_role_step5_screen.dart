import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:treasureflow/shared/widgets/custom_back_button_widget.dart';
import '../widgets/role_selection_card.dart';

class SelectRoleStep6Screen extends StatelessWidget {
  const SelectRoleStep6Screen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFF0A0F16);
    const Color primaryGreen = Color(0xFF34A853);
    const Color primaryYellow = Color(0xFFEAB308);

    final size = MediaQuery.sizeOf(context);

    double resFont(double baseSize) {
      return (baseSize * (size.width / 390)).clamp(
        baseSize * 0.8,
        baseSize * 1.3,
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
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
                      children: [
                        const Icon(
                          Icons.recycling,
                          color: primaryGreen,
                          size: 28,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'SoftGenix',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: resFont(18),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const Spacer(flex: 1),

                    SizedBox(
                      height: (size.height * 0.30).clamp(180.0, 350.0),
                      width: double.infinity,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Lottie.asset(
                            'assets/animations/basurita_saludando_white.json',
                            height: (size.height * 0.30).clamp(180.0, 350.0),
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

                    const SizedBox(height: 32),

                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: resFont(32),
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          fontFamily: 'Poppins',
                        ),
                        children: const [
                          TextSpan(
                            text: 'EL VIAJE ',
                            style: TextStyle(color: Colors.white),
                          ),
                          TextSpan(
                            text: 'ESTÁ ',
                            style: TextStyle(color: primaryGreen),
                          ),
                          TextSpan(
                            text: 'LISTO',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildDashLine(),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Icon(Icons.eco, color: primaryGreen, size: 16),
                        ),
                        _buildDashLine(),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'ELIGE TU ROL PARA EMPEZAR',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: resFont(14),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                      ),
                    ),

                    const SizedBox(height: 32),

                    RoleSelectionCard(
                      glowColor: primaryGreen,
                      roleTitle: 'CIUDADANO',
                      icon: Icons.person_outline,
                      onTap: () {
                        context.push('/registerCitizen');
                      },
                    ),

                    const SizedBox(height: 20),

                    RoleSelectionCard(
                      glowColor: primaryYellow,
                      roleTitle: 'ESTABLECIMIENTO',
                      icon: Icons.storefront_outlined,
                      onTap: () {
                        context.push('/registerLocalStep1');
                      },
                    ),

                    const Spacer(flex: 2),

                    TextButton(
                      onPressed: () {
                        context.push('/login');
                      },
                      child: RichText(
                        text: TextSpan(
                          text: '¿Ya eres usuario de la app? ',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: resFont(14),
                          ),
                          children: const [
                            TextSpan(
                              text: 'Inicia Sesión',
                              style: TextStyle(
                                color: Color(0xFF34A853),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    const CustomBackButtonWidget(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashLine() {
    return Container(
      width: 30,
      height: 2,
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}
