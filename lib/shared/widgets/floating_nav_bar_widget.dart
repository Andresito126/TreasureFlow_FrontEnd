import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:treasureflow/features/auth/citizen/presentation/providers/auth_provider.dart';

class FloatingNavBarWidget extends StatelessWidget {
  final int currentIndex;

  const FloatingNavBarWidget({super.key, required this.currentIndex});

  /// Ciudadano: inicio(0), explorar(1), ventas(2), perfil(3).
  /// Establecimiento: inicio(0), explorar(1), compras(2), perfil(3).


  List<_NavItem> _itemsFor(bool isEstablishment) {
    return [
      _NavItem(
        icon: Icons.home_rounded,
        label: 'Inicio',
        route: isEstablishment ? '/homeLocal' : '/homeCitizen',
      ),
      const _NavItem(
        icon: Icons.explore_rounded,
        label: 'Explorar',
        route: '/feed',
      ),
      if (isEstablishment)
        const _NavItem(
          icon: Icons.local_shipping_rounded,
          label: 'Compras',
          route: '/myPurchases',
        )
      else
        const _NavItem(
          icon: Icons.sell_rounded,
          label: 'Ventas',
          route: '/mySales',
        ),
      _NavItem(
        icon: Icons.person_rounded,
        label: 'Perfil',
        route: isEstablishment ? '/profileLocal' : '/profile',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final isEstablishment =
        context.read<AuthProvider>().userType == 'establishment';
    final items = _itemsFor(isEstablishment);

    return Container(
      margin: const EdgeInsets.only(left: 48, right: 48, bottom: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: colors.outline.withValues(alpha: 0.1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(items.length, (index) {
                final isActive = currentIndex == index;
                return _buildItem(
                  item: items[index],
                  isActive: isActive,
                  colors: colors,
                  onTap: () {
                    if (index == currentIndex) return;
                    context.go(items[index].route);
                  },
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItem({
    required _NavItem item,
    required bool isActive,
    required ColorScheme colors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.4),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Icon(
          item.icon,
          size: 24,
          color: isActive
              ? colors.onPrimary
              : colors.onSurface.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String route;
  const _NavItem({required this.icon, required this.label, required this.route});
}
