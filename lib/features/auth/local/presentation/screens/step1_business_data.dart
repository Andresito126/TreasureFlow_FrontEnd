import 'package:flutter/material.dart';
import 'package:treasureflow/features/auth/local/presentation/widgets/register_profile_header._widget.dart';
import 'package:treasureflow/shared/widgets/input_field_widget.dart';
import 'package:treasureflow/shared/widgets/primary_button_green_widget.dart';

class Step1BusinessData extends StatelessWidget {
  final VoidCallback onNext;

  Step1BusinessData({super.key, required this.onNext});

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          RegisterProfileHeaderWidget(onEditPhoto: () {
            // la logicaaaaaaa
          }),

          const SizedBox(height: 32),

          InputFieldWidget(
            controller: _nameController,
            hTPlaceHolder: 'Nombre del local',
            iconInput: Icons.storefront,
          ),
          const SizedBox(height: 16),
          InputFieldWidget(
            controller: _phoneController,
            hTPlaceHolder: 'Teléfono de contacto',
            iconInput: Icons.phone,
          ),
          const SizedBox(height: 16),
          InputFieldWidget(
            controller: _emailController,
            hTPlaceHolder: 'Correo electrónico',
            iconInput: Icons.email,
          ),
          const SizedBox(height: 16),
          InputFieldWidget(
            controller: _passwordController,
            hTPlaceHolder: 'Contraseña',
            iconInput: Icons.lock,
            isPassword: true,
          ),

          const SizedBox(height: 32),

          PrimaryButtonGreenWidget(text: 'Siguiente', onPressed: onNext),
        ],
      ),
    );
  }
}
