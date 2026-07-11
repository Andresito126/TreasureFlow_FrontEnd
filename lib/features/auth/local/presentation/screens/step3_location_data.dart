import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:treasureflow/core/maps/presentation/providers/map_provider.dart';
import 'package:treasureflow/features/auth/local/presentation/providers/register_local_provider.dart';
import 'package:treasureflow/shared/widgets/app_toast.dart';
import 'package:treasureflow/shared/widgets/map/treasure_map_widget.dart';

class Step3LocationData extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const Step3LocationData({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<Step3LocationData> createState() => _Step3LocationDataState();
}

class _Step3LocationDataState extends State<Step3LocationData> {
  @override
  void initState() {
    super.initState();
    context.read<RegisterLocalProvider>().addListener(_onStatusChanged);
  }

  void _onStatusChanged() {
    final provider = context.read<RegisterLocalProvider>();

    if (provider.status == RegisterLocalStatus.success) {
      AppToast.show(context, 'Establecimiento registrado exitosamente', type: ToastType.success);
      context.go('/login');
    }

    if (provider.status == RegisterLocalStatus.error) {
      AppToast.show(
        context,
        provider.errorMessage ?? 'Error al registrar',
        type: ToastType.error,
      );
    }
  }

  void _onConfirm() {
    final mapProvider = context.read<MapProvider>();
    final registerProvider = context.read<RegisterLocalProvider>();

    final pin = mapProvider.pinLocation;
    if (pin == null) {
      AppToast.show(context, 'Selecciona una ubicación en el mapa', type: ToastType.warning);
      return;
    }

    registerProvider.setLocation(
      latitude: pin.latitude,
      longitude: pin.longitude,
      addressText: mapProvider.currentPlace != null
          ? '${mapProvider.currentPlace!.street} ${mapProvider.currentPlace!.streetNumber}, ${mapProvider.currentPlace!.city}'
          : null,
    );

    registerProvider.signUp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TreasureMapWidget(onNext: _onConfirm, onBack: widget.onBack, nextLabel: 'Crear cuenta'),
    );
  }
}
