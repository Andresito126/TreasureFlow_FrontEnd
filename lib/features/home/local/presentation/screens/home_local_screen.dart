import 'package:flutter/material.dart';
import 'package:treasureflow/features/home/local/presentation/widgets/accepted_offer_card_widget.dart';
import 'package:treasureflow/features/home/local/presentation/widgets/local_action_card_widget.dart';
import 'package:treasureflow/features/home/local/presentation/widgets/review_card_widget.dart';
import 'package:treasureflow/features/home/local/presentation/widgets/solicitud_card_widget.dart';
import 'package:treasureflow/features/home/shared/widgets/premium_banner_widget.dart';
import 'package:treasureflow/shared/widgets/floating_nav_bar_widget.dart';

class HomeLocalScreen extends StatefulWidget {
  const HomeLocalScreen({super.key});

  @override
  State<HomeLocalScreen> createState() => _HomeLocalScreenState();
}

class _HomeLocalScreenState extends State<HomeLocalScreen> {
  int _currentNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(colors, textTheme),
                  const SizedBox(height: 20),

                  const PremiumBannerWidget(),
                  const SizedBox(height: 20),

                  _buildActionOptions(colors),
                  const SizedBox(height: 24),

                  _buildSectionHeader(
                    'Solicitudes nuevas',
                    '1',
                    colors,
                    textTheme,
                  ),
                  const SizedBox(height: 12),
                  const SolicitudCardWidget(
                    title: '50 botellas PET',
                    date: '2 Jun 2026',
                    views: '52',
                    offersCount: '5 ofertas',
                    address:
                        'Olivo Sur 503-315, Patria Nueva, 29045 Tuxtla Gutiérrez, Chis.',
                    actionLabel: 'Ofertar residuos',
                  ),
                  const SizedBox(height: 24),

                  _buildSectionHeader(
                    'Ofertas aceptadas',
                    '1',
                    colors,
                    textTheme,
                  ),
                  const SizedBox(height: 12),
                  const AcceptedOfferCardWidget(
                    title: '50 botellas PET',
                    price: '\$10.00',
                    date: '2 Jun 2026',
                    address:
                        'Olivo Sur 503-315, Patria Nueva, 29045 Tuxtla Gutiérrez, Chis.',
                  ),
                  const SizedBox(height: 24),

                  _buildSectionHeader('Nuevas reseñas', '1', colors, textTheme),
                  const SizedBox(height: 12),
                  const ReviewCardWidget(
                    reviewerName: 'María G.',
                    rating: 5,
                    comment:
                        'Excelente atención, muy ordenados con los materiales.',
                    timeAgo: 'hace 3 días',
                  ),
                ],
              ),
            ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: FloatingNavBarWidget(
                currentIndex: _currentNavIndex,
                onTap: (index) => setState(() => _currentNavIndex = index),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colors, TextTheme textTheme) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '¡Bienvenido Centro de Acopio la Palma!',
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w400),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.notifications_outlined,
            size: 22,
            color: colors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionOptions(ColorScheme colors) {
    return const IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            child: LocalActionCardWidget(
              title: 'Ofertar residuos',
              subtitle: 'Ofrecer monto por residuos',
              icon: Icons.attach_money,
              gradientColors: [Color(0xFF2D7D46), Color(0xFF4CAF50)],
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: LocalActionCardWidget(
              title: 'Atender solicitudes',
              subtitle: 'Revisar solicitudes para recolección',
              icon: Icons.assignment_outlined,
              gradientColors: [Color(0xFFF5A623), Color(0xFFFEC562)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    String count,
    ColorScheme colors,
    TextTheme textTheme,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w400),
        ),
        Container(
          padding: const EdgeInsets.all(4),
          constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              count,
              style: textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontSize: 11,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
