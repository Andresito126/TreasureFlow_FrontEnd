import 'package:flutter/material.dart';
import 'package:treasureflow/shared/theme/app_theme_extension.dart';

class CollectionStatusInfo {
  final String label;
  final Color color;

  const CollectionStatusInfo({required this.label, required this.color});
}

/// Traduce el status crudo de la API de collections a etiqueta + color.
class CollectionStatusTranslator {
  static CollectionStatusInfo translate(String rawStatus, ThemeData theme) {
    final ext = theme.extension<AppThemeExtension>();
    final colors = theme.colorScheme;

    return switch (rawStatus) {
      'pending_delivery' || 'pending_weighing' => CollectionStatusInfo(
          label: 'Pesaje pendiente',
          color: ext?.blueHold ?? colors.primary,
        ),
      'pending_confirmation' => CollectionStatusInfo(
          label: 'Confirmar monto',
          color: ext?.yellowComplete ?? colors.secondary,
        ),
      'pending_payment' => CollectionStatusInfo(
          label: 'Pago pendiente',
          color: colors.primary,
        ),
      'completed' => CollectionStatusInfo(
          label: 'Completada',
          color: ext?.yellowComplete ?? colors.primary,
        ),
      'cancelled_by_citizen' ||
      'cancelled_by_establishment' =>
        CollectionStatusInfo(
          label: 'Cancelada',
          color: ext?.redExpired ?? colors.error,
        ),
      _ => CollectionStatusInfo(
          label: 'Desconocido',
          color: colors.outline,
        ),
    };
  }
}
