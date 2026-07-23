import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:treasureflow/features/home/citizen/domain/entities/citizen_home.dart';
import 'package:treasureflow/features/home/citizen/presentation/providers/citizen_home_provider.dart';
import 'package:treasureflow/features/home/citizen/presentation/widgets/action_card_widget.dart';
import 'package:treasureflow/features/home/citizen/presentation/widgets/activity_summary_card_widget.dart';
import 'package:treasureflow/features/home/citizen/presentation/widgets/establishment_card_widget.dart';
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
                        SizedBox(
                          width: double.infinity,
                          child: StatCardWidget(
                            icon: Icons.article_outlined,
                            value: data != null
                                ? '${data.totalPublications}'
                                : '—',
                            title: 'Publicaciones hechas',
                            subtitle: 'Activas y finalizadas',
                          ),
                        ),
                        const SizedBox(height: 24),

                        _sectionTitle('¿Qué vas a hacer hoy?', textTheme),
                        const SizedBox(height: 12),
                        _buildActionCards(),
                        const SizedBox(height: 24),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _sectionTitle(
                              'Establecimientos destacados',
                              textTheme,
                            ),
                            TextButton(
                              onPressed: () => context.push('/establishments'),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Ver más',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildEstablishments(data, colors, textTheme),
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

  Widget _buildHeader(
    CitizenHome? data,
    ColorScheme colors,
    TextTheme textTheme,
  ) {
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
                data != null
                    ? 'Hola, ${data.fullName.split(' ').first}!'
                    : 'Hola!',
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
      ],
    );
  }

  Widget _buildEstablishments(
    CitizenHome? data,
    ColorScheme colors,
    TextTheme textTheme,
  ) {
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
      return _emptySection(
        'No hay establecimientos cercanos',
        colors,
        textTheme,
      );
    }

    return _buildHorizontalList(
      itemCount: establishments.length,
      itemBuilder: (i) => EstablishmentCardWidget(
        name: establishments[i].storeName,
        distance: establishments[i].distance,
        rating: establishments[i].averageRating,
        reviewCount: establishments[i].reviewsCount,
        materials: establishments[i].materials,
        isOpen: establishments[i].isOpen,
        isPremium: establishments[i].isPremium,
        photoUrl: establishments[i].photoUrl,
        onTap: () =>
            context.push('/establishmentDetail/${establishments[i].id}'),
      ),
    );
  }

  Widget _buildReceivedOffers(
    CitizenHome? data,
    ColorScheme colors,
    TextTheme textTheme,
  ) {
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
        offeredPrice:
            '\$${offers[i].pricePerUnit.toStringAsFixed(2)}/${offers[i].unit}',
        buyerName: offers[i].establishmentName,
        timeAgo: offers[i].offeredAt,
        status: 'Pendiente',
        onTap: () => context.push('/wasteDetail/${offers[i].publicationId}'),
      ),
    );
  }

  Widget _emptySection(
    String message,
    ColorScheme colors,
    TextTheme textTheme,
  ) {
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
          children:
              [
                ActionCardWidget(
                  title: 'Publicar',
                  subtitle: 'Sube algo que ya no uses',
                  icon: Icons.add_a_photo_outlined,
                  gradientColors: const [Color(0xFF17B593), Color(0xFF5ACA7E)],
                  onTap: () => context.push('/createWaste'),
                ),
                ActionCardWidget(
                  title: 'Ver locales',
                  subtitle: 'Encuentra dónde llevar tu material',
                  icon: Icons.storefront_outlined,
                  gradientColors: const [Color(0xFF59B3E0), Color(0xFF30A3F3)],
                  onTap: () => context.push('/establishments'),
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
