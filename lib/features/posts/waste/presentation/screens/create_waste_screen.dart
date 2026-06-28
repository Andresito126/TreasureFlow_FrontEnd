import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:treasureflow/core/maps/presentation/providers/map_provider.dart';
import 'package:treasureflow/features/auth/local/presentation/widgets/operating_hours_selector.dart';
import 'package:treasureflow/features/posts/waste/presentation/widgets/location_preview_widget.dart';
import 'package:treasureflow/shared/layouts/app_card_container.dart';
import 'package:treasureflow/shared/widgets/add_photo_card_widget.dart';
import 'package:treasureflow/shared/widgets/category_card_widget.dart';
import 'package:treasureflow/shared/widgets/numbered_step_title.dart';
import 'package:treasureflow/shared/widgets/primary_button_green_widget.dart';
import 'package:treasureflow/shared/widgets/screen_header_widget.dart';
import 'package:treasureflow/shared/widgets/selection_card_widget.dart';

class _CategoryItem {
  final String title;
  final String? svgPath;
  final IconData? icon;
  const _CategoryItem({required this.title, this.svgPath, this.icon});
}

class CreateWasteScreen extends StatefulWidget {
  const CreateWasteScreen({super.key});

  @override
  State<CreateWasteScreen> createState() => _CreateWasteScreenState();
}

class _CreateWasteScreenState extends State<CreateWasteScreen> {
  static const List<_CategoryItem> _categories = [
    _CategoryItem(title: 'Aluminio', svgPath: 'assets/icons/aluminum.svg'),
    _CategoryItem(title: 'Aceite', svgPath: 'assets/icons/oil.svg'),
    _CategoryItem(title: 'Papel/Cartón', svgPath: 'assets/icons/cardboard.svg'),
    _CategoryItem(title: 'Plástico', svgPath: 'assets/icons/plastic.svg'),
    _CategoryItem(title: 'Metal', svgPath: 'assets/icons/metal.svg'),
    _CategoryItem(title: 'Pila/Batería', svgPath: 'assets/icons/battery.svg'),
    _CategoryItem(title: 'Otro', icon: Icons.more_horiz),
  ];

  String? _selectedMaterial;
  final TextEditingController _otherMaterialController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  int _deliveryMode = -1;
  LatLng? _selectedLocation;
  String? _selectedAddress;

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
  }

  Future<void> _loadCurrentLocation() async {
    final provider = context.read<MapProvider>();
    await provider.initializeLocation();
    if (!mounted) return;
    final place = provider.currentPlace;
    if (place != null) {
      setState(() {
        _selectedLocation = LatLng(place.latitude, place.longitude);
        _selectedAddress = place.fullAddress;
      });
    }
  }

  @override
  void dispose() {
    _otherMaterialController.dispose();
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
                  //  material 
                  NumberedStepTitle(
                    stepNumber: '1',
                    title: '¿Qué material quieres publicar?',
                    fontSize: 13,
                  ),
                  const SizedBox(height: 20),
                  _buildCategoryGrid(isTablet),
                  if (_selectedMaterial == 'Otro') ...[
                    const SizedBox(height: 16),
                    _buildOtherMaterialField(theme, textTheme),
                  ],

                  _divider(colors),

                  //  Desc y las fotos 
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

                  // entrega 
                  NumberedStepTitle(
                    stepNumber: '3',
                    title: '¿Cómo entregas?',
                    fontSize: 13,
                  ),
                  const SizedBox(height: 16),
                  _buildDeliveryOptions(isTablet),

                  _divider(colors),

                  //  dispo 
                  NumberedStepTitle(
                    stepNumber: '4',
                    title: 'Disponibilidad',
                    fontSize: 13,
                  ),
                  const SizedBox(height: 16),
                  const OperatingHoursSelector(
                    singleDay: true,
                    singleRange: true,
                  ),

                  _divider(colors),

                  //  ubi 
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

            PrimaryButtonGreenWidget(
              text: 'Publicar residuo',
              onPressed: _onSubmit,
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final int columns = isTablet ? 4 : 3;
        const double spacing = 10.0;
        final double totalSpacing = spacing * (columns - 1);
        final double cardWidth =
            (constraints.maxWidth - totalSpacing) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: _categories.map((category) {
            final isSelected = _selectedMaterial == category.title;
            return SizedBox(
              width: cardWidth,
              height: 110,
              child: CategoryCardWidget(
                title: category.title,
                svgPath: category.svgPath,
                icon: category.icon,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    _selectedMaterial =
                        isSelected ? null : category.title;
                    if (_selectedMaterial != 'Otro') {
                      _otherMaterialController.clear();
                    }
                  });
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildOtherMaterialField(ThemeData theme, TextTheme textTheme) {
    final colors = theme.colorScheme;

    return TextFormField(
      controller: _otherMaterialController,
      style: textTheme.bodyMedium,
      maxLength: 50,
      inputFormatters: [
        _NoNumbersFormatter(),
        _MaxWordsFormatter(10),
      ],
      decoration: InputDecoration(
        hintText: '¿Qué material es? (máx. 10 palabras)',
        hintStyle: textTheme.bodySmall?.copyWith(
          color: colors.onSurface.withValues(alpha: 0.4),
        ),
        prefixIcon: Icon(
          Icons.category_outlined,
          color: colors.onSurface.withValues(alpha: 0.4),
          size: 20,
        ),
        counterText: '',
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 16.0,
        ),
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

  Widget _buildDescriptionField(ThemeData theme, TextTheme textTheme) {
    final colors = theme.colorScheme;

    return TextFormField(
      controller: _descriptionController,
      minLines: 1,
      maxLines: 3,
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
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 16.0,
        ),
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
    return const Row(
      children: [
        Expanded(child: AddPhotoCardWidget()),
        SizedBox(width: 12),
        Expanded(child: AddPhotoCardWidget()),
        SizedBox(width: 12),
        Expanded(child: AddPhotoCardWidget()),
      ],
    );
  }

  Widget _buildDeliveryOptions(bool isTablet) {
    Widget pickup = SelectionCardWidget(
      title: 'Prefiero que pasen por él',
      svgPath: 'assets/icons/car.svg',
      isSelected: _deliveryMode == 0,
      onTap: () => setState(() => _deliveryMode = 0),
    );

    Widget deliver = SelectionCardWidget(
      title: 'Yo lo puedo llevar',
      svgPath: 'assets/icons/house.svg',
      isSelected: _deliveryMode == 1,
      onTap: () => setState(() => _deliveryMode = 1),
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
  }

  void _openMapEditor() async {
    final provider = context.read<MapProvider>();
    await provider.initializeLocation();
    if (!mounted) return;
    final place = provider.currentPlace;
    if (place != null) {
      setState(() {
        _selectedLocation = LatLng(place.latitude, place.longitude);
        _selectedAddress = place.fullAddress;
      });
    }
  }

  void _onSubmit() {
    context.push('/createObject');
  }
}

class _NoNumbersFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final filtered = newValue.text.replaceAll(RegExp(r'[0-9]'), '');
    if (filtered == newValue.text) return newValue;
    return TextEditingValue(
      text: filtered,
      selection: TextSelection.collapsed(offset: filtered.length),
    );
  }
}

class _MaxWordsFormatter extends TextInputFormatter {
  final int maxWords;
  const _MaxWordsFormatter(this.maxWords);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final words = newValue.text.trim().split(RegExp(r'\s+'));
    if (newValue.text.trim().isEmpty || words.length <= maxWords) {
      return newValue;
    }
    return oldValue;
  }
}
