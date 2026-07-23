import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:treasureflow/core/di/app_container.dart';
import 'package:treasureflow/core/maps/presentation/providers/map_provider.dart';
import 'package:treasureflow/core/maps/presentation/screens/location_picker_screen.dart';
import 'package:treasureflow/features/posts/waste/di/waste_post_module.dart';
import 'package:treasureflow/features/posts/waste/domain/entities/waste_post_detail.dart';
import 'package:treasureflow/features/posts/waste/presentation/providers/edit_waste_provider.dart';
import 'package:treasureflow/features/posts/waste/presentation/widgets/location_preview_widget.dart';
import 'package:treasureflow/shared/layouts/app_card_container.dart';
import 'package:treasureflow/shared/widgets/app_toast.dart';
import 'package:treasureflow/shared/widgets/category_card_widget.dart';
import 'package:treasureflow/shared/widgets/numbered_step_title.dart';
import 'package:treasureflow/shared/widgets/primary_button_green_widget.dart';
import 'package:treasureflow/shared/widgets/screen_header_widget.dart';
import 'package:treasureflow/shared/widgets/selection_card_widget.dart';

class _CategoryItem {
  final String id;
  final String title;
  final String? svgPath;
  const _CategoryItem({required this.id, required this.title, this.svgPath});
}

class EditWasteScreen extends StatefulWidget {
  final String postId;

  const EditWasteScreen({super.key, required this.postId});

  @override
  State<EditWasteScreen> createState() => _EditWasteScreenState();
}

class _EditWasteScreenState extends State<EditWasteScreen> {
  static const List<_CategoryItem> _categories = [
    _CategoryItem(id: 'e78a20e5-a69d-4edb-bf50-33831f9aae6e', title: 'Aluminio', svgPath: 'assets/icons/aluminum.svg'),
    _CategoryItem(id: '2e532ca8-c6de-465d-af27-c2465b74f14c', title: 'Aceite', svgPath: 'assets/icons/oil.svg'),
    _CategoryItem(id: '1be3bf83-8b1a-421c-8474-a72785bf80b5', title: 'Papel/Cartón', svgPath: 'assets/icons/cardboard.svg'),
    _CategoryItem(id: 'caa8cf7a-d5f6-4ae6-a9aa-ea92bdf4b334', title: 'Plástico', svgPath: 'assets/icons/plastic.svg'),
    _CategoryItem(id: '918a523e-655b-4f53-bd86-2d43c2618be5', title: 'Metal', svgPath: 'assets/icons/metal.svg'),
    _CategoryItem(id: '37962e6b-8f0a-4dd7-9e5d-0db74d021313', title: 'Pila/Batería', svgPath: 'assets/icons/battery.svg'),
  ];

  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  late final EditWasteProvider _provider;
  late final WastePostModule _module;

  bool _initializing = true;
  String? _initError;

  LatLng? _selectedLocation;
  String? _selectedAddress;

  @override
  void initState() {
    super.initState();
    final container = context.read<AppContainer>();
    _module = WastePostModule(container);
    _provider = _module.provideEditWasteProvider();
    _provider.addListener(_onProviderChanged);
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      final detail = await _module.provideGetDetailUseCase()(widget.postId);
      if (!mounted) return;
      _initFromDetail(detail);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _initError = 'No se pudo cargar la publicación';
        _initializing = false;
      });
    }
  }

  void _initFromDetail(WastePostDetail detail) {
    _provider.initializeFromDetail(detail);
    _descriptionController.text = detail.description;

    if (detail.latitude != null && detail.longitude != null) {
      _selectedLocation = LatLng(detail.latitude!, detail.longitude!);
    }
    _selectedAddress = detail.addressText;

    setState(() => _initializing = false);
  }

  void _onProviderChanged() {
    if (_provider.status == EditWasteStatus.success) {
      AppToast.show(context, 'Publicación actualizada', type: ToastType.success);
      context.pop();
    }
    if (_provider.status == EditWasteStatus.error) {
      AppToast.show(
        context,
        _provider.errorMessage ?? 'Error al actualizar',
        type: ToastType.error,
      );
    }
    if (mounted) setState(() {});
  }

  Future<void> _pickPhoto() async {
    if (_provider.photos.length >= 3) return;
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

  void _onSubmit() {
    _provider.setDescription(_descriptionController.text);
    _provider.submit(widget.postId);
  }

  @override
  void dispose() {
    _provider.removeListener(_onProviderChanged);
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    if (_initializing) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_initError != null) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: Center(
          child: Text(_initError!, style: textTheme.bodyMedium),
        ),
      );
    }

    final isTablet = MediaQuery.sizeOf(context).width > 600;

    return ChangeNotifierProvider<EditWasteProvider>.value(
      value: _provider,
      child: Scaffold(
        appBar: _buildAppBar(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Modifica los campos que desees actualizar',
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 24),

              AppCardContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NumberedStepTitle(stepNumber: '1', title: '¿Qué material quieres publicar?', fontSize: 13),
                    const SizedBox(height: 20),
                    _buildCategoryGrid(isTablet),

                    _divider(colors),

                    NumberedStepTitle(stepNumber: '2', title: 'Describe tu material', fontSize: 13),
                    const SizedBox(height: 16),
                    _buildDescriptionField(theme, textTheme),
                    const SizedBox(height: 16),
                    _buildPhotoSection(),

                    _divider(colors),

                    NumberedStepTitle(stepNumber: '3', title: '¿Cómo entregas?', fontSize: 13),
                    const SizedBox(height: 16),
                    _buildDeliveryOptions(isTablet),

                    _divider(colors),

                    NumberedStepTitle(stepNumber: '4', title: 'Ubicación', fontSize: 13),
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

              Consumer<EditWasteProvider>(
                builder: (context, provider, _) => PrimaryButtonGreenWidget(
                  text: 'Guardar cambios',
                  isLoading: provider.status == EditWasteStatus.loading,
                  onPressed: _onSubmit,
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      title: const ScreenHeaderWidget(
        titlePrefix: 'Editar ',
        titleHighlight: 'publicación',
      ),
      centerTitle: false,
    );
  }

  Widget _divider(ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Divider(height: 1, color: colors.outline.withValues(alpha: 0.7)),
    );
  }

  Widget _buildCategoryGrid(bool isTablet) {
    return Consumer<EditWasteProvider>(
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
                    isSelected: isSelected,
                    onTap: () => provider.setMaterialTypeId(isSelected ? null : category.id),
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
        hintStyle: textTheme.bodySmall?.copyWith(color: colors.onSurface.withValues(alpha: 0.4)),
        prefixIcon: Icon(Icons.edit_outlined, color: colors.onSurface.withValues(alpha: 0.4), size: 20),
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
    return Consumer<EditWasteProvider>(
      builder: (context, provider, _) {
        final colors = Theme.of(context).colorScheme;
        return Row(
          children: List.generate(3, (index) {
            final hasSlot = index < provider.photos.length;
            final slot = hasSlot ? provider.photos[index] : null;

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: index > 0 ? 6 : 0,
                  right: index < 2 ? 6 : 0,
                ),
                child: GestureDetector(
                  onTap: hasSlot ? () => provider.removePhoto(index) : _pickPhoto,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colors.outline),
                        image: hasSlot
                            ? DecorationImage(
                                image: slot!.isExisting
                                    ? NetworkImage(slot.url!) as ImageProvider
                                    : FileImage(slot.file!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: hasSlot
                          ? Align(
                              alignment: Alignment.topRight,
                              child: Container(
                                margin: const EdgeInsets.all(4),
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
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
        );
      },
    );
  }

  Widget _buildDeliveryOptions(bool isTablet) {
    return Consumer<EditWasteProvider>(
      builder: (context, provider, _) {
        final pickup = SelectionCardWidget(
          title: 'Prefiero que pasen por él',
          svgPath: 'assets/icons/car.svg',
          isSelected: provider.deliveryMode == 'home_delivery',
          onTap: () => provider.setDeliveryMode('home_delivery'),
        );
        final deliver = SelectionCardWidget(
          title: 'Yo lo puedo llevar',
          svgPath: 'assets/icons/house.svg',
          isSelected: provider.deliveryMode == 'drop_off',
          onTap: () => provider.setDeliveryMode('drop_off'),
        );

        if (isTablet) {
          return Row(children: [Expanded(child: pickup), const SizedBox(width: 12), Expanded(child: deliver)]);
        }
        return Column(children: [pickup, const SizedBox(height: 12), deliver]);
      },
    );
  }

  void _openMapEditor() async {
    final result = await Navigator.of(context).push<LocationPickerResult>(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: context.read<MapProvider>(),
          child: LocationPickerScreen(initialLocation: _selectedLocation),
        ),
        fullscreenDialog: true,
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      _selectedLocation = result.latLng;
      _selectedAddress = result.address;
    });
    _provider.setLocation(
      latitude: result.latLng.latitude,
      longitude: result.latLng.longitude,
      addressText: result.address,
    );
  }
}
