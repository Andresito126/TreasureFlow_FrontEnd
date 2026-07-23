import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:treasureflow/core/di/app_container.dart';
import 'package:treasureflow/features/reviews/di/reviews_module.dart';
import 'package:treasureflow/features/reviews/presentation/providers/establishment_reviews_provider.dart';
import 'package:treasureflow/features/reviews/presentation/widgets/review_item_widget.dart';
import 'package:treasureflow/features/home/local/domain/entities/local_home_summary.dart';
import 'package:treasureflow/features/home/local/domain/entities/local_home_feed_item.dart';
import 'package:treasureflow/features/home/local/presentation/providers/local_home_summary_provider.dart';
import 'package:treasureflow/features/home/local/presentation/providers/local_home_feed_provider.dart';
import 'package:treasureflow/features/home/local/presentation/widgets/accepted_offer_card_widget.dart';
import 'package:treasureflow/features/home/local/presentation/widgets/local_action_card_widget.dart';
import 'package:treasureflow/features/home/local/presentation/widgets/solicitud_card_widget.dart';
import 'package:treasureflow/features/home/citizen/presentation/widgets/stat_card_widget.dart';
import 'package:treasureflow/features/home/shared/widgets/premium_banner_widget.dart';
import 'package:treasureflow/shared/theme/app_theme_extension.dart';
import 'package:treasureflow/shared/widgets/floating_nav_bar_widget.dart';
import 'package:treasureflow/shared/widgets/premium_badge_widget.dart';

class HomeLocalScreen extends StatefulWidget {
  const HomeLocalScreen({super.key});

  @override
  State<HomeLocalScreen> createState() => _HomeLocalScreenState();
}

class _HomeLocalScreenState extends State<HomeLocalScreen> {
  late final EstablishmentReviewsProvider _reviewsProvider;

  @override
  void initState() {
    super.initState();
    final container = context.read<AppContainer>();
    _reviewsProvider = ReviewsModule(container).provideReviewsProvider();
    _reviewsProvider.addListener(_onReviewsChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocalHomeFeedProvider>().load();
      context.read<LocalHomeSummaryProvider>().load();
      _reviewsProvider.load();
    });
  }

  @override
  void dispose() {
    _reviewsProvider.removeListener(_onReviewsChanged);
    _reviewsProvider.dispose();
    super.dispose();
  }

  void _onReviewsChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;
    final feed = context.watch<LocalHomeFeedProvider>();
    final home = context.watch<LocalHomeSummaryProvider>();

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(home.data, colors, textTheme),
                  const SizedBox(height: 20),

                  if (!(home.data?.isPremium ?? false)) ...[
                    PremiumBannerWidget(
                      onTap: () => context.push('/premiumLocal'),
                    ),
                    const SizedBox(height: 20),
                  ],

                  _buildStats(home, colors, textTheme),
                  const SizedBox(height: 24),

                  _buildActionOptions(colors),
                  const SizedBox(height: 24),

                  _buildSectionHeader(
                    'Solicitudes nuevas',
                    '${feed.total}',
                    colors,
                    textTheme,
                  ),
                  const SizedBox(height: 12),
                  _buildFeedSection(feed, colors, textTheme),
                  const SizedBox(height: 24),

                  _buildSectionHeader(
                    'Ofertas pendientes',
                    '${home.data?.pendingOffersCount ?? 0}',
                    colors,
                    textTheme,
                  ),
                  const SizedBox(height: 12),
                  _buildPendingOffersSection(home, colors, textTheme),
                  const SizedBox(height: 24),

                  _buildSectionHeader(
                    'Nuevas reseñas',
                    '${_reviewsProvider.total}',
                    colors,
                    textTheme,
                  ),
                  const SizedBox(height: 12),
                  _buildReviewsSection(colors, textTheme),
                ],
              ),
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

  Widget _buildFeedSection(
    LocalHomeFeedProvider feed,
    ColorScheme colors,
    TextTheme textTheme,
  ) {
    if (feed.status == LocalHomeFeedStatus.loading ||
        feed.status == LocalHomeFeedStatus.idle) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (feed.status == LocalHomeFeedStatus.error) {
      return Text(
        feed.errorMessage ?? 'No se pudo cargar el feed',
        style: textTheme.bodySmall?.copyWith(color: colors.error),
      );
    }

    if (feed.items.isEmpty) {
      return Text(
        'No hay solicitudes nuevas cerca de ti',
        style: textTheme.bodySmall?.copyWith(
          color: colors.onSurface.withValues(alpha: 0.6),
        ),
      );
    }

    return Column(
      children: [
        for (final item in feed.items) ...[
          _solicitudCard(item, colors, textTheme),
          if (item != feed.items.last) const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _solicitudCard(
    LocalHomeFeedItem item,
    ColorScheme colors,
    TextTheme textTheme,
  ) {
    return SolicitudCardWidget(
      title: item.materialTypeName,
      date: item.publishedAt,
      distanceLabel: '${item.distanceMeters} m',
      publisherName: item.citizenName,
    citizenIsPremium: item.citizenIsPremium,
      address: item.description ?? 'Sin descripción',
      status: item.isFeatured ? 'Destacada' : 'Nueva',
      actionLabel: 'Ofertar residuos',
      onTap: () => context.push('/wasteDetailLocal/${item.id}'),
      onAction: () => context.push('/wasteDetailLocal/${item.id}'),
    );
  }

  Widget _buildPendingOffersSection(
    LocalHomeSummaryProvider home,
    ColorScheme colors,
    TextTheme textTheme,
  ) {
    if (home.status == LocalHomeSummaryStatus.loading ||
        home.status == LocalHomeSummaryStatus.idle) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (home.status == LocalHomeSummaryStatus.error) {
      return Text(
        home.errorMessage ?? 'No se pudieron cargar tus ofertas',
        style: textTheme.bodySmall?.copyWith(color: colors.error),
      );
    }

    final offers = home.data?.pendingOffers ?? [];
    if (offers.isEmpty) {
      return _emptySection('No tienes ofertas pendientes', colors, textTheme);
    }

    final blueHold = Theme.of(context).extension<AppThemeExtension>()!.blueHold;

    return Column(
      children: [
        for (final offer in offers) ...[
          AcceptedOfferCardWidget(
            title: offer.publicationMaterial,
            price: '\$${offer.pricePerUnit.toStringAsFixed(2)}/${offer.unit}',
            date: offer.offeredAt,
            address: offer.citizenName,
            statusLabel: 'Pendiente',
            statusColor: blueHold,
            onTap: () =>
                context.push('/wasteDetailLocal/${offer.publicationId}'),
          ),
          if (offer != offers.last) const SizedBox(height: 12),
        ],
      ],
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

  Widget _buildReviewsSection(ColorScheme colors, TextTheme textTheme) {
    if (_reviewsProvider.status == ReviewsListStatus.loading ||
        _reviewsProvider.status == ReviewsListStatus.idle) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_reviewsProvider.items.isEmpty) {
      return _emptySection('Aún no tienes reseñas', colors, textTheme);
    }

    return Column(
      children: _reviewsProvider.items
          .take(3)
          .map((review) => ReviewItemWidget(review: review))
          .toList(),
    );
  }

  Widget _buildHeader(
    LocalHomeSummary? data,
    ColorScheme colors,
    TextTheme textTheme,
  ) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  data != null
                      ? '¡Bienvenido ${data.storeName}!'
                      : '¡Bienvenido!',
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              if (data?.isPremium ?? false) ...[
                const SizedBox(width: 6),
                const PremiumBadgeWidget(),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStats(
    LocalHomeSummaryProvider home,
    ColorScheme colors,
    TextTheme textTheme,
  ) {
    final data = home.data;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: StatCardWidget(
              icon: Icons.account_balance_wallet_outlined,
              value: data != null
                  ? '\$${data.monthlySpend.toStringAsFixed(2)}'
                  : '—',
              title: 'Gasto del mes',
              subtitle: 'En recolecciones',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatCardWidget(
              icon: Icons.local_shipping_outlined,
              value: data != null ? '${data.monthlyCompletedPickups}' : '—',
              title: 'Recolecciones',
              subtitle: 'Completadas este mes',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionOptions(ColorScheme colors) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            child: LocalActionCardWidget(
              title: 'Ofertar residuos',
              subtitle: 'Ofrecer monto por residuos',
              icon: Icons.attach_money,
              gradientColors: const [Color(0xFF2D7D46), Color(0xFF4CAF50)],
              onTap: () => context.push('/feed'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: LocalActionCardWidget(
              title: 'Atender solicitudes',
              subtitle: 'Revisar solicitudes para recolección',
              icon: Icons.assignment_outlined,
              gradientColors: const [Color(0xFFF5A623), Color(0xFFFEC562)],
              onTap: () => context.push('/myPurchases'),
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
