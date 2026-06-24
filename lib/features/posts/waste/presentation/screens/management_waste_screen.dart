import 'package:flutter/material.dart';
import 'package:treasureflow/shared/widgets/add_photo_card_widget.dart';
import 'package:treasureflow/shared/widgets/category_card_widget.dart';
import 'package:treasureflow/shared/widgets/numbered_step_title.dart';
import 'package:treasureflow/shared/widgets/selection_card_widget.dart';

/// Estructura de datos para mantener limpias las categorías
class _CategoryItem {
  final String title;
  final String svgPath;
  const _CategoryItem({required this.title, required this.svgPath});
}

class ManagementWasteScreen extends StatelessWidget {
  const ManagementWasteScreen({super.key});

  static const List<_CategoryItem> _categories = [
    _CategoryItem(title: 'Aluminio', svgPath: 'assets/icons/aluminum.svg'),
    _CategoryItem(title: 'Aceite', svgPath: 'assets/icons/oil.svg'),
    _CategoryItem(title: 'Papel/Cartón', svgPath: 'assets/icons/cardboard.svg'),
    _CategoryItem(title: 'Plástico', svgPath: 'assets/icons/plastic.svg'),
    _CategoryItem(title: 'Metal', svgPath: 'assets/icons/metal.svg'),
    _CategoryItem(title: 'Pila/Batería', svgPath: 'assets/icons/battery.svg'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTabletOrLandscape = screenWidth > 600;

    // Función responsiva para fuentes
    double resFont(double baseSize) {
      return (baseSize * (screenWidth / 390)).clamp(baseSize, baseSize * 1.3);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.background,
        elevation: 0,
        leading: IconButton(
          color: theme.colorScheme.onSurface,
          onPressed: () {},
          icon: const Icon(Icons.arrow_back_ios, size: 25),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme, resFont),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 24.0,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: theme.colorScheme.surface,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NumberedStepTitle(
                      stepNumber: '1',
                      title: '¿Qué material quieres publicar?',
                      fontSize: resFont(13),
                    ),
                    const SizedBox(height: 20),
                    _buildCategoryGrid(isTabletOrLandscape),
                    const SizedBox(height: 24),

                    NumberedStepTitle(
                      stepNumber: '2',
                      title: 'Describe tu material',
                      fontSize: resFont(13),
                    ),
                    const SizedBox(height: 16),
                    _buildDescriptionField(theme, resFont),
                    const SizedBox(height: 16),
                    _buildPhotoSection(),
                    const SizedBox(height: 24),

                    NumberedStepTitle(
                      stepNumber: '3',
                      title: '¿Cómo y cuándo entregas',
                      fontSize: resFont(13),
                    ),
                    const SizedBox(height: 16),
                    _buildDeliveryOptions(isTabletOrLandscape),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  /// Encabezado e introduccion de la pantalla
  Widget _buildHeader(ThemeData theme, double Function(double) resFont) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: 'Publica tu ',
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: resFont(25),
              fontWeight: FontWeight.bold,
            ),
            children: [
              TextSpan(
                text: 'residuo',
                style: TextStyle(color: theme.colorScheme.primary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Conecta con establecimientos que le dan valor a tu material',
          style: TextStyle(fontSize: resFont(15), color: Colors.grey),
        ),
      ],
    );
  }

  /// Grid adaptativo con wrap para las categorías
  Widget _buildCategoryGrid(bool isTablet) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final int columns = isTablet ? 4 : 3;
        const double spacing = 10.0;
        final double totalSpacing = spacing * (columns - 1);
        final double exactCardWidth =
            (constraints.maxWidth - totalSpacing) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: _categories.map((category) {
            return SizedBox(
              width: exactCardWidth,
              height: 110,
              child: CategoryCardWidget(
                title: category.title,
                svgPath: category.svgPath,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // esto es auxiliar jeje
  Widget _buildDescriptionField(
    ThemeData theme,
    double Function(double) resFont,
  ) {
    return TextFormField(
      minLines: 1,
      maxLines: 3,
      style: TextStyle(fontSize: resFont(14)),
      decoration: InputDecoration(
        hintText: 'Describe tu material (ej. cajas de cartón un poco sucias)',
        hintStyle: TextStyle(
          color: Colors.grey,
          fontSize: resFont(14),
          fontWeight: FontWeight.normal,
        ),
        prefixIcon: const Icon(
          Icons.edit_outlined,
          color: Colors.grey,
          size: 20,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 16.0,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.outline, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
        ),
      ),
    );
  }

  /// Sección horizontal para añadir fotografías
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

  /// Manejo de la disposición responsiva de las tarjetas de entrega
  Widget _buildDeliveryOptions(bool isTabletOrLandscape) {
    if (isTabletOrLandscape) {
      return Row(
        children: [
          const Expanded(
            flex: 1,
            child: SelectionCardWidget(
              title: 'Prefieren que pasen por él',
              svgPath: 'assets/icons/car.svg',
              isSelected: true,
            ),
          ),
          const SelectionCardSpacer(),
          const Expanded(
            flex: 1,
            child: SelectionCardWidget(
              title: 'Yo lo puedo llevar',
              svgPath: 'assets/icons/house.svg',
              isSelected: false,
            ),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          const SelectionCardWidget(
            title: 'Prefieren que pasen por él',
            svgPath: 'assets/icons/car.svg',
            isSelected: true,
          ),
          const SizedBox(height: 12),
          const SelectionCardWidget(
            title: 'Yo lo puedo llevar',
            svgPath: 'assets/icons/house.svg',
            isSelected: false,
          ),
        ],
      );
    }
  }
}

class SelectionCardSpacer extends StatelessWidget {
  const SelectionCardSpacer({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.sizeOf(context).width > 600;
    return isTablet ? const SizedBox(width: 12) : const SizedBox(height: 12);
  }
}
