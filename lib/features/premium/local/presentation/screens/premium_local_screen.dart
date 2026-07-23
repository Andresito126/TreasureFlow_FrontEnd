import 'package:flutter/material.dart';
import 'package:treasureflow/features/premium/shared/presentation/screens/premium_screen_base.dart';

class PremiumLocalScreen extends StatelessWidget {
  const PremiumLocalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PremiumScreenBase(
      subtitle:
          'Llega a más ciudadanos y consigue más material para tu establecimiento.',
      features: [
        PremiumFeature('Perfil y materiales aceptados'),
        PremiumFeature('Aparecer en el mapa de ciudadanos'),
        PremiumFeature('Ver publicaciones y hacer ofertas'),
        PremiumFeature('Recolección a domicilio y calificaciones'),
        PremiumFeature('Acceso anticipado a nuevas publicaciones', freeIncluded: false),
        PremiumFeature('Aparecer primero en búsquedas', freeIncluded: false),
        PremiumFeature('Insignia Premium en tu perfil', freeIncluded: false),
      ],
    );
  }
}
