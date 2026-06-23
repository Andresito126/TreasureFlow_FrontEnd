import 'package:flutter/material.dart';

import '../widgets/role_selection_card.dart'; 

class SelectRoleStep6Screen extends StatelessWidget {
  const SelectRoleStep6Screen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFF0A0F16);
    const Color primaryGreen = Color(0xFF34A853);
    const Color primaryYellow = Color(0xFFEAB308);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              
              Row(
                children: [
                  Icon(Icons.recycling, color: primaryGreen, size: 28),
                  const SizedBox(width: 8),
                  const Text(
                    'Treasure Flow',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              const Spacer(flex: 1),

              
              Image.asset(
                'assets/images/basurini_happy_placeholder.png', 
                height: 200,
                errorBuilder: (context, error, stackTrace) => const SizedBox(
                  height: 200,
                  width: 200,
                  child: Placeholder(color: Colors.white24),
                ),
              ),

              const SizedBox(height: 32),

              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    fontFamily: 'Poppins', 
                  ),
                  children: [
                    TextSpan(text: 'EL VIAJE ', style: TextStyle(color: Colors.white)),
                    TextSpan(text: 'ESTÁ ', style: TextStyle(color: primaryGreen)),
                    TextSpan(text: 'LISTO', style: TextStyle(color: Colors.white)),
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
              const Text(
                'ELIGE TU ROL PARA EMPEZAR',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
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
                  Navigator.pushNamed(context, '/registerCitizen');
                },
              ),

              const SizedBox(height: 20),
  
              RoleSelectionCard(
                glowColor: primaryYellow,
                roleTitle: 'ESTABLECIMIENTO',
                icon: Icons.storefront_outlined,
                onTap: () {
                  
                },
              ),

              const Spacer(flex: 2),
              

              
              TextButton(
                onPressed: () {
                  
                  Navigator.pushNamed(context, '/login');
                },
                child: RichText(
                  text: const TextSpan(
                    text: '¿Ya tienes una cuenta? ',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                    children: [
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

              
              Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: () {
                    
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  },
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: primaryGreen.withOpacity(0.5)),
                      color: primaryGreen.withOpacity(0.1),
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
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