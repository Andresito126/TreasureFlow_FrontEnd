import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:treasureflow/core/maps/presentation/providers/map_provider.dart';
import 'package:treasureflow/features/posts/waste/presentation/widgets/location_preview_widget.dart';
import 'package:treasureflow/shared/layouts/app_card_container.dart';
import 'package:treasureflow/shared/widgets/add_photo_card_widget.dart';
import 'package:treasureflow/shared/widgets/category_card_widget.dart';
import 'package:treasureflow/shared/widgets/condition_chip_widget.dart';
import 'package:treasureflow/shared/widgets/primary_button_green_widget.dart';
import 'package:treasureflow/shared/widgets/screen_header_widget.dart';
import 'package:treasureflow/shared/widgets/selection_card_widget.dart';

class _ObjectCategory {
  final String title;
  final IconData? icon;
  final String assetPath;
  const _ObjectCategory({
    required this.title,
    required this.assetPath,
    this.icon,
  });
}

class CreateObjectScreen extends StatefulWidget {
  const CreateObjectScreen({super.key});

  @override
  State<CreateObjectScreen> createState() => _CreateObjectScreenState();
}

class _CreateObjectScreenState extends State<CreateObjectScreen> {
  static final List<_ObjectCategory> _categories = [
    _ObjectCategory(
      title: 'Muebles',
      assetPath: 'assets/object/couch_icon.svg',
    ),
    const _ObjectCategory(
      title: 'Electrodomésticos',
      assetPath: "assets/object/refrigerator_icon.svg",
      icon: Icons.kitchen_outlined,
    ),
    const _ObjectCategory(
      title: 'Ropa',
      assetPath: "assets/object/clothes_icon.svg",
      icon: Icons.checkroom_outlined,
    ),
    const _ObjectCategory(
      title: 'Herramientas',
      assetPath: "assets/object/tools_icon.svg",
      icon: Icons.build_outlined,
    ),
    const _ObjectCategory(
      title: 'Electrónicos',
      assetPath: "assets/object/electronics_icon.svg",
      icon: Icons.devices_outlined,
    ),
    const _ObjectCategory(
      title: 'Otros',
      assetPath: "assets/object/others_icon.svg",
      icon: Icons.more_horiz,
    ),
  ];

  static const List<String> _conditions = [
    'Nuevo',
    'Como nuevo',
    'Buen estado',
    'Funcional con detalles',
    'Para reparar',
  ];

  String? _selectedCategory;
  String? _selectedCondition;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _otherCategoryController =
      TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  bool _hasCost = true;
  int _deliveryMode = -1;
  LatLng? _selectedLocation;
  String? _selectedAddress;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentLocation();
    });
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
    _nameController.dispose();
    _otherCategoryController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
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
          titleHighlight: 'objeto',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                text: 'Conecta con personas que le puedan ',
                style: textTheme.bodySmall?.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.6),
                ),
                children: [
                  TextSpan(
                    text: 'dar una segunda vida a tu objeto',
                    style: TextStyle(color: colors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            AppCardContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('1.Nombre de tu objeto', textTheme),
                  const SizedBox(height: 10),
                  _buildTextField(
                    controller: _nameController,
                    hint: 'Ej. Blusa color roja',
                    theme: theme,
                    prefixIcon: Icons.edit_outlined,
                  ),

                  const SizedBox(height: 20),

                  _sectionTitle('2.¿Qué tipo de objeto es?', textTheme),
                  const SizedBox(height: 10),
                  _buildCategoryGrid(isTablet),
                  if (_selectedCategory == 'Otros') ...[
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: _otherCategoryController,
                      hint: '¿Qué tipo de objeto es? (máx. 10 palabras)',
                      theme: theme,
                      prefixIcon: Icons.category_outlined,
                      inputFormatters: [
                        _NoNumbersFormatter(),
                        _MaxWordsFormatter(10),
                      ],
                    ),
                  ],

                  const SizedBox(height: 20),

                  _sectionTitle('3.¿Cómo está tu objeto?', textTheme),
                  const SizedBox(height: 10),
                  _buildConditionChips(),

                  const SizedBox(height: 20),

                  _sectionTitle('4.Cuéntanos más', textTheme),
                  const SizedBox(height: 10),
                  _buildTextField(
                    controller: _descriptionController,
                    hint:
                        'Ej. Blusa color roja como nueva, el detalle es que lo compré, pero no me quedó',
                    theme: theme,
                    minLines: 2,
                    maxLines: 4,
                  ),

                  const SizedBox(height: 20),

                  _sectionTitle('5.¿Tiene costo?', textTheme),
                  const SizedBox(height: 10),
                  _buildCostSection(theme, textTheme, colors),

                  const SizedBox(height: 20),

                  _sectionTitle('6.Agregar fotos', textTheme),
                  const SizedBox(height: 10),
                  _buildPhotoSection(),

                  const SizedBox(height: 20),

                  _sectionTitle('7.Ubicación de entrega', textTheme),
                  const SizedBox(height: 10),
                  LocationPreviewWidget(
                    location: _selectedLocation,
                    address: _selectedAddress,
                    onEdit: _loadCurrentLocation,
                  ),

                  const SizedBox(height: 20),

                  _sectionTitle('8.¿Cómo prefieres entregarlo?', textTheme),
                  const SizedBox(height: 10),
                  _buildDeliveryOptions(isTablet),
                ],
              ),
            ),

            const SizedBox(height: 24),

            PrimaryButtonGreenWidget(
              text: 'Publicar objeto',
              onPressed: _onSubmit,
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text, TextTheme textTheme) {
    return Text(
      text,
      style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required ThemeData theme,
    IconData? prefixIcon,
    int minLines = 1,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
  }) {
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return TextFormField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
      style: textTheme.bodySmall,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: textTheme.bodySmall?.copyWith(
          color: colors.onSurface.withValues(alpha: 0.4),
        ),
        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon,
                color: colors.onSurface.withValues(alpha: 0.4),
                size: 16,
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12.0,
          horizontal: 15.0,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: BorderSide(color: colors.outline, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
      ),
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
            final isSelected = _selectedCategory == category.title;
            return SizedBox(
              width: cardWidth,
              height: 110,
              child: CategoryCardWidget(
                title: category.title,
                svgPath: category.assetPath.isNotEmpty
                    ? category.assetPath
                    : null,
                icon: category.assetPath.isEmpty ? category.icon : null,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    _selectedCategory = isSelected ? null : category.title;
                    if (_selectedCategory != 'Otros') {
                      _otherCategoryController.clear();
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

  Widget _buildConditionChips() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _conditions.map((condition) {
        return ConditionChipWidget(
          label: condition,
          isSelected: _selectedCondition == condition,
          onTap: () {
            setState(() {
              _selectedCondition = _selectedCondition == condition
                  ? null
                  : condition;
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildCostSection(
    ThemeData theme,
    TextTheme textTheme,
    ColorScheme colors,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            border: Border.all(color: colors.outline),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Activa si quieres vender, desactívalo si es una donación',
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Switch(
                value: _hasCost,
                onChanged: (val) => setState(() => _hasCost = val),
                activeThumbColor: colors.onPrimary,
                activeTrackColor: colors.primary,
              ),
            ],
          ),
        ),
        if (_hasCost) ...[
          const SizedBox(height: 10),
          TextFormField(
            controller: _priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            style: textTheme.bodySmall,
            decoration: InputDecoration(
              hintText: '0.00',
              hintStyle: textTheme.bodySmall?.copyWith(
                color: colors.onSurface.withValues(alpha: 0.4),
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 15, right: 10),
                child: Text(
                  '\$',
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 0,
                minHeight: 0,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 15.0,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: BorderSide(color: colors.outline, width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: BorderSide(color: colors.primary, width: 1.5),
              ),
            ),
          ),
        ],
      ],
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
    Widget nearby = SelectionCardWidget(
      title: 'Puedo llevarlo',
      svgPath: 'assets/icons/car.svg',
      isSelected: _deliveryMode == 0,
      onTap: () => setState(() => _deliveryMode = 0),
    );

    Widget home = SelectionCardWidget(
      title: 'Solo en mi domicilio',
      svgPath: 'assets/icons/house.svg',
      isSelected: _deliveryMode == 1,
      onTap: () => setState(() => _deliveryMode = 1),
    );

    return Row(
      children: [
        Expanded(child: nearby),
        const SizedBox(width: 12),
        Expanded(child: home),
      ],
    );
  }

  void _onSubmit() {}
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
