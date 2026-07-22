import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:treasureflow/features/home/shared/widgets/premium_banner_widget.dart';
import 'package:treasureflow/features/profile/citizen/presentation/providers/profile_posts_provider.dart';
import 'package:treasureflow/features/profile/shared/widgets/settings_group_card_widget.dart';
import 'package:treasureflow/features/profile/shared/widgets/settings_logout_tile_widget.dart';
import 'package:treasureflow/features/profile/shared/widgets/settings_profile_card_widget.dart';
import 'package:treasureflow/features/profile/shared/widgets/settings_section_label_widget.dart';
import 'package:treasureflow/features/profile/shared/widgets/settings_tile_widget.dart';

class SettingsScreenCitizen extends StatefulWidget {
  const SettingsScreenCitizen({super.key});

  @override
  State<SettingsScreenCitizen> createState() => _SettingsScreenCitizenState();
}

class _SettingsScreenCitizenState extends State<SettingsScreenCitizen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ProfilePostsProvider>();
      if (provider.profile == null) provider.loadPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;
    final profile = context.watch<ProfilePostsProvider>().profile;

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
                name: profile?.fullName ?? '—',
                email: profile?.email ?? '',
                avatarUrl: profile?.profilePictureUrl,
                onTap: () => context.push('/editCitizenProfile'),
              ),
              const SizedBox(height: 24),

              const SettingsSectionLabel('GENERAL'),
              const SizedBox(height: 8),
              SettingsGroupCard(
                children: [
                  SettingsTileWidget(
                    icon: Icons.person_outline,
                    title: 'Editar información personal',
                    subtitle: 'Actualiza tu nombre, correo, teléfono y foto.',
                    onTap: () => context.push('/editCitizenProfile'),
                  ),
                  SettingsTileWidget(
                    icon: Icons.notifications_outlined,
                    title: 'Notificaciones',
                    subtitle: 'Gestiona tus preferencias de notificaciones.',
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

              const SettingsSectionLabel('SOPORTE'),
              const SizedBox(height: 8),
              SettingsGroupCard(
                children: [
                  SettingsTileWidget(
                    icon: Icons.description_outlined,
                    title: 'Términos y condiciones',
                    subtitle: 'Información legal de la plataforma.',
                    onTap: () {},
                    showDivider: false,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              const SettingsLogoutTile(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
