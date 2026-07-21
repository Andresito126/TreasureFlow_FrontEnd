import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:treasureflow/core/di/app_container.dart';
import 'package:treasureflow/features/profile/local/di/local_profile_module.dart';
import 'package:treasureflow/features/profile/local/presentation/providers/local_profile_provider.dart';
import 'package:treasureflow/shared/layouts/app_card_container.dart';
import 'package:treasureflow/shared/widgets/app_toast.dart';
import 'package:treasureflow/shared/widgets/primary_button_blue_widget.dart';
import 'package:treasureflow/shared/widgets/primary_button_green_widget.dart';

class EditEstablishmentProfileScreen extends StatefulWidget {
  const EditEstablishmentProfileScreen({super.key});

  @override
  State<EditEstablishmentProfileScreen> createState() =>
      _EditEstablishmentProfileScreenState();
}

class _EditEstablishmentProfileScreenState
    extends State<EditEstablishmentProfileScreen> {
  late final LocalProfileProvider _provider;
  final _imagePicker = ImagePicker();

  final _storeNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _hasVehicle = false;

  bool _formPrefilled = false;

  @override
  void initState() {
    super.initState();
    final container = context.read<AppContainer>();
    _provider = LocalProfileModule(container).provideLocalProfileProvider();
    _provider.addListener(_onProviderChanged);
    _provider.load();
  }

  @override
  void dispose() {
    _provider.removeListener(_onProviderChanged);
    _provider.dispose();
    _storeNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _onProviderChanged() {
    if (!mounted) return;

    if (_provider.status == LocalProfileStatus.success && !_formPrefilled) {
      final profile = _provider.profile;
      if (profile != null) {
        _storeNameController.text = profile.storeName;
        _phoneController.text = profile.phone;
        _addressController.text = profile.addressText ?? '';
        _hasVehicle = profile.hasVehicle;
        _formPrefilled = true;
      }
    }

    if (_provider.saveStatus == SaveLocalProfileStatus.saved) {
      AppToast.show(context, 'Perfil actualizado', type: ToastType.success);
      Navigator.of(context).pop(true);
    } else if (_provider.saveStatus == SaveLocalProfileStatus.error) {
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
    if (_storeNameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty) {
      AppToast.show(
        context,
        'Completa todos los campos',
        type: ToastType.error,
      );
      return;
    }

    _provider.updateProfile(
      storeName: _storeNameController.text.trim(),
      phone: _phoneController.text.trim(),
      addressText: _addressController.text.trim(),
      hasVehicle: _hasVehicle,
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
                  Expanded(
                    child: Text(
                      'Editar información del establecimiento',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
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
    if (_provider.status == LocalProfileStatus.loading ||
        _provider.status == LocalProfileStatus.idle) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 60),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_provider.status == LocalProfileStatus.error) {
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
    final isSaving = _provider.saveStatus == SaveLocalProfileStatus.saving;

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
              _textField(
                'Nombre del establecimiento',
                _storeNameController,
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
              const SizedBox(height: 16),
              _textField(
                'Dirección',
                _addressController,
                textTheme,
                colors,
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              _vehicleSwitch(colors, textTheme),
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
                ? Icon(
                    Icons.storefront_rounded,
                    size: 48,
                    color: colors.primary,
                  )
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
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
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

  Widget _vehicleSwitch(ColorScheme colors, TextTheme textTheme) {
    return Row(
      children: [
        Icon(Icons.local_shipping_outlined, size: 18, color: colors.primary),
        const SizedBox(width: 10),
        Expanded(child: Text('Vehículo propio', style: textTheme.bodyMedium)),
        Switch(
          value: _hasVehicle,
          activeTrackColor: colors.primary,
          onChanged: (value) => setState(() => _hasVehicle = value),
        ),
      ],
    );
  }
}
