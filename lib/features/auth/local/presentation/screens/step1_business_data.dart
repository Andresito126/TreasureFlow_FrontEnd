import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:treasureflow/features/auth/local/presentation/providers/register_local_provider.dart';
import 'package:treasureflow/shared/layouts/app_card_container.dart';
import 'package:treasureflow/shared/widgets/input_field_widget.dart';
import 'package:treasureflow/shared/widgets/primary_button_green_widget.dart';

class Step1BusinessData extends StatefulWidget {
  final VoidCallback onNext;

  const Step1BusinessData({super.key, required this.onNext});

  @override
  State<Step1BusinessData> createState() => _Step1BusinessDataState();
}

class _Step1BusinessDataState extends State<Step1BusinessData> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _imagePicker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );
    if (picked != null && mounted) {
      context.read<RegisterLocalProvider>().setProfileImage(File(picked.path));
    }
  }

  Future<void> _pickPhoto() async {
    final provider = context.read<RegisterLocalProvider>();
    if (provider.photos.length >= 3) return;

    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 80,
    );
    if (picked != null && mounted) {
      provider.addPhoto(File(picked.path));
    }
  }

  void _onNext() {
    if (!_formKey.currentState!.validate()) return;

    context.read<RegisterLocalProvider>().setStep1Data(
      storeName: _nameController.text.trim(),
      phone: '+52${_phoneController.text.trim()}',
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Form(
        key: _formKey,
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
                        color: colors.surfaceContainerHighest,
                        child: const Center(child: Icon(Icons.image, size: 50)),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    child: GestureDetector(
                      onTap: _pickProfileImage,
                      child: Consumer<RegisterLocalProvider>(
                        builder: (context, provider, _) {
                          return Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                height: 80,
                                width: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: colors.surface,
                                  border: Border.all(
                                    color: colors.surface,
                                    width: 4,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: provider.profileImage != null
                                      ? Image.file(
                                          provider.profileImage!,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.asset(
                                          'assets/auth/basurini_ball.png',
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
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
                                  border: Border.all(
                                    color: colors.surface,
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
                          );
                        },
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
                    maxLength: 50,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Ingresa el nombre del local'
                        : null,
                  ),

                  const SizedBox(height: 16),

                  InputFieldWidget(
                    controller: _phoneController,
                    hTPlaceHolder: 'Teléfono de contacto',
                    iconInput: Icons.phone,
                    prefixText: '+52',
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) => v == null || v.length != 10
                        ? 'Ingresa 10 dígitos'
                        : null,
                  ),

                  const SizedBox(height: 16),

                  InputFieldWidget(
                    controller: _emailController,
                    hTPlaceHolder: 'Correo electrónico',
                    iconInput: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty)
                        return 'Ingresa tu correo';
                      final emailRegex = RegExp(
                        r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,}$',
                      );
                      if (!emailRegex.hasMatch(v.trim()))
                        return 'Correo no válido';
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  InputFieldWidget(
                    controller: _passwordController,
                    hTPlaceHolder: 'Contraseña',
                    iconInput: Icons.lock,
                    isPassword: true,
                    validator: (v) => v == null || v.length < 8
                        ? 'Mínimo 8 caracteres'
                        : null,
                  ),

                  const SizedBox(height: 24),

                  Consumer<RegisterLocalProvider>(
                    builder: (context, provider, _) {
                      return Row(
                        children: List.generate(3, (index) {
                          final hasPhoto = index < provider.photos.length;
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: index > 0 ? 6 : 0,
                                right: index < 2 ? 6 : 0,
                              ),
                              child: GestureDetector(
                                onTap: hasPhoto
                                    ? () => provider.removePhoto(index)
                                    : _pickPhoto,
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: colors.outline),
                                      image: hasPhoto
                                          ? DecorationImage(
                                              image: FileImage(
                                                provider.photos[index],
                                              ),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                    ),
                                    child: hasPhoto
                                        ? Align(
                                            alignment: Alignment.topRight,
                                            child: Container(
                                              margin: const EdgeInsets.all(4),
                                              padding: const EdgeInsets.all(2),
                                              decoration: const BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.close,
                                                size: 14,
                                                color: Colors.white,
                                              ),
                                            ),
                                          )
                                        : Icon(
                                            Icons.add_a_photo_outlined,
                                            color: colors.primary,
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  PrimaryButtonGreenWidget(
                    text: 'Siguiente',
                    onPressed: _onNext,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
