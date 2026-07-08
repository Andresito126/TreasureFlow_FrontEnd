import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:treasureflow/features/auth/citizen/presentation/providers/auth_provider.dart';
import 'package:treasureflow/features/home/shared/widgets/premium_banner_widget.dart';

class SettingsScreenCitizen extends StatelessWidget {
  const SettingsScreenCitizen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

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
                    style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _profileCard(colors, textTheme),
              const SizedBox(height: 24),

              _sectionLabel('GENERAL', colors, textTheme),
              const SizedBox(height: 8),
              _groupCard([
                _settingsTile(
                  icon: Icons.person_outline,
                  title: 'Editar información personal',
                  subtitle: 'Actualiza tu nombre, correo, teléfono y foto.',
                  colors: colors,
                  textTheme: textTheme,
                  onTap: () {},
                ),
                _settingsTile(
                  icon: Icons.notifications_outlined,
                  title: 'Notificaciones',
                  subtitle: 'Gestiona tus preferencias de notificaciones.',
                  colors: colors,
                  textTheme: textTheme,
                  onTap: () {},
                ),
                _settingsTile(
                  icon: Icons.shield_outlined,
                  title: 'Privacidad y seguridad',
                  subtitle: 'Configura tu contraseña y protege tu cuenta.',
                  colors: colors,
                  textTheme: textTheme,
                  onTap: () {},
                  showDivider: false,
                ),
              ]),
              const SizedBox(height: 20),

              PremiumBannerWidget(onTap: () {}),
              const SizedBox(height: 24),

              _sectionLabel('SOPORTE', colors, textTheme),
              const SizedBox(height: 8),
              _groupCard([
                _settingsTile(
                  icon: Icons.description_outlined,
                  title: 'Términos y condiciones',
                  subtitle: 'Información legal de la plataforma.',
                  colors: colors,
                  textTheme: textTheme,
                  onTap: () {},
                  showDivider: false,
                ),
              ]),
              const SizedBox(height: 16),

              _logoutTile(context, colors, textTheme),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text, ColorScheme colors, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: textTheme.bodySmall?.copyWith(
          color: colors.onSurface.withValues(alpha: 0.5),
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _profileCard(ColorScheme colors, TextTheme textTheme) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.outline.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: colors.primary.withValues(alpha: 0.1),
              child: Icon(Icons.person, size: 28, color: colors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kevin Jimmy',
                    style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'kevin.jimmy@gmail.com',
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: colors.onSurface.withValues(alpha: 0.4)),
          ],
        ),
      ),
    );
  }

  Widget _groupCard(List<Widget> tiles) {
    return Builder(
      builder: (context) {
        final colors = Theme.of(context).colorScheme;
        return Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.outline.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(children: tiles),
        );
      },
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required ColorScheme colors,
    required TextTheme textTheme,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 18, color: colors.onPrimary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.onSurface.withValues(alpha: 0.5),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: colors.onSurface.withValues(alpha: 0.4)),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(height: 1, indent: 14, endIndent: 14, color: colors.outline.withValues(alpha: 0.15)),
      ],
    );
  }

  Widget _logoutTile(BuildContext context, ColorScheme colors, TextTheme textTheme) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outline.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _onLogoutPressed(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFE05353),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout, size: 18, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cerrar sesión',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFE05353),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Sale de tu cuenta de Treasure Flow.',
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.5),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colors.onSurface.withValues(alpha: 0.4)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onLogoutPressed(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cerrar sesión'),
        content: const Text('¿Seguro que quieres salir de tu cuenta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFE05353)),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    await context.read<AuthProvider>().logout();
    if (!context.mounted) return;

    context.go('/login');
  }
}
