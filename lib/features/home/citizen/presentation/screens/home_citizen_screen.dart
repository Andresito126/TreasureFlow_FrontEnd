import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:treasureflow/features/home/citizen/domain/entities/citizen_home.dart';
import 'package:treasureflow/features/home/citizen/presentation/providers/citizen_home_provider.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CitizenHomeProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Consumer<CitizenHomeProvider>(
              builder: (context, provider, _) {
                final data = provider.data;

                return RefreshIndicator(
                  onRefresh: provider.load,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(data, colors, textTheme),
                        const SizedBox(height: 20),

                        const PremiumBannerWidget(),
                        const SizedBox(height: 20),

                        _sectionTitle('Resumen de tus actividades', textTheme),
                        const SizedBox(height: 12),
                        ActivitySummaryCardWidget(
                          amount: data != null
                              ? '\$${data.monthlyEarnings.toStringAsFixed(2)}'
                              : '\$ —',
                          percentChange: '—',
                        ),
                        const SizedBox(height: 12),
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: StatCardWidget(
                                  icon: Icons.article_outlined,
                                  value: data != null ? '${data.totalPublications}' : '—',
                                  title: 'Publicaciones hechas',
                                  subtitle: 'Activas y finalizadas',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: StatCardWidget(
                                  icon: Icons.inventory_2_outlined,
                                  value: data != null ? '${data.itemsObtained}' : '—',
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
                        _buildEstablishments(data, colors, textTheme),
                        const SizedBox(height: 24),

                        _sectionTitle('Objetos cerca de ti', textTheme),
                        const SizedBox(height: 12),
                        _buildNearbyItems(data, colors, textTheme),
                        const SizedBox(height: 24),

                        _sectionTitle('Ofertas recibidas', textTheme),
                        const SizedBox(height: 12),
                        _buildReceivedOffers(data, colors, textTheme),
                      ],
                    ),
                  ),
                );
              },
            ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: const FloatingNavBarWidget(currentIndex: 0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(CitizenHome? data, ColorScheme colors, TextTheme textTheme) {
    final pictureUrl = data?.profilePictureUrl;
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: colors.primary.withValues(alpha: 0.1),
          backgroundImage: pictureUrl != null ? NetworkImage(pictureUrl) : null,
          child: pictureUrl == null
              ? Icon(Icons.person, color: colors.primary)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data != null ? 'Hola, ${data.fullName.split(' ').first}!' : 'Hola!',
                style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
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

  Widget _buildEstablishments(CitizenHome? data, ColorScheme colors, TextTheme textTheme) {
    final establishments = data?.nearbyEstablishments ?? [];

    if (data == null) {
      return _buildHorizontalList(
        itemCount: 3,
        itemBuilder: (_) => const EstablishmentCardWidget(
          name: 'MetalRecicla S.A',
          distance: '1.5 km',
          rating: 4.8,
          reviewCount: 50,
          materials: ['Metales', 'Plásticos'],
          isPremium: true,
        ),
      );
    }

    if (establishments.isEmpty) {
      return _emptySection('No hay establecimientos cercanos', colors, textTheme);
    }

    return _buildHorizontalList(
      itemCount: establishments.length,
      itemBuilder: (i) => EstablishmentCardWidget(
        name: establishments[i].storeName,
        distance: establishments[i].distance,
        rating: establishments[i].averageRating,
        reviewCount: 0,
        materials: establishments[i].materials,
        isOpen: establishments[i].isOpen,
      ),
    );
  }

  Widget _buildNearbyItems(CitizenHome? data, ColorScheme colors, TextTheme textTheme) {
    final items = data?.nearbyItems ?? [];

    if (data == null) {
      return _buildHorizontalList(
        itemCount: 3,
        itemBuilder: (_) => const ObjectNearbyCardWidget(
          objectName: 'Mesa de madera',
          price: '\$1,200',
          ownerName: 'Andre Gutiérrez',
          timeAgo: '3 hrs',
          distance: '1.5 km',
        ),
      );
    }

    if (items.isEmpty) {
      return _emptySection('No hay objetos cerca de ti', colors, textTheme);
    }

    return _buildHorizontalList(
      itemCount: items.length,
      itemBuilder: (i) => ObjectNearbyCardWidget(
        objectName: items[i].description,
        price: '—',
        ownerName: 'Ciudadano',
        timeAgo: items[i].publishedAt,
        distance: items[i].distance,
      ),
    );
  }

  Widget _buildReceivedOffers(CitizenHome? data, ColorScheme colors, TextTheme textTheme) {
    final offers = data?.receivedOffers ?? [];

    if (data == null) {
      return _buildHorizontalList(
        itemCount: 2,
        itemBuilder: (_) => const OfferCardWidget(
          objectName: 'Silla de madera',
          offeredPrice: '\$120',
          buyerName: 'EcoCentro Verde',
          timeAgo: 'hace 2 hrs',
          status: 'Pendiente',
        ),
      );
    }

    if (offers.isEmpty) {
      return _emptySection('No tienes ofertas recibidas', colors, textTheme);
    }

    return _buildHorizontalList(
      itemCount: offers.length,
      itemBuilder: (i) => OfferCardWidget(
        objectName: 'Publicación de residuo',
        offeredPrice: '\$${offers[i].pricePerUnit.toStringAsFixed(2)}/${offers[i].unit}',
        buyerName: offers[i].establishmentName,
        timeAgo: offers[i].offeredAt,
        status: 'Pendiente',
        onTap: () => context.push('/wasteDetail/${offers[i].publicationId}'),
      ),
    );
  }

  Widget _emptySection(String message, ColorScheme colors, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        message,
        style: textTheme.bodySmall?.copyWith(
          color: colors.onSurface.withValues(alpha: 0.4),
        ),
      ),
    );
  }

  void _showPublishOptions(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '¿Qué quieres publicar?',
              style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _publishOption(
              icon: Icons.recycling,
              title: 'Publicar residuo',
              subtitle: 'Material reciclable para establecimientos',
              colors: colors,
              textTheme: textTheme,
              onTap: () {
                Navigator.pop(context);
                context.push('/createWaste');
              },
            ),
            const SizedBox(height: 12),
            _publishOption(
              icon: Icons.inventory_2_outlined,
              title: 'Publicar objeto',
              subtitle: 'Dale una segunda vida a lo que ya no uses',
              colors: colors,
              textTheme: textTheme,
              onTap: () {
                Navigator.pop(context);
                context.push('/createObject');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _publishOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required ColorScheme colors,
    required TextTheme textTheme,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.outline.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 24, color: colors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.5),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: colors.onSurface.withValues(alpha: 0.3)),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text, TextTheme textTheme) {
    return Text(
      text,
      style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
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
          children: [
            ActionCardWidget(
              title: 'Publicar',
              subtitle: 'Sube algo que ya no uses',
              icon: Icons.add_a_photo_outlined,
              gradientColors: const [Color(0xFF17B593), Color(0xFF5ACA7E)],
              onTap: () => _showPublishOptions(context),
            ),
            const ActionCardWidget(
              title: 'Ver locales',
              subtitle: 'Encuentra dónde llevar tu material',
              icon: Icons.storefront_outlined,
              gradientColors: [Color(0xFF59B3E0), Color(0xFF30A3F3)],
            ),
            const ActionCardWidget(
              title: 'Explorar',
              subtitle: 'Descubre objetos cerca de ti',
              icon: Icons.explore_outlined,
              gradientColors: [Color(0xFF6D53ED), Color(0xFF9F72F7)],
            ),
            const ActionCardWidget(
              title: 'Mis ofertas',
              subtitle: 'Gestiona tus publicaciones',
              icon: Icons.local_offer_outlined,
              gradientColors: [Color(0xFFF5A32E), Color(0xFFFEC562)],
            ),
          ].map((card) {
            return SizedBox(width: cardWidth, height: cardHeight, child: card);
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