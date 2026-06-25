import 'package:flutter/material.dart';
import 'package:treasureflow/shared/layouts/app_card_container.dart';
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 160,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Container(
                  height: 120,
                  width: double.infinity,
                  child: Image.asset(
                    'assets/auth/banner.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: colors.surfaceVariant,
                      child: const Center(child: Icon(Icons.image, size: 50)),
                    ),
                  ),
                ),

                Positioned(
                  bottom: 0,
                  child: GestureDetector(
                    onTap: () {
                      print("Seleccionar foto del local");
                    },
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colors.surface,
                            border: Border.all(color: colors.surface, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/auth/basurini_ball.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.storefront,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                            ),
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: colors.secondary,
                            shape: BoxShape.circle,
                            border: Border.all(color: colors.surface, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          AppCardContainer(
            child: Column(
              children: [
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
                  keyboardType: TextInputType.phone,
                ),

                const SizedBox(height: 16),

                InputFieldWidget(
                  controller: _emailController,
                  hTPlaceHolder: 'Correo electrónico',
                  iconInput: Icons.email,
                  keyboardType: TextInputType.emailAddress,
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
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
