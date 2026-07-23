import 'package:flutter/material.dart';
import 'package:treasureflow/features/premium/shared/presentation/screens/premium_screen_base.dart';

class PremiumCitizenScreen extends StatelessWidget {
  const PremiumCitizenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PremiumScreenBase(
      subtitle:
          'Dale más visibilidad a tus publicaciones y vende tu material más rápido.',
      features: [
        PremiumFeature('Publicar residuos y objetos'),
        PremiumFeature('Mapa, ofertas y pagos en la app'),
        PremiumFeature('Historial y calificaciones'),
        PremiumFeature('Publicaciones destacadas', freeIncluded: false),
        PremiumFeature('Insignia Premium en tu perfil', freeIncluded: false),
        PremiumFeature('Aviso prioritario a establecimientos', freeIncluded: false),
      ],
    );
  }
}
