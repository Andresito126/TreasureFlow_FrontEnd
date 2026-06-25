import 'package:flutter/material.dart';
import 'package:treasureflow/shared/widgets/input_field_widget.dart';
import 'package:treasureflow/shared/widgets/primary_button_green_widget.dart';

class RegisterCitizenScreen extends StatefulWidget {
  const RegisterCitizenScreen({super.key});

  @override
  State<RegisterCitizenScreen> createState() => _RegisterCitizenScreenState();
}

class _RegisterCitizenScreenState extends State<RegisterCitizenScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _secondLastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _secondLastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onConfirmPressed() {}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Crea tu cuenta',
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.onBackground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Dale una segunda vida a lo que ya no usas',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.onBackground.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              height: 160,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    height: 120,
                    width: double.infinity,
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(),

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
                        print("Seleccionar foto de perfil");
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
                              border: Border.all(
                                color: colors.background,
                                width: 4,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
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
                                      Icons.person,
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
                              border: Border.all(
                                color: colors.background,
                                width: 2,
                              ),
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

            const SizedBox(height: 32),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    InputFieldWidget(
                      controller: _nameController,
                      hTPlaceHolder: 'Nombre',
                      iconInput: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),

                    InputFieldWidget(
                      controller: _lastNameController,
                      hTPlaceHolder: 'Apellido Paterno',
                      iconInput: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),

                    InputFieldWidget(
                      controller: _secondLastNameController,
                      hTPlaceHolder: 'Apellido Materno',
                      iconInput: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),

                    InputFieldWidget(
                      controller: _phoneController,
                      hTPlaceHolder: 'Número de teléfono',
                      iconInput: Icons.phone_android_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),

                    InputFieldWidget(
                      controller: _emailController,
                      hTPlaceHolder: 'Correo electrónico',
                      iconInput: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),

                    InputFieldWidget(
                      controller: _passwordController,
                      hTPlaceHolder: 'Contraseña',
                      iconInput: Icons.lock_outline,
                      isPassword: true,
                    ),

                    const SizedBox(height: 40),

                    PrimaryButtonGreenWidget(
                      text: 'Confirmar datos',
                      onPressed: _onConfirmPressed,
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
