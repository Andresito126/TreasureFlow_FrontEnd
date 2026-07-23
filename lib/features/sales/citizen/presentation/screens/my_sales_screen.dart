import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:treasureflow/core/di/app_container.dart';
import 'package:treasureflow/features/collections/citizen/di/citizen_collections_module.dart';
import 'package:treasureflow/features/collections/citizen/presentation/providers/citizen_collections_list_provider.dart';
import 'package:treasureflow/features/collections/shared/widgets/collection_card_widget.dart';
import 'package:treasureflow/shared/widgets/floating_nav_bar_widget.dart';
import 'package:treasureflow/shared/widgets/primary_button_blue_widget.dart';
import 'package:treasureflow/shared/widgets/screen_header_widget.dart';

class MySalesScreen extends StatefulWidget {
  const MySalesScreen({super.key});

  @override
  State<MySalesScreen> createState() => _MySalesScreenState();
}

class _MySalesScreenState extends State<MySalesScreen> {
  late final CitizenCollectionsListProvider _provider;
  bool _showHistory = false;

  @override
  void initState() {
    super.initState();
    final container = context.read<AppContainer>();
    _provider = CitizenCollectionsModule(container).provideListProvider();
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
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const ScreenHeaderWidget(
          titlePrefix: 'Mis ',
          titleHighlight: 'ventas',
        ),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: _buildScopeToggle(colors, textTheme),
              ),
              Expanded(child: _buildBody(colors, textTheme)),
            ],
          ),
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: FloatingNavBarWidget(currentIndex: 2),
          ),
        ],
      ),
    );
  }

  Widget _buildScopeToggle(ColorScheme colors, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _scopeOption(
              label: 'En curso',
              icon: Icons.autorenew_rounded,
              selected: !_showHistory,
              colors: colors,
              textTheme: textTheme,
              onTap: () => setState(() => _showHistory = false),
            ),
          ),
          Expanded(
            child: _scopeOption(
              label: 'Historial',
              icon: Icons.history_rounded,
              selected: _showHistory,
              colors: colors,
              textTheme: textTheme,
              onTap: () => setState(() => _showHistory = true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _scopeOption({
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
              size: 16,
              color: selected ? colors.onPrimary : colors.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: selected ? colors.onPrimary : colors.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(ColorScheme colors, TextTheme textTheme) {
    switch (_provider.status) {
      case CitizenListStatus.idle:
      case CitizenListStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case CitizenListStatus.error:
        return _errorState(colors, textTheme);
      case CitizenListStatus.success:
        final items = _showHistory
            ? _provider.allItems
                .where((i) => !i.collection.status.isActive)
                .toList()
            : _provider.activeItems;
        if (items.isEmpty) return _emptyState(colors, textTheme);

        return RefreshIndicator(
          onRefresh: _provider.load,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
            itemCount: items.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _showHistory
                        ? 'Recolecciones completadas o canceladas.'
                        : 'Continúa el proceso de entrega y pago de tus materiales.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                );
              }
              final item = items[index - 1];
              final collection = item.collection;
              final offer = item.offer;
              return CollectionCardWidget(
                title: offer?.wastePublicationTitle ?? 'Residuo',
                subtitle: offer?.establishmentName ?? 'Establecimiento',
                photoUrl: offer?.wastePublicationPhotoUrl,
                statusRaw: collection.statusRaw,
                step: collection.status.stepNumber,
                amountLabel: collection.finalAmount != null
                    ? '\$${collection.finalAmount!.toStringAsFixed(2)}'
                    : offer != null
                        ? '\$${offer.pricePerUnit.toStringAsFixed(2)}/${offer.unit}'
                        : '—',
                onTap: () async {
                  await context
                      .push('/saleDetail/${collection.collectionId}');
                  _provider.load();
                },
              );
            },
          ),
        );
    }
  }

  Widget _errorState(ColorScheme colors, TextTheme textTheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 48, color: colors.error),
            const SizedBox(height: 16),
            Text(
              _provider.errorMessage ?? 'No se pudieron cargar tus ventas',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            PrimaryButtonBlueWidget(
              text: 'Reintentar',
              onPressed: _provider.load,
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(ColorScheme colors, TextTheme textTheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.primary.withValues(alpha: 0.1),
              ),
              child: Icon(
                _showHistory ? Icons.history_rounded : Icons.sell_outlined,
                size: 40,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _showHistory
                  ? 'Aún no tienes ventas en tu historial'
                  : 'No tienes ventas en curso',
              textAlign: TextAlign.center,
              style:
                  textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _showHistory
                  ? 'Aquí aparecerán tus ventas completadas o canceladas.'
                  : 'Cuando aceptes una oferta en alguna de tus publicaciones, aquí verás el avance de la venta.',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
