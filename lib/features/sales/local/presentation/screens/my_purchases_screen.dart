import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:treasureflow/features/sales/local/presentation/models/purchase_ui_model.dart';
import 'package:treasureflow/features/sales/local/presentation/ui_states/purchase_status.dart';
import 'package:treasureflow/features/sales/local/presentation/widgets/purchase_card_widget.dart';
import 'package:treasureflow/shared/widgets/app_toast.dart';
import 'package:treasureflow/shared/widgets/floating_nav_bar_widget.dart';
import 'package:treasureflow/shared/widgets/primary_button_green_widget.dart';
import 'package:treasureflow/shared/widgets/screen_header_widget.dart';

// compras apartadas del establecimiento
//  los locales con vehículo pueden generar la ruta de recolección de hoy solo elllos 
//  reprogramar entregas a otra fecha (el ciudadano deberá aceptar).

class MyPurchasesScreen extends StatefulWidget {
  const MyPurchasesScreen({super.key});

  @override
  State<MyPurchasesScreen> createState() => _MyPurchasesScreenState();
}

class _MyPurchasesScreenState extends State<MyPurchasesScreen> {
  late List<PurchaseUiModel> _purchases;

  static const _availableDates = [
    ('Hoy', true),
    ('Sáb 12 jul', false),
    ('Dom 13 jul', false),
    ('Lun 14 jul', false),
  ];

  @override
  void initState() {
    super.initState();
    _purchases = mockPurchases
        .where((p) => p.status != PurchaseStatus.completed)
        .toList();
  }

  Future<void> _onMoveDate(PurchaseUiModel purchase) async {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final selected = await showDialog<(String, bool)>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Mover entrega',
          style:
              theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Elige la nueva fecha. Se notificará al ciudadano y deberá aceptar el cambio.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 12),
            for (final date in _availableDates)
              if (date.$1 != purchase.dateLabel)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  leading: Icon(
                    date.$2
                        ? Icons.today_rounded
                        : Icons.calendar_month_outlined,
                    size: 20,
                    color: colors.primary,
                  ),
                  title: Text(date.$1, style: theme.textTheme.bodyMedium),
                  onTap: () => Navigator.of(context).pop(date),
                ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );

    if (selected == null || !mounted) return;

    setState(() {
      final index = _purchases.indexWhere((p) => p.id == purchase.id);
      if (index != -1) {
        _purchases[index] = _purchases[index].copyWith(
          dateLabel: selected.$1,
          isToday: selected.$2,
        );
      }
    });

    AppToast.show(
      context,
      'Se notificará al ciudadano para que acepte el cambio',
      type: ToastType.info,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Agrupar por fecha respetando el orden del catálogo de fechas
    final grouped = <String, List<PurchaseUiModel>>{};
    for (final date in _availableDates) {
      final items = _purchases.where((p) => p.dateLabel == date.$1).toList();
      if (items.isNotEmpty) grouped[date.$1] = items;
    }

    final hasTodayPurchases =
        _purchases.any((p) => p.isToday && p.status != PurchaseStatus.completed);
    final showRouteButton = mockLocalHasVehicle && hasTodayPurchases;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const ScreenHeaderWidget(
          titlePrefix: 'Mis ',
          titleHighlight: 'compras',
        ),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          _purchases.isEmpty
              ? _emptyState(colors, textTheme)
              : SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    8,
                    16,
                    showRouteButton ? 180 : 110,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Materiales con oferta aceptada, listos para recolectar.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colors.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 20),
                      for (final entry in grouped.entries) ...[
                        _dateHeader(
                          context,
                          label: entry.key,
                          isToday: entry.value.first.isToday,
                          count: entry.value.length,
                        ),
                        const SizedBox(height: 10),
                        for (final purchase in entry.value)
                          PurchaseCardWidget(
                            purchase: purchase,
                            onTap: () => context
                                .push('/purchaseDetail/${purchase.id}'),
                            onMoveDate: mockLocalHasVehicle
                                ? () => _onMoveDate(purchase)
                                : null,
                          ),
                        const SizedBox(height: 14),
                      ],
                    ],
                  ),
                ),

          // Botón principal de ruta — solo locales con vehículo
          if (showRouteButton)
            Positioned(
              left: 16,
              right: 16,
              bottom: 100,
              child: PrimaryButtonGreenWidget(
                text: 'Generar ruta de hoy',
                onPressed: () => context.push('/collectionRoute'),
              ),
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

  Widget _dateHeader(
    BuildContext context, {
    required String label,
    required bool isToday,
    required int count,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Row(
      children: [
        Icon(
          isToday ? Icons.today_rounded : Icons.calendar_month_outlined,
          size: 18,
          color: colors.primary,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            '$label · $count ${count == 1 ? 'recolección' : 'recolecciones'}',
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ],
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
                Icons.local_shipping_outlined,
                size: 40,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No tienes compras en curso',
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Cuando un ciudadano acepte una de tus ofertas, aquí verás la recolección pendiente.',
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
