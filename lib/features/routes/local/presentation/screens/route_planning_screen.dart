import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:treasureflow/core/di/app_container.dart';
import 'package:treasureflow/features/routes/local/di/routes_module.dart';
import 'package:treasureflow/features/routes/local/domain/entities/weekly_planning_day.dart';
import 'package:treasureflow/features/routes/local/presentation/providers/weekly_planning_provider.dart';
import 'package:treasureflow/shared/layouts/app_card_container.dart';
import 'package:treasureflow/shared/widgets/primary_button_blue_widget.dart';
import 'package:treasureflow/shared/widgets/screen_header_widget.dart';

class RoutePlanningScreen extends StatefulWidget {
  const RoutePlanningScreen({super.key});

  @override
  State<RoutePlanningScreen> createState() => _RoutePlanningScreenState();
}

class _RoutePlanningScreenState extends State<RoutePlanningScreen> {
  late final WeeklyPlanningProvider _provider;

  @override
  void initState() {
    super.initState();
    final container = context.read<AppContainer>();
    _provider = RoutesModule(container).provideWeeklyPlanningProvider();
    _provider.addListener(_onProviderChanged);
    _provider.loadFromToday();
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
        title: const ScreenHeaderWidget(
          titlePrefix: 'Planificar ',
          titleHighlight: 'rutas',
        ),
      ),
      body: SafeArea(child: _buildBody(colors, textTheme)),
    );
  }

  Widget _buildBody(ColorScheme colors, TextTheme textTheme) {
    switch (_provider.status) {
      case WeeklyPlanningStatus.idle:
      case WeeklyPlanningStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case WeeklyPlanningStatus.error:
        return _errorState(colors, textTheme);
      case WeeklyPlanningStatus.success:
        return Column(
          children: [
            _weekNavigator(colors, textTheme),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: _provider.days.length,
                itemBuilder: (context, index) =>
                    _dayCard(_provider.days[index], colors, textTheme),
              ),
            ),
          ],
        );
    }
  }

  Widget _weekNavigator(ColorScheme colors, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: _provider.canGoPrevious ? _provider.previousWeek : null,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Expanded(
            child: Text(
              'Semana de recolecciones confirmadas',
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          IconButton(
            onPressed: _provider.nextWeek,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }

  Widget _dayCard(
    WeeklyPlanningDay day,
    ColorScheme colors,
    TextTheme textTheme,
  ) {
    final hasPickups = day.pickupCount > 0;

    return Opacity(
      opacity: hasPickups ? 1 : 0.5,
      child: GestureDetector(
        onTap: hasPickups
            ? () => context.push('/routeDetail/${day.date}')
            : null,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AppCardContainer(
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: hasPickups
                        ? colors.primary.withValues(alpha: 0.1)
                        : colors.outline.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.local_shipping_outlined,
                    color: hasPickups
                        ? colors.primary
                        : colors.onSurface.withValues(alpha: 0.4),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        day.dayLabel,
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        day.date,
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.onSurface.withValues(alpha: 0.55),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: hasPickups
                        ? colors.primary.withValues(alpha: 0.12)
                        : colors.outline.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    hasPickups
                        ? '${day.pickupCount} ${day.pickupCount == 1 ? 'recolección' : 'recolecciones'}'
                        : 'Sin recolecciones',
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: hasPickups
                          ? colors.primary
                          : colors.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                if (hasPickups) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: colors.onSurface.withValues(alpha: 0.4),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
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
              _provider.errorMessage ?? 'No se pudo cargar la planeación',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            PrimaryButtonBlueWidget(
              text: 'Reintentar',
              onPressed: _provider.loadFromToday,
            ),
          ],
        ),
      ),
    );
  }
}
