import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:treasureflow/core/di/app_container.dart';
import 'package:treasureflow/features/home/shared/widgets/premium_banner_widget.dart';
import 'package:treasureflow/features/profile/local/di/local_profile_module.dart';
import 'package:treasureflow/features/profile/local/presentation/providers/local_profile_provider.dart';
import 'package:treasureflow/features/profile/shared/widgets/settings_group_card_widget.dart';
import 'package:treasureflow/features/profile/shared/widgets/settings_logout_tile_widget.dart';
import 'package:treasureflow/features/profile/shared/widgets/settings_profile_card_widget.dart';
import 'package:treasureflow/features/profile/shared/widgets/settings_section_label_widget.dart';
import 'package:treasureflow/features/profile/shared/widgets/settings_tile_widget.dart';

class SettingsScreenLocal extends StatefulWidget {
  const SettingsScreenLocal({super.key});

  @override
  State<SettingsScreenLocal> createState() => _SettingsScreenLocalState();
}

class _SettingsScreenLocalState extends State<SettingsScreenLocal> {
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;
    final profile = _provider.profile;

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  BackButton(color: colors.primary),
                  const SizedBox(width: 4),
                  Text(
                    'Ajustes',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              SettingsProfileCardWidget(
                name: profile?.storeName ?? 'Mi establecimiento',
                email: profile?.email ?? '',
                avatarUrl: profile?.profilePictureUrl,
                fallbackIcon: Icons.storefront_rounded,
                onTap: () => context.push('/editEstablishmentProfile'),
              ),
              const SizedBox(height: 24),

              const SettingsSectionLabel('GENERAL'),
              const SizedBox(height: 8),
              SettingsGroupCard(
                children: [
                  SettingsTileWidget(
                    icon: Icons.storefront_outlined,
                    title: 'Editar información del establecimiento',
                    subtitle:
                        'Actualiza nombre, contacto, dirección y materiales.',
                    onTap: () => context.push('/editEstablishmentProfile'),
                  ),
                  SettingsTileWidget(
                    icon: Icons.photo_outlined,
                    title: 'Adjuntar fotos',
                    subtitle: 'Muestra tu local con fotos del lugar.',
                    onTap: () {},
                  ),
                  SettingsTileWidget(
                    icon: Icons.star_outline,
                    title: 'Ver reseñas',
                    subtitle: 'Consulta lo que opinan los ciudadanos de ti.',
                    onTap: () {},
                  ),
                  SettingsTileWidget(
                    icon: Icons.notifications_outlined,
                    title: 'Notificaciones',
                    subtitle: 'Gestiona tus preferencias de notificaciones.',
                    onTap: () {},
                  ),
                  SettingsTileWidget(
                    icon: Icons.credit_card_outlined,
                    title: 'Métodos de pago',
                    subtitle: 'Administra cómo pagas tus recolecciones.',
                    onTap: () {},
                  ),
                  SettingsTileWidget(
                    icon: Icons.shield_outlined,
                    title: 'Privacidad y seguridad',
                    subtitle: 'Configura tu contraseña y protege tu cuenta.',
                    onTap: () => context.push('/changePassword'),
                    showDivider: false,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              PremiumBannerWidget(onTap: () {}),
              const SizedBox(height: 24),

              const SettingsLogoutTile(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
