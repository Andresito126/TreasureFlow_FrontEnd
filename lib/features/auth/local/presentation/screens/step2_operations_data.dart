import 'package:flutter/material.dart';
import 'package:treasureflow/features/auth/local/presentation/widgets/day_selector_widget.dart';
import 'package:treasureflow/shared/widgets/primary_button_blue_widget.dart';
import 'package:treasureflow/shared/widgets/primary_button_green_widget.dart';

class Step2OperationsData extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const Step2OperationsData({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Horarios de atención", style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),
          const DaySelectorWidget(),

          const SizedBox(height: 32),

          Text("Materiales que aceptas", style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),
          
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.colorScheme.outline),
            ),
            child: Center(
              child: Text(
                "Esperando a Kev...",
                style: theme.textTheme.bodySmall,
              ),
            ),
          ),

          const SizedBox(height: 32),

          SwitchListTile(
            title: Text("Ofrece recolección a domicilio", style: theme.textTheme.bodyMedium),
            value: true,
            onChanged: (val) {},
            activeColor: theme.colorScheme.primary,
          ),

          const SizedBox(height: 32),

          Row(
            children: [
              Expanded(
                child: PrimaryButtonBlueWidget(
                  text: 'Regresar',
                  onPressed: onBack,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: PrimaryButtonGreenWidget(
                  text: 'Siguiente',
                  onPressed: onNext,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
