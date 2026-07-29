import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:treasureflow/features/auth/presentation/providers/register_citizen_provider.dart';
import 'package:treasureflow/features/auth/presentation/widgets/register_avatar_picker_widget.dart';
import 'package:treasureflow/shared/widgets/input_field_widget.dart';
import 'package:treasureflow/shared/widgets/app_toast.dart';
import 'package:treasureflow/shared/widgets/primary_button_green_widget.dart';
import 'package:treasureflow/shared/utils/form_validators.dart';

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
  final _imagePicker = ImagePicker();

  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    context.read<RegisterCitizenProvider>().addListener(_onStatusChanged);
  }

  @override
  void dispose() {
    context.read<RegisterCitizenProvider>().removeListener(_onStatusChanged);
    _nameController.dispose();
    _lastNameController.dispose();
    _secondLastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onStatusChanged() {
    if (!mounted) return;
    final provider = context.read<RegisterCitizenProvider>();

    switch (provider.status) {
      case RegisterCitizenStatus.success:
        if (!_navigated) {
          _navigated = true;
          AppToast.show(context, 'Cuenta creada exitosamente', type: ToastType.success);
          context.go('/login');
        }
      case RegisterCitizenStatus.error:
        AppToast.show(
          context,
          provider.errorMessage ?? 'Error al registrar',
          type: ToastType.error,
        );
      case RegisterCitizenStatus.idle:
      case RegisterCitizenStatus.loading:
        break;
    }
  }

  Future<void> _pickImage() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );
    if (picked != null && mounted) {
      context.read<RegisterCitizenProvider>().setImage(File(picked.path));
    }
  }

  void _onConfirmPressed() {
    if (!_formKey.currentState!.validate()) return;

    context.read<RegisterCitizenProvider>().signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          phone: '+52${_phoneController.text.trim()}',
          firstName: _nameController.text.trim(),
          paternalLastName: _lastNameController.text.trim(),
          maternalLastName: _secondLastNameController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              Text(
                'Crea tu cuenta',
                style: textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Dale una segunda vida a lo que ya no usas.',
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.onSurface.withValues(alpha: .6),
                ),
              ),

              const SizedBox(height: 24),

              Consumer<RegisterCitizenProvider>(
                builder: (context, provider, _) => RegisterAvatarPickerWidget(
                  selectedImage: provider.selectedImage,
                  onTap: _pickImage,
                ),
              ),

              const SizedBox(height: 28),

              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: colors.outline.withValues(alpha: .1)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .10),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      InputFieldWidget(
                        controller: _nameController,
                        hTPlaceHolder: 'Nombre',
                        iconInput: Icons.person_outline,
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ]'))],
                        validator: (v) => v == null || v.trim().isEmpty ? 'Ingresa tu nombre' : null,
                      ),

                      const SizedBox(height: 16),

                      InputFieldWidget(
                        controller: _lastNameController,
                        hTPlaceHolder: 'Apellido paterno',
                        iconInput: Icons.person_outline,
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ]'))],
                        validator: (v) => v == null || v.trim().isEmpty ? 'Ingresa tu apellido paterno' : null,
                      ),

                      const SizedBox(height: 16),

                      InputFieldWidget(
                        controller: _secondLastNameController,
                        hTPlaceHolder: 'Apellido materno',
                        iconInput: Icons.person_outline,
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ]'))],
                        validator: (v) => v == null || v.trim().isEmpty ? 'Ingresa tu apellido materno' : null,
                      ),

                      const SizedBox(height: 16),

                      InputFieldWidget(
                        controller: _phoneController,
                        hTPlaceHolder: 'Número telefónico',
                        iconInput: Icons.phone_android_outlined,
                        prefixText: '+52',
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (v) => v == null || v.length != 10 ? 'Ingresa 10 dígitos' : null,
                      ),

                      const SizedBox(height: 16),

                      InputFieldWidget(
                        controller: _emailController,
                        hTPlaceHolder: 'Correo electrónico',
                        iconInput: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: FormValidators.email,
                      ),

                      const SizedBox(height: 16),

                      InputFieldWidget(
                        controller: _passwordController,
                        hTPlaceHolder: 'Contraseña',
                        iconInput: Icons.lock_outline,
                        isPassword: true,
                        validator: FormValidators.minLengthPassword,
                      ),

                      const SizedBox(height: 32),

                      Consumer<RegisterCitizenProvider>(
                        builder: (context, provider, _) {
                          return PrimaryButtonGreenWidget(
                            text: 'Confirmar datos',
                            isLoading: provider.status == RegisterCitizenStatus.loading,
                            onPressed: _onConfirmPressed,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
