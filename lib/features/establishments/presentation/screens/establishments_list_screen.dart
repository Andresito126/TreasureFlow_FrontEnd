import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:treasureflow/features/establishments/presentation/providers/establishments_list_provider.dart';
import 'package:treasureflow/features/home/citizen/presentation/widgets/establishment_card_widget.dart';
import 'package:treasureflow/shared/utils/material_type_id_catalog.dart';
import 'package:treasureflow/shared/widgets/floating_nav_bar_widget.dart';

class EstablishmentsListScreen extends StatefulWidget {
  const EstablishmentsListScreen({super.key});

  @override
  State<EstablishmentsListScreen> createState() =>
      _EstablishmentsListScreenState();
}

class _EstablishmentsListScreenState extends State<EstablishmentsListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<EstablishmentsListProvider>();
      provider.resetSearch();
      _searchController.clear();
      provider.load();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: _buildSearchField(provider, colors, textTheme),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: _buildScopeToggle(provider, colors, textTheme),
                ),
                const SizedBox(height: 10),
                _buildMaterialFilterChips(provider, colors, textTheme),
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

  Widget _buildSearchField(
    EstablishmentsListProvider provider,
    ColorScheme colors,
    TextTheme textTheme,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outline.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: provider.setSearchQuery,
        style: textTheme.bodyMedium,
        decoration: InputDecoration(
          hintText: 'Buscar establecimiento por nombre...',
          hintStyle: textTheme.bodyMedium?.copyWith(
            color: colors.onSurface.withValues(alpha: 0.4),
          ),
          prefixIcon: Icon(Icons.search_rounded, color: colors.primary),
          suffixIcon: provider.searchQuery.isEmpty
              ? null
              : IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: colors.onSurface.withValues(alpha: 0.5),
                  ),
                  onPressed: () {
                    _searchController.clear();
                    provider.setSearchQuery('');
                  },
                ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildScopeToggle(
    EstablishmentsListProvider provider,
    ColorScheme colors,
    TextTheme textTheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.outline.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildScopeOption(
              label: 'Ver todos',
              icon: Icons.grid_view_rounded,
              selected: !provider.nearbyOnly,
              colors: colors,
              textTheme: textTheme,
              onTap: () => provider.setNearbyOnly(false),
            ),
          ),
          Expanded(
            child: _buildScopeOption(
              label: 'Cerca de mí',
              icon: Icons.near_me_rounded,
              selected: provider.nearbyOnly,
              colors: colors,
              textTheme: textTheme,
              onTap: () => provider.setNearbyOnly(true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScopeOption({
    required String label,
    required IconData icon,
    required bool selected,
    required ColorScheme colors,
    required TextTheme textTheme,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 17,
              color: selected ? colors.onPrimary : colors.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: selected ? colors.onPrimary : colors.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialFilterChips(
    EstablishmentsListProvider provider,
    ColorScheme colors,
    TextTheme textTheme,
  ) {
    final materials = MaterialTypeIdCatalog.all;

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        children: [
          _buildFilterChip(
            label: 'Todos',
            selected: provider.materialTypeId == null,
            colors: colors,
            textTheme: textTheme,
            onTap: () => provider.filterByMaterial(null),
          ),
          ...materials.entries.map(
            (entry) => _buildFilterChip(
              label: entry.value,
              selected: provider.materialTypeId == entry.key,
              colors: colors,
              textTheme: textTheme,
              onTap: () => provider.filterByMaterial(entry.key),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required ColorScheme colors,
    required TextTheme textTheme,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? colors.primary : colors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? colors.primary
                  : colors.outline.withValues(alpha: 0.35),
            ),
          ),
          child: Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: selected ? colors.onPrimary : colors.onSurface.withValues(alpha: 0.7),
            ),
          ),
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
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.storefront_outlined,
                size: 40,
                color: colors.onSurface.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 12),
              Text(
                provider.searchQuery.isNotEmpty
                    ? 'No encontramos establecimientos con ese nombre'
                    : provider.nearbyOnly
                        ? 'No hay establecimientos cerca de ti'
                        : 'No hay establecimientos disponibles',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
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
              reviewCount: item.reviewsCount,
              materials: item.materials,
              isOpen: item.isOpen,
              isPremium: item.isPremium,
              photoUrl: item.photoUrl,
              onTap: () => context.push('/establishmentDetail/${item.id}'),
            );
          },
        ),
      ),
    );
  }
}
