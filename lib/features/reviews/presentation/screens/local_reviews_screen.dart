import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:treasureflow/core/di/app_container.dart';
import 'package:treasureflow/features/reviews/di/reviews_module.dart';
import 'package:treasureflow/features/reviews/presentation/providers/establishment_reviews_provider.dart';
import 'package:treasureflow/features/reviews/presentation/widgets/review_item_widget.dart';

/// Lista de las reseñas propias del establecimiento (GET /reviews/me).
class LocalReviewsScreen extends StatefulWidget {
  const LocalReviewsScreen({super.key});

  @override
  State<LocalReviewsScreen> createState() => _LocalReviewsScreenState();
}

class _LocalReviewsScreenState extends State<LocalReviewsScreen> {
  late final EstablishmentReviewsProvider _provider;

  @override
  void initState() {
    super.initState();
    final container = context.read<AppContainer>();
    _provider = ReviewsModule(container).provideReviewsProvider();
    _provider.addListener(_onProviderChanged);
    _provider.load();
  }

  @override
  void dispose() {
    _provider.removeListener(_onProviderChanged);
    _provider.dispose();
    super.dispose();
  }

  void _onProviderChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  BackButton(color: colors.primary),
                  const SizedBox(width: 4),
                  Text(
                    'Mis reseñas',
                    style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Expanded(child: _buildBody(colors, textTheme)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(ColorScheme colors, TextTheme textTheme) {
    if (_provider.status == ReviewsListStatus.loading ||
        _provider.status == ReviewsListStatus.idle) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_provider.status == ReviewsListStatus.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _provider.errorMessage ?? 'No se pudieron cargar tus reseñas',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium,
          ),
        ),
      );
    }

    if (_provider.items.isEmpty) {
      return Center(
        child: Text(
          'Aún no tienes reseñas',
          style: textTheme.bodyMedium?.copyWith(
            color: colors.onSurface.withValues(alpha: 0.6),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _provider.load,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.pixels >=
              notification.metrics.maxScrollExtent - 200) {
            _provider.loadMore();
          }
          return false;
        },
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: _provider.items.length + (_provider.isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= _provider.items.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return ReviewItemWidget(review: _provider.items[index]);
          },
        ),
      ),
    );
  }
}
