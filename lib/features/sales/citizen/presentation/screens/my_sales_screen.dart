import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:treasureflow/features/sales/citizen/presentation/models/sale_ui_model.dart';
import 'package:treasureflow/features/sales/citizen/presentation/ui_states/sale_status.dart';
import 'package:treasureflow/features/sales/citizen/presentation/widgets/sale_card_widget.dart';
import 'package:treasureflow/shared/widgets/floating_nav_bar_widget.dart';
import 'package:treasureflow/shared/widgets/screen_header_widget.dart';

class MySalesScreen extends StatelessWidget {
  const MySalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    final inProgress = mockSales
        .where((s) => s.status != SaleStatus.completed)
        .toList();

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
          inProgress.isEmpty
              ? _emptyState(colors, textTheme)
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
                  itemCount: inProgress.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          'Continúa el proceso de entrega y pago de tus materiales.',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colors.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      );
                    }
                    final sale = inProgress[index - 1];
                    return SaleCardWidget(
                      sale: sale,
                      onTap: () => context.push('/saleDetail/${sale.id}'),
                    );
                  },
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
              child: Icon(Icons.sell_outlined, size: 40, color: colors.primary),
            ),
            const SizedBox(height: 20),
            Text(
              'No tienes ventas en curso',
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Cuando aceptes una oferta en alguna de tus publicaciones, aquí verás el avance de la venta.',
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
