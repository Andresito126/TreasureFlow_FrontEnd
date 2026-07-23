import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:treasureflow/core/di/app_container.dart';
import 'package:treasureflow/features/profile/local/di/local_profile_module.dart';
import 'package:treasureflow/features/profile/local/domain/entities/establishment_profile.dart';
import 'package:treasureflow/features/profile/local/presentation/providers/local_profile_provider.dart';
import 'package:treasureflow/shared/layouts/app_card_container.dart';
import 'package:treasureflow/shared/widgets/app_toast.dart';
import 'package:treasureflow/shared/widgets/operating_hours_selector.dart';
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
  List<DaySchedule>? _daySchedules;

  bool _formPrefilled = false;
  bool _popped = false;

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

    if (_provider.saveStatus == SaveLocalProfileStatus.saved && !_popped) {
      _popped = true;
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

  Future<void> _pickEstablishmentPhoto() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 80,
    );
    if (picked != null && mounted) {
      _provider.addPhoto(File(picked.path));
    }
  }

  void _onScheduleChanged(List<DaySchedule> days) {
    _daySchedules = days;
  }

  List<ScheduleEntry>? _initialScheduleEntries(EstablishmentProfile? profile) {
    if (profile == null) return null;
    return profile.schedules
        .map(
          (s) => (
            dayOfWeek: s.dayOfWeek,
            startTime: s.startTime,
            endTime: s.endTime,
          ),
        )
        .toList();
  }

  List<EstablishmentSchedule>? _resolveSchedules() {
    final edited = _daySchedules;
    if (edited == null) return _provider.profile?.schedules;

    final schedules = <EstablishmentSchedule>[];
    for (int i = 0; i < edited.length; i++) {
      final day = edited[i];
      if (!day.isOpen) continue;
      for (final range in day.ranges) {
        final startStr =
            '${range.start.hour.toString().padLeft(2, '0')}:${range.start.minute.toString().padLeft(2, '0')}';
        final endStr =
            '${range.end.hour.toString().padLeft(2, '0')}:${range.end.minute.toString().padLeft(2, '0')}';
        schedules.add(
          EstablishmentSchedule(
            dayOfWeek: i + 1,
            startTime: startStr,
            endTime: endStr,
          ),
        );
      }
    }
    return schedules;
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
      schedules: _resolveSchedules(),
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
        AppCardContainer(child: _buildPhotosSection(colors, textTheme)),
        const SizedBox(height: 24),
        AppCardContainer(child: _buildHoursSection(profile, colors, textTheme)),
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

  Widget _buildPhotosSection(ColorScheme colors, TextTheme textTheme) {
    final existing = _provider.existingPhotoUrls;
    final newOnes = _provider.newPhotos;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fotos del establecimiento',
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          'Muestra tu local con fotos del lugar (máx. 3).',
          style: textTheme.bodySmall?.copyWith(
            color: colors.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (int i = 0; i < existing.length; i++)
              _photoThumb(
                image: NetworkImage(existing[i]),
                onRemove: () => _provider.removeExistingPhoto(i),
                colors: colors,
              ),
            for (int i = 0; i < newOnes.length; i++)
              _photoThumb(
                image: FileImage(newOnes[i]),
                onRemove: () => _provider.removeNewPhoto(i),
                colors: colors,
              ),
            if (_provider.canAddMorePhotos) _addPhotoTile(colors),
          ],
        ),
      ],
    );
  }

  Widget _photoThumb({
    required ImageProvider image,
    required VoidCallback onRemove,
    required ColorScheme colors,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image(image: image, width: 80, height: 80, fit: BoxFit.cover),
        ),
        Positioned(
          top: -6,
          right: -6,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: colors.error,
                shape: BoxShape.circle,
                border: Border.all(color: colors.surface, width: 2),
              ),
              child: Icon(Icons.close, size: 12, color: colors.onError),
            ),
          ),
        ),
      ],
    );
  }

  Widget _addPhotoTile(ColorScheme colors) {
    return GestureDetector(
      onTap: _pickEstablishmentPhoto,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.outline.withValues(alpha: 0.4)),
          color: colors.surfaceContainerLowest,
        ),
        child: Icon(Icons.add_a_photo_outlined, color: colors.primary),
      ),
    );
  }

  Widget _buildHoursSection(
    EstablishmentProfile? profile,
    ColorScheme colors,
    TextTheme textTheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.access_time, size: 18, color: colors.onSurface),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Horarios de atención',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        OperatingHoursSelector(
          initialEntries: _initialScheduleEntries(profile),
          onChanged: _onScheduleChanged,
        ),
      ],
    );
  }
}
