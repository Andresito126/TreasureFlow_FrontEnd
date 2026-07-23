import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:treasureflow/features/establishments/presentation/providers/establishments_list_provider.dart';
import 'package:treasureflow/features/home/citizen/presentation/widgets/establishment_card_widget.dart';
import 'package:treasureflow/shared/widgets/floating_nav_bar_widget.dart';

class EstablishmentsListScreen extends StatefulWidget {
  const EstablishmentsListScreen({super.key});

  @override
  State<EstablishmentsListScreen> createState() =>
      _EstablishmentsListScreenState();
}

class _EstablishmentsListScreenState extends State<EstablishmentsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EstablishmentsListProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;
    final provider = context.watch<EstablishmentsListProvider>();

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    children: [
                      BackButton(color: colors.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Establecimientos',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(child: _buildBody(provider, colors, textTheme)),
              ],
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: FloatingNavBarWidget(currentIndex: 1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    EstablishmentsListProvider provider,
    ColorScheme colors,
    TextTheme textTheme,
  ) {
    if (provider.status == EstablishmentsListStatus.loading ||
        provider.status == EstablishmentsListStatus.idle) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.status == EstablishmentsListStatus.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            provider.errorMessage ??
                'No se pudieron cargar los establecimientos',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium,
          ),
        ),
      );
    }

    if (provider.items.isEmpty) {
      return Center(
        child: Text(
          'No hay establecimientos disponibles',
          style: textTheme.bodyMedium?.copyWith(
            color: colors.onSurface.withValues(alpha: 0.6),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: provider.load,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.pixels >=
              notification.metrics.maxScrollExtent - 200) {
            provider.loadMore();
          }
          return false;
        },
        child: GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          physics: const AlwaysScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.72,
          ),
          itemCount: provider.items.length + (provider.isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= provider.items.length) {
              return const Center(child: CircularProgressIndicator());
            }
            final item = provider.items[index];
            return EstablishmentCardWidget(
              name: item.storeName,
              distance: item.distance ?? '',
              rating: item.averageRating,
              reviewCount: 0,
              materials: item.materials,
              isOpen: item.isOpen,
              photoUrl: item.photoUrl,
              onTap: () => context.push('/establishmentDetail/${item.id}'),
            );
          },
        ),
      ),
    );
  }
}
