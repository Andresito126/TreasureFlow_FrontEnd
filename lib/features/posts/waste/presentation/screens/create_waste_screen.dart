import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:treasureflow/core/maps/presentation/providers/map_provider.dart';
import 'package:treasureflow/features/auth/local/presentation/widgets/operating_hours_selector.dart';
import 'package:treasureflow/features/posts/waste/domain/entities/waste_availability.dart';
import 'package:treasureflow/features/posts/waste/presentation/providers/create_waste_provider.dart';
import 'package:treasureflow/features/posts/waste/presentation/widgets/location_preview_widget.dart';
import 'package:treasureflow/shared/layouts/app_card_container.dart';
import 'package:treasureflow/shared/widgets/category_card_widget.dart';
import 'package:treasureflow/shared/widgets/numbered_step_title.dart';
import 'package:treasureflow/shared/widgets/primary_button_green_widget.dart';
import 'package:treasureflow/shared/widgets/screen_header_widget.dart';
import 'package:treasureflow/shared/widgets/selection_card_widget.dart';

class _CategoryItem {
  final String id;
  final String title;
  final String? svgPath;
  final IconData? icon;
  const _CategoryItem({required this.id, required this.title, this.svgPath, this.icon});
}

class CreateWasteScreen extends StatefulWidget {
  const CreateWasteScreen({super.key});

  @override
  State<CreateWasteScreen> createState() => _CreateWasteScreenState();
}

class _CreateWasteScreenState extends State<CreateWasteScreen> {
  static const List<_CategoryItem> _categories = [
    _CategoryItem(id: 'e78a20e5-a69d-4edb-bf50-33831f9aae6e', title: 'Aluminio', svgPath: 'assets/icons/aluminum.svg'),
    _CategoryItem(id: '2e532ca8-c6de-465d-af27-c2465b74f14c', title: 'Aceite', svgPath: 'assets/icons/oil.svg'),
    _CategoryItem(id: '1be3bf83-8b1a-421c-8474-a72785bf80b5', title: 'Papel/Cartón', svgPath: 'assets/icons/cardboard.svg'),
    _CategoryItem(id: 'caa8cf7a-d5f6-4ae6-a9aa-ea92bdf4b334', title: 'Plástico', svgPath: 'assets/icons/plastic.svg'),
    _CategoryItem(id: '918a523e-655b-4f53-bd86-2d43c2618be5', title: 'Metal', svgPath: 'assets/icons/metal.svg'),
    _CategoryItem(id: '37962e6b-8f0a-4dd7-9e5d-0db74d021313', title: 'Pila/Batería', svgPath: 'assets/icons/battery.svg'),
  ];

  final TextEditingController _descriptionController = TextEditingController();
  final _imagePicker = ImagePicker();
  LatLng? _selectedLocation;
  String? _selectedAddress;
  List<DaySchedule> _daySchedules = [];

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
    context.read<CreateWasteProvider>().addListener(_onStatusChanged);
  }

  Future<void> _loadCurrentLocation() async {
    final provider = context.read<MapProvider>();
    await provider.initializeLocation();
    if (!mounted) return;
    final place = provider.currentPlace;
    if (place != null) {
      setState(() {
        _selectedLocation = LatLng(place.latitude, place.longitude);
        _selectedAddress = '${place.street} ${place.streetNumber}, ${place.city}'.trim();
      });
      context.read<CreateWasteProvider>().setLocation(
            latitude: place.latitude,
            longitude: place.longitude,
            addressText: _selectedAddress!,
          );
    }
  }

  void _onStatusChanged() {
    final provider = context.read<CreateWasteProvider>();

    if (provider.status == CreateWasteStatus.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Residuo publicado exitosamente')),
      );
      provider.reset();
      context.go('/homeCitizen');
    }

    if (provider.status == CreateWasteStatus.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? 'Error al publicar')),
      );
    }
  }

  Future<void> _pickPhoto() async {
    final provider = context.read<CreateWasteProvider>();
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

  void _onSubmit() {
    final provider = context.read<CreateWasteProvider>();
    provider.setDescription(_descriptionController.text);

    if (provider.deliveryMode == 'home_delivery' && _daySchedules.isNotEmpty) {
      final schedules = <WasteAvailability>[];
      for (int i = 0; i < _daySchedules.length; i++) {
        final day = _daySchedules[i];
        if (!day.isOpen) continue;
        for (final range in day.ranges) {
          schedules.add(WasteAvailability(
            dayOfWeek: i + 1,
            startTime: '${range.start.hour.toString().padLeft(2, '0')}:${range.start.minute.toString().padLeft(2, '0')}',
            endTime: '${range.end.hour.toString().padLeft(2, '0')}:${range.end.minute.toString().padLeft(2, '0')}',
          ));
        }
      }
      provider.setSchedules(schedules);
    }

    provider.submit();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        title: const ScreenHeaderWidget(
          titlePrefix: 'Publica tu ',
          titleHighlight: 'residuo',
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Conecta con establecimientos que le dan valor a tu material',
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),

            AppCardContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NumberedStepTitle(
                    stepNumber: '1',
                    title: '¿Qué material quieres publicar?',
                    fontSize: 13,
                  ),
                  const SizedBox(height: 20),
                  _buildCategoryGrid(isTablet),

                  _divider(colors),

                  NumberedStepTitle(
                    stepNumber: '2',
                    title: 'Describe tu material',
                    fontSize: 13,
                  ),
                  const SizedBox(height: 16),
                  _buildDescriptionField(theme, textTheme),
                  const SizedBox(height: 16),
                  _buildPhotoSection(),

                  _divider(colors),

                  NumberedStepTitle(
                    stepNumber: '3',
                    title: '¿Cómo entregas?',
                    fontSize: 13,
                  ),
                  const SizedBox(height: 16),
                  _buildDeliveryOptions(isTablet),

                  Consumer<CreateWasteProvider>(
                    builder: (context, provider, _) {
                      if (provider.deliveryMode == 'home_delivery') {
                        return Column(
                          children: [
                            _divider(colors),
                            NumberedStepTitle(
                              stepNumber: '4',
                              title: 'Disponibilidad',
                              fontSize: 13,
                            ),
                            const SizedBox(height: 16),
                            OperatingHoursSelector(
                              singleDay: true,
                              singleRange: true,
                              onChanged: (days) => _daySchedules = days,
                            ),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  _divider(colors),

                  NumberedStepTitle(
                    stepNumber: '5',
                    title: 'Ubicación',
                    fontSize: 13,
                  ),
                  const SizedBox(height: 16),
                  LocationPreviewWidget(
                    location: _selectedLocation,
                    address: _selectedAddress,
                    onEdit: _openMapEditor,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Consumer<CreateWasteProvider>(
              builder: (context, provider, _) {
                return PrimaryButtonGreenWidget(
                  text: 'Publicar residuo',
                  isLoading: provider.status == CreateWasteStatus.loading,
                  onPressed: _onSubmit,
                );
              },
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _divider(ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Divider(height: 1, color: colors.outline.withValues(alpha: 0.7)),
    );
  }

  Widget _buildCategoryGrid(bool isTablet) {
    return Consumer<CreateWasteProvider>(
      builder: (context, provider, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final int columns = isTablet ? 4 : 3;
            const double spacing = 10.0;
            final double totalSpacing = spacing * (columns - 1);
            final double cardWidth = (constraints.maxWidth - totalSpacing) / columns;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: _categories.map((category) {
                final isSelected = provider.materialTypeId == category.id;
                return SizedBox(
                  width: cardWidth,
                  height: 110,
                  child: CategoryCardWidget(
                    title: category.title,
                    svgPath: category.svgPath,
                    icon: category.icon,
                    isSelected: isSelected,
                    onTap: () => provider.setMaterialTypeId(
                      isSelected ? null : category.id,
                    ),
                  ),
                );
              }).toList(),
            );
          },
        );
      },
    );
  }

  Widget _buildDescriptionField(ThemeData theme, TextTheme textTheme) {
    final colors = theme.colorScheme;

    return TextFormField(
      controller: _descriptionController,
      minLines: 1,
      maxLines: 3,
      maxLength: 200,
      style: textTheme.bodyMedium,
      decoration: InputDecoration(
        hintText: 'Describe tu material (ej. cajas de cartón un poco sucias)',
        hintStyle: textTheme.bodySmall?.copyWith(
          color: colors.onSurface.withValues(alpha: 0.4),
        ),
        prefixIcon: Icon(
          Icons.edit_outlined,
          color: colors.onSurface.withValues(alpha: 0.4),
          size: 20,
        ),
        counterText: '',
        contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.outline, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Consumer<CreateWasteProvider>(
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
                        border: Border.all(color: Theme.of(context).colorScheme.outline),
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
                          : Icon(Icons.add_a_photo_outlined,
                              color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildDeliveryOptions(bool isTablet) {
    return Consumer<CreateWasteProvider>(
      builder: (context, provider, _) {
        Widget pickup = SelectionCardWidget(
          title: 'Prefiero que pasen por él',
          svgPath: 'assets/icons/car.svg',
          isSelected: provider.deliveryMode == 'home_delivery',
          onTap: () => provider.setDeliveryMode('home_delivery'),
        );

        Widget deliver = SelectionCardWidget(
          title: 'Yo lo puedo llevar',
          svgPath: 'assets/icons/house.svg',
          isSelected: provider.deliveryMode == 'drop_off',
          onTap: () => provider.setDeliveryMode('drop_off'),
        );

        if (isTablet) {
          return Row(
            children: [
              Expanded(child: pickup),
              const SizedBox(width: 12),
              Expanded(child: deliver),
            ],
          );
        }

        return Column(
          children: [
            pickup,
            const SizedBox(height: 12),
            deliver,
          ],
        );
      },
    );
  }

  void _openMapEditor() async {
    final provider = context.read<MapProvider>();
    await provider.initializeLocation();
    if (!mounted) return;
    final place = provider.currentPlace;
    if (place != null) {
      setState(() {
        _selectedLocation = LatLng(place.latitude, place.longitude);
        _selectedAddress = '${place.street} ${place.streetNumber}, ${place.city}'.trim();
      });
      context.read<CreateWasteProvider>().setLocation(
            latitude: place.latitude,
            longitude: place.longitude,
            addressText: _selectedAddress!,
          );
    }
  }
}