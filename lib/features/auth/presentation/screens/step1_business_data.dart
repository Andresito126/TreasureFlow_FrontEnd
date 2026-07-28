import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:treasureflow/features/auth/presentation/providers/register_local_provider.dart';
import 'package:treasureflow/features/auth/presentation/widgets/register_avatar_picker_widget.dart';
import 'package:treasureflow/shared/layouts/app_card_container.dart';
import 'package:treasureflow/shared/widgets/app_toast.dart';
import 'package:treasureflow/shared/widgets/input_field_widget.dart';
import 'package:treasureflow/shared/widgets/primary_button_green_widget.dart';
import 'package:treasureflow/shared/utils/form_validators.dart';

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

    final provider = context.read<RegisterLocalProvider>();

    if (provider.profileImage == null) {
      AppToast.show(context, 'Selecciona una foto de perfil', type: ToastType.warning);
      return;
    }

    if (provider.photos.isEmpty) {
      AppToast.show(context, 'Agrega las 3 fotos de tu local', type: ToastType.warning);
      return;
    }

    provider.setStep1Data(
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
            Consumer<RegisterLocalProvider>(
              builder: (context, provider, _) => RegisterAvatarPickerWidget(
                selectedImage: provider.profileImage,
                onTap: _pickProfileImage,
                avatarSize: 80,
                placeholderIcon: Icons.storefront,
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
                    validator: (v) => v == null || v.trim().isEmpty ? 'Ingresa el nombre del local' : null,
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
                    validator: (v) => v == null || v.length != 10 ? 'Ingresa 10 dígitos' : null,
                  ),

                  const SizedBox(height: 16),

                  InputFieldWidget(
                    controller: _emailController,
                    hTPlaceHolder: 'Correo electrónico',
                    iconInput: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: FormValidators.email,
                  ),

                  const SizedBox(height: 16),

                  InputFieldWidget(
                    controller: _passwordController,
                    hTPlaceHolder: 'Contraseña',
                    iconInput: Icons.lock,
                    isPassword: true,
                    validator: FormValidators.minLengthPassword,
                  ),

                  const SizedBox(height: 24),

                  Consumer<RegisterLocalProvider>(
                    builder: (context, provider, _) {
                      final theme = Theme.of(context);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.photo_library_outlined, size: 16, color: theme.colorScheme.onSurface),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Fotos del local',
                                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ),
                              Text(
                                '${provider.photos.length}/3',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Agrega fotos para que los ciudadanos conozcan tu local',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
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
                                                  image: FileImage(provider.photos[index]),
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
                                                  child: const Icon(Icons.close, size: 14, color: Colors.white),
                                                ),
                                              )
                                            : Icon(Icons.add_a_photo_outlined, color: colors.primary),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  PrimaryButtonGreenWidget(text: 'Siguiente', onPressed: _onNext),
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
