import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:treasureflow/core/di/app_container.dart';
import 'package:treasureflow/features/profile/citizen/di/profile_module.dart';
import 'package:treasureflow/features/profile/citizen/presentation/providers/edit_citizen_profile_provider.dart';
import 'package:treasureflow/shared/layouts/app_card_container.dart';
import 'package:treasureflow/shared/widgets/app_toast.dart';
import 'package:treasureflow/shared/widgets/primary_button_blue_widget.dart';
import 'package:treasureflow/shared/widgets/primary_button_green_widget.dart';

class EditCitizenProfileScreen extends StatefulWidget {
  const EditCitizenProfileScreen({super.key});

  @override
  State<EditCitizenProfileScreen> createState() =>
      _EditCitizenProfileScreenState();
}

class _EditCitizenProfileScreenState extends State<EditCitizenProfileScreen> {
  late final EditCitizenProfileProvider _provider;
  final _imagePicker = ImagePicker();

  final _firstNameController = TextEditingController();
  final _paternalLastNameController = TextEditingController();
  final _maternalLastNameController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _formPrefilled = false;
  bool _popped = false;

  @override
  void initState() {
    super.initState();
    final container = context.read<AppContainer>();
    _provider = ProfileModule(container).provideEditCitizenProfileProvider();
    _provider.addListener(_onProviderChanged);
    _provider.load();
  }

  @override
  void dispose() {
    _provider.removeListener(_onProviderChanged);
    _provider.dispose();
    _firstNameController.dispose();
    _paternalLastNameController.dispose();
    _maternalLastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onProviderChanged() {
    if (!mounted) return;

    if (_provider.status == EditCitizenProfileStatus.success &&
        !_formPrefilled) {
      final profile = _provider.profile;
      if (profile != null) {
        _firstNameController.text = profile.firstName;
        _paternalLastNameController.text = profile.paternalLastName;
        _maternalLastNameController.text = profile.maternalLastName;
        _phoneController.text = profile.phone;
        _formPrefilled = true;
      }
    }

    if (_provider.saveStatus == SaveCitizenProfileStatus.saved && !_popped) {
      _popped = true;
      AppToast.show(context, 'Perfil actualizado', type: ToastType.success);
      Navigator.of(context).pop(true);
    } else if (_provider.saveStatus == SaveCitizenProfileStatus.error) {
      AppToast.show(
        context,
        _provider.saveError ?? 'No se pudo guardar tu perfil',
        type: ToastType.error,
      );
    }

    setState(() {});
  }

  Future<void> _pickImage() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );
    if (picked != null && mounted) {
      _provider.setImage(File(picked.path));
    }
  }

  void _onSave() {
    if (_firstNameController.text.trim().isEmpty ||
        _paternalLastNameController.text.trim().isEmpty ||
        _maternalLastNameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty) {
      AppToast.show(
        context,
        'Completa todos los campos',
        type: ToastType.error,
      );
      return;
    }

    _provider.save(
      firstName: _firstNameController.text.trim(),
      paternalLastName: _paternalLastNameController.text.trim(),
      maternalLastName: _maternalLastNameController.text.trim(),
      phone: _phoneController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  BackButton(color: colors.primary),
                  const SizedBox(width: 4),
                  Text(
                    'Editar información personal',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildBody(colors, textTheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(ColorScheme colors, TextTheme textTheme) {
    if (_provider.status == EditCitizenProfileStatus.loading ||
        _provider.status == EditCitizenProfileStatus.idle) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 60),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_provider.status == EditCitizenProfileStatus.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              Icon(Icons.error_outline_rounded, size: 48, color: colors.error),
              const SizedBox(height: 16),
              Text(
                _provider.errorMessage ?? 'No se pudo cargar tu perfil',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              PrimaryButtonBlueWidget(
                text: 'Reintentar',
                onPressed: _provider.load,
              ),
            ],
          ),
        ),
      );
    }

    final profile = _provider.profile;
    final isSaving = _provider.saveStatus == SaveCitizenProfileStatus.saving;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(child: _buildAvatarPicker(colors)),
        const SizedBox(height: 24),
        AppCardContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _readOnlyField('Correo', profile?.email ?? '', colors, textTheme),
              const SizedBox(height: 16),
              _textField('Nombre', _firstNameController, textTheme, colors),
              const SizedBox(height: 16),
              _textField(
                'Apellido paterno',
                _paternalLastNameController,
                textTheme,
                colors,
              ),
              const SizedBox(height: 16),
              _textField(
                'Apellido materno',
                _maternalLastNameController,
                textTheme,
                colors,
              ),
              const SizedBox(height: 16),
              _textField(
                'Teléfono',
                _phoneController,
                textTheme,
                colors,
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: isSaving
              ? const Center(child: CircularProgressIndicator())
              : PrimaryButtonGreenWidget(
                  text: 'Guardar cambios',
                  onPressed: _onSave,
                ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildAvatarPicker(ColorScheme colors) {
    final localImage = _provider.selectedImage;
    final remoteUrl = _provider.profile?.profilePictureUrl;

    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: colors.primary.withValues(alpha: 0.1),
            backgroundImage: localImage != null
                ? FileImage(localImage)
                : (remoteUrl != null
                      ? NetworkImage(remoteUrl) as ImageProvider
                      : null),
            child: localImage == null && remoteUrl == null
                ? Icon(Icons.person, size: 48, color: colors.primary)
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: colors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: colors.surface, width: 2),
              ),
              child: Icon(
                Icons.camera_alt_rounded,
                size: 16,
                color: colors.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _readOnlyField(
    String label,
    String value,
    ColorScheme colors,
    TextTheme textTheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: colors.onSurface.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _textField(
    String label,
    TextEditingController controller,
    TextTheme textTheme,
    ColorScheme colors, {
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: textTheme.bodyMedium,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: colors.surfaceContainerLowest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.outline.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.outline.withValues(alpha: 0.2)),
        ),
      ),
    );
  }
}
