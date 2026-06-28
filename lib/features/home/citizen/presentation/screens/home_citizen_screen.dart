import 'package:flutter/material.dart';
import 'package:treasureflow/features/home/citizen/presentation/widgets/action_card_widget.dart';
import 'package:treasureflow/features/home/citizen/presentation/widgets/activity_summary_card_widget.dart';
import 'package:treasureflow/features/home/citizen/presentation/widgets/establishment_card_widget.dart';
import 'package:treasureflow/features/home/citizen/presentation/widgets/object_nearby_card_widget.dart';
import 'package:treasureflow/features/home/citizen/presentation/widgets/offer_card_widget.dart';
import 'package:treasureflow/features/home/citizen/presentation/widgets/stat_card_widget.dart';
import 'package:treasureflow/features/home/shared/widgets/premium_banner_widget.dart';
import 'package:treasureflow/shared/widgets/floating_nav_bar_widget.dart';

class HomeCitizenScreen extends StatefulWidget {
  const HomeCitizenScreen({super.key});

  @override
  State<HomeCitizenScreen> createState() => _HomeCitizenScreenState();
}

class _HomeCitizenScreenState extends State<HomeCitizenScreen> {
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

                  _sectionTitle('Resumen de tus actividades', textTheme),
                  const SizedBox(height: 12),
                  const ActivitySummaryCardWidget(
                    amount: '\$ 1,265.75',
                    percentChange: '18%',
                  ),
                  const SizedBox(height: 12),
                  const IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: StatCardWidget(
                            icon: Icons.article_outlined,
                            value: '15',
                            title: 'Publicaciones hechas',
                            subtitle: 'Activas y finalizadas',
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: StatCardWidget(
                            icon: Icons.inventory_2_outlined,
                            value: '15',
                            title: 'Objetos obtenidos',
                            subtitle: 'De segunda vida',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  _sectionTitle('¿Qué vas a hacer hoy?', textTheme),
                  const SizedBox(height: 12),
                  _buildActionCards(),
                  const SizedBox(height: 24),

                  _sectionTitle('Establecimientos destacados', textTheme),
                  const SizedBox(height: 12),
                  _buildHorizontalList(
                    itemCount: 5,
                    itemBuilder: (index) => const EstablishmentCardWidget(
                      name: 'MetalRecicla S.A',
                      distance: '1.5 km',
                      rating: 4.8,
                      reviewCount: 50,
                      materials: ['Metales', 'Plásticos', 'Baterías'],
                      isPremium: true,
                    ),
                  ),
                  const SizedBox(height: 24),

                  _sectionTitle('Objetos cerca de ti', textTheme),
                  const SizedBox(height: 12),
                  _buildHorizontalList(
                    itemCount: 5,
                    itemBuilder: (index) => const ObjectNearbyCardWidget(
                      objectName: 'Mesa de madera',
                      price: '\$1,200',
                      ownerName: 'Andre Gutiérrez',
                      timeAgo: '3 hrs',
                      distance: '1.5 km',
                    ),
                  ),
                  const SizedBox(height: 24),

                  _sectionTitle('Ofertas recibidas', textTheme),
                  const SizedBox(height: 12),
                  _buildHorizontalList(
                    itemCount: 3,
                    itemBuilder: (index) {
                      final offers = [
                        const OfferCardWidget(
                          objectName: 'Silla de madera',
                          offeredPrice: '\$120',
                          buyerName: 'EcoCentro Verde',
                          timeAgo: 'hace 2 hrs',
                          status: 'Pendiente',
                        ),
                        const OfferCardWidget(
                          objectName: 'Bicicleta urbana',
                          offeredPrice: '\$250',
                          buyerName: 'GreenShop',
                          timeAgo: 'hace 5 hrs',
                          status: 'Pendiente',
                        ),
                        const OfferCardWidget(
                          objectName: 'Mesa de centro',
                          offeredPrice: '\$180',
                          buyerName: 'Hogar Sustentable',
                          timeAgo: 'hace 1 día',
                          status: 'Aceptada',
                        ),
                      ];
                      return offers[index];
                    },
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
        CircleAvatar(
          radius: 22,
          backgroundColor: colors.primary.withValues(alpha: 0.1),
          child: Icon(Icons.person, color: colors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hola, Carlos!',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Vamos a ayudar el planeta hoy',
                style: textTheme.bodySmall?.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.6),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.notifications_outlined, size: 22, color: colors.primary),
        ),
      ],
    );
  }

  Widget _sectionTitle(String text, TextTheme textTheme) {
    return Text(
      text,
      style: textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildActionCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 12) / 2;
        final cardHeight = cardWidth * 0.55;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: const [
            ActionCardWidget(
              title: 'Publicar',
              subtitle: 'Sube algo que ya no uses',
              icon: Icons.add_a_photo_outlined,
              gradientColors: [Color(0xFF17B593), Color(0xFF5ACA7E)],
            ),
            ActionCardWidget(
              title: 'Ver locales',
              subtitle: 'Encuentra dónde llevar tu material',
              icon: Icons.storefront_outlined,
              gradientColors: [Color(0xFF59B3E0), Color(0xFF30A3F3)],
            ),
            ActionCardWidget(
              title: 'Explorar',
              subtitle: 'Descubre objetos cerca de ti',
              icon: Icons.explore_outlined,
              gradientColors: [Color(0xFF6D53ED), Color(0xFF9F72F7)],
            ),
            ActionCardWidget(
              title: 'Mis ofertas',
              subtitle: 'Gestiona tus publicaciones',
              icon: Icons.local_offer_outlined,
              gradientColors: [Color(0xFFF5A32E), Color(0xFFFEC562)],
            ),
          ].map((card) {
            return SizedBox(
              width: cardWidth,
              height: cardHeight,
              child: card,
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildHorizontalList({
    required int itemCount,
    required Widget Function(int index) itemBuilder,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: List.generate(itemCount, (index) {
            return Padding(
              padding: EdgeInsets.only(right: index < itemCount - 1 ? 10 : 0),
              child: itemBuilder(index),
            );
          }),
        ),
      ),
    );
  }
}
