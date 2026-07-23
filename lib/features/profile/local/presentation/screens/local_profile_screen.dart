import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:treasureflow/core/di/app_container.dart';
import 'package:treasureflow/features/profile/local/di/local_profile_module.dart';
import 'package:treasureflow/features/profile/local/domain/entities/establishment_profile.dart';
import 'package:treasureflow/features/profile/local/presentation/providers/local_profile_provider.dart';
import 'package:treasureflow/shared/layouts/app_card_container.dart';
import 'package:treasureflow/shared/utils/material_type_id_catalog.dart';
import 'package:treasureflow/shared/widgets/floating_nav_bar_widget.dart';
import 'package:treasureflow/shared/widgets/primary_button_blue_widget.dart';

const _dayNames = [
  '',
  'Lunes',
  'Martes',
  'Miércoles',
  'Jueves',
  'Viernes',
  'Sábado',
  'Domingo',
];

class LocalProfileScreen extends StatefulWidget {
  const LocalProfileScreen({super.key});

  @override
  State<LocalProfileScreen> createState() => _LocalProfileScreenState();
}

class _LocalProfileScreenState extends State<LocalProfileScreen> {
  late final LocalProfileProvider _provider;

  @override
  void initState() {
    super.initState();
    final container = context.read<AppContainer>();
    _provider = LocalProfileModule(container).provideLocalProfileProvider();
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
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      body: Stack(
        children: [
          Positioned.fill(child: SafeArea(bottom: false, child: _buildBody())),
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 16,
            child: _topIconButton(
              Icons.settings_outlined,
              colors,
              onTap: () => context.push('/settingsLocal'),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: const FloatingNavBarWidget(currentIndex: 3),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_provider.status) {
      case LocalProfileStatus.idle:
      case LocalProfileStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case LocalProfileStatus.error:
        return _errorState();
      case LocalProfileStatus.success:
        final profile = _provider.profile;
        if (profile == null) return _errorState();
        return _content(profile);
    }
  }

  Widget _errorState() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 48, color: colors.error),
            const SizedBox(height: 16),
            Text(
              _provider.errorMessage ?? 'No se pudo cargar tu perfil',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
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

  Widget _content(EstablishmentProfile profile) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBannerAndAvatar(profile, colors),
          const SizedBox(height: 52),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNameSection(profile, colors, textTheme),
                const SizedBox(height: 16),
                _buildStats(profile, colors, textTheme),
                const SizedBox(height: 24),

                _sectionTitle(
                  'Información de contacto',
                  colors,
                  textTheme,
                  icon: Icons.badge_outlined,
                ),
                const SizedBox(height: 10),
                AppCardContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoRow(
                        Icons.mail_outline_rounded,
                        'Correo',
                        profile.email,
                        colors,
                        textTheme,
                      ),
                      _infoRow(
                        Icons.phone_outlined,
                        'Teléfono',
                        profile.phone,
                        colors,
                        textTheme,
                      ),
                      if (profile.addressText != null)
                        _infoRow(
                          Icons.location_on_outlined,
                          'Dirección',
                          profile.addressText!,
                          colors,
                          textTheme,
                        ),
                      _infoRow(
                        Icons.local_shipping_outlined,
                        'Vehículo propio',
                        profile.hasVehicle ? 'Sí' : 'No',
                        colors,
                        textTheme,
                        showDivider: false,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                _sectionTitle(
                  'Materiales que recibe',
                  colors,
                  textTheme,
                  icon: Icons.recycling_rounded,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final id in profile.materialTypeIds)
                      _materialChip(
                        MaterialTypeIdCatalog.nameOf(id),
                        colors,
                        textTheme,
                      ),
                  ],
                ),
                const SizedBox(height: 24),

                _sectionTitle(
                  'Horario laboral',
                  colors,
                  textTheme,
                  icon: Icons.access_time_rounded,
                ),
                const SizedBox(height: 10),
                AppCardContainer(
                  child: Column(
                    children: [
                      for (var i = 0; i < profile.schedules.length; i++)
                        _scheduleRow(
                          profile.schedules[i],
                          colors,
                          textTheme,
                          showDivider: i < profile.schedules.length - 1,
                        ),
                      if (profile.schedules.isEmpty)
                        Text(
                          'Sin horario configurado',
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                    ],
                  ),
                ),

                if (profile.photoUrls.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _sectionTitle(
                    'Fotos del establecimiento',
                    colors,
                    textTheme,
                    icon: Icons.photo_library_outlined,
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 104,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: profile.photoUrls.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 10),
                      itemBuilder: (context, index) =>
                          _photoTile(profile.photoUrls[index], colors),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(
    String text,
    ColorScheme colors,
    TextTheme textTheme, {
    IconData? icon,
  }) {
    if (icon == null) {
      return Text(
        text,
        style: textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      );
    }
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 15, color: colors.primary),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildBannerAndAvatar(
    EstablishmentProfile profile,
    ColorScheme colors,
  ) {
    return SizedBox(
      height: 194,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/auth/banner.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: colors.primary.withValues(alpha: 0.15)),
            ),
          ),
          Positioned(
            left: 16,
            bottom: -44,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: colors.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 40,
                backgroundColor: colors.primary.withValues(alpha: 0.1),
                backgroundImage: profile.profilePictureUrl != null
                    ? NetworkImage(profile.profilePictureUrl!)
                    : null,
                child: profile.profilePictureUrl == null
                    ? Icon(
                        Icons.storefront_rounded,
                        size: 40,
                        color: colors.primary,
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameSection(
    EstablishmentProfile profile,
    ColorScheme colors,
    TextTheme textTheme,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.storeName,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                profile.email,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.storefront_rounded, size: 13, color: colors.primary),
              const SizedBox(width: 4),
              Text(
                'Establecimiento',
                style: textTheme.bodySmall?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStats(
    EstablishmentProfile profile,
    ColorScheme colors,
    TextTheme textTheme,
  ) {
    return Row(
      children: [
        _statChip(
          icon: Icons.recycling_rounded,
          label: 'Materiales',
          value: '${profile.materialTypeIds.length}',
          colors: colors,
          textTheme: textTheme,
        ),
        const SizedBox(width: 8),
        _statChip(
          icon: Icons.calendar_today_rounded,
          label: 'Días activos',
          value: '${profile.schedules.length}',
          colors: colors,
          textTheme: textTheme,
        ),
        const SizedBox(width: 8),
        _statChip(
          icon: Icons.photo_library_rounded,
          label: 'Fotos',
          value: '${profile.photoUrls.length}',
          colors: colors,
          textTheme: textTheme,
        ),
      ],
    );
  }

  Widget _statChip({
    required IconData icon,
    required String label,
    required String value,
    required ColorScheme colors,
    required TextTheme textTheme,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.outline.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: colors.primary),
            const SizedBox(height: 6),
            Text(
              value,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurface.withValues(alpha: 0.5),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topIconButton(
    IconData icon,
    ColorScheme colors, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: colors.surface.withValues(alpha: 0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: colors.onSurface),
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String label,
    String value,
    ColorScheme colors,
    TextTheme textTheme, {
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: colors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(height: 1, color: colors.outline.withValues(alpha: 0.15)),
      ],
    );
  }

  Widget _scheduleRow(
    EstablishmentSchedule schedule,
    ColorScheme colors,
    TextTheme textTheme, {
    required bool showDivider,
  }) {
    final dayLabel = schedule.dayOfWeek >= 1 && schedule.dayOfWeek <= 7
        ? _dayNames[schedule.dayOfWeek]
        : 'Día ${schedule.dayOfWeek}';
    final isToday = schedule.dayOfWeek == DateTime.now().weekday;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 14,
                color: colors.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  dayLabel,
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  '${schedule.startTime} – ${schedule.endTime}',
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.7),
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(height: 1, color: colors.outline.withValues(alpha: 0.15)),
      ],
    );
  }

  Widget _materialChip(String label, ColorScheme colors, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.recycling_rounded, size: 14, color: colors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _photoTile(String url, ColorScheme colors) {
    return Container(
      width: 104,
      height: 104,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          url,
          width: 104,
          height: 104,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Container(
            width: 104,
            height: 104,
            color: colors.primary.withValues(alpha: 0.1),
            child: Icon(Icons.storefront_outlined, color: colors.primary),
          ),
        ),
      ),
    );
  }
}
