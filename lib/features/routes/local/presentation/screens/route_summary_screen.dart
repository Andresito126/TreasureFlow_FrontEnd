import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:treasureflow/core/di/app_container.dart';
import 'package:treasureflow/features/routes/local/di/routes_module.dart';
import 'package:treasureflow/features/routes/local/domain/entities/route_status.dart';
import 'package:treasureflow/features/routes/local/domain/entities/route_summary.dart';
import 'package:treasureflow/features/routes/local/presentation/providers/route_summary_provider.dart';
import 'package:treasureflow/features/routes/local/presentation/widgets/route_summary_stat_card_widget.dart';
import 'package:treasureflow/shared/layouts/app_card_container.dart';
import 'package:treasureflow/shared/widgets/primary_button_blue_widget.dart';

class RouteSummaryScreen extends StatefulWidget {
  final Object? extra;

  const RouteSummaryScreen({super.key, this.extra});

  @override
  State<RouteSummaryScreen> createState() => _RouteSummaryScreenState();
}

class _RouteSummaryScreenState extends State<RouteSummaryScreen> {
  late final RouteSummaryProvider _provider;
  String? _routeId;

  @override
  void initState() {
    super.initState();
    _routeId = _extractRouteId(widget.extra);
    final container = context.read<AppContainer>();
    _provider = RoutesModule(container).provideRouteSummaryProvider();
    _provider.addListener(_onChanged);
    final id = _routeId;
    if (id != null) _provider.load(id);
  }

  @override
  void dispose() {
    _provider.removeListener(_onChanged);
    _provider.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  String? _extractRouteId(Object? extra) {
    if (extra is Map && extra['routeId'] != null) {
      return extra['routeId'].toString();
    }

    try {
      final metadata = (extra as dynamic).metadata;
      if (metadata is Map && metadata['routeId'] != null) {
        return metadata['routeId'].toString();
      }
    } catch (_) {}
    return null;
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
        title: const Text('Resumen de ruta'),
      ),
      body: SafeArea(child: _buildBody(colors, textTheme)),
    );
  }

  Widget _buildBody(ColorScheme colors, TextTheme textTheme) {
    if (_routeId == null) {
      return _message(
        colors,
        textTheme,
        Icons.error_outline_rounded,
        'No se pudo identificar la ruta a resumir.',
      );
    }

    switch (_provider.status) {
      case RouteSummaryStatus.idle:
      case RouteSummaryStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case RouteSummaryStatus.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: colors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  _provider.errorMessage ?? 'No se pudo cargar el resumen',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                PrimaryButtonBlueWidget(
                  text: 'Reintentar',
                  onPressed: () => _provider.load(_routeId!),
                ),
              ],
            ),
          ),
        );
      case RouteSummaryStatus.success:
        final summary = _provider.summary;
        if (summary == null) {
          return _message(
            colors,
            textTheme,
            Icons.inbox_outlined,
            'No hay datos del resumen.',
          );
        }
        return _summaryView(summary, colors, textTheme);
    }
  }

  Widget _summaryView(
    RouteSummary summary,
    ColorScheme colors,
    TextTheme textTheme,
  ) {
    final km = (summary.totalDistanceMeters / 1000).toStringAsFixed(1);
    final abandoned = summary.status == RouteExecutionStatus.abandoned;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppCardContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      abandoned
                          ? Icons.warning_amber_rounded
                          : Icons.flag_rounded,
                      size: 20,
                      color: abandoned ? colors.tertiary : colors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        abandoned
                            ? 'Recorrido cerrado automáticamente'
                            : 'Recorrido finalizado',
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  abandoned
                      ? 'No hubo señal del conductor por un tiempo prolongado. Distancia recorrida hasta el cierre: $km km.'
                      : 'Distancia total recorrida: $km km',
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: RouteSummaryStatCardWidget(
                  icon: Icons.list_alt_rounded,
                  label: 'Paradas',
                  value: summary.totalStops,
                  accent: colors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: RouteSummaryStatCardWidget(
                  icon: Icons.check_circle_outline_rounded,
                  label: 'Completadas',
                  value: summary.completedStops,
                  accent: colors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: RouteSummaryStatCardWidget(
                  icon: Icons.schedule_rounded,
                  label: 'Pospuestas',
                  value: summary.postponedStops,
                  accent: colors.tertiary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: RouteSummaryStatCardWidget(
                  icon: Icons.cancel_outlined,
                  label: 'Canceladas',
                  value: summary.cancelledStops,
                  accent: colors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _message(
    ColorScheme colors,
    TextTheme textTheme,
    IconData icon,
    String text,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: colors.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              text,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
