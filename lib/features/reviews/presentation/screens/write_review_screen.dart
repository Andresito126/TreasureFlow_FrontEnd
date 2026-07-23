import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:treasureflow/core/di/app_container.dart';
import 'package:treasureflow/features/reviews/di/reviews_module.dart';
import 'package:treasureflow/features/reviews/presentation/providers/submit_review_provider.dart';
import 'package:treasureflow/shared/widgets/app_toast.dart';
import 'package:treasureflow/shared/widgets/primary_button_blue_widget.dart';

/// Acepta [collectionId] (conocido de antemano — salta la carga de
/// elegibilidad) o [establishmentId] (carga las compras completadas sin
/// reseñar con ese local y, si hay más de una, deja elegir cuál).
class WriteReviewScreen extends StatefulWidget {
  final String? collectionId;
  final String? establishmentId;

  const WriteReviewScreen({super.key, this.collectionId, this.establishmentId})
    : assert(
        collectionId != null || establishmentId != null,
        'Se requiere collectionId o establishmentId',
      );

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  late final SubmitReviewProvider _provider;
  final _commentController = TextEditingController();

  int _rating = 0;
  String? _selectedCollectionId;

  @override
  void initState() {
    super.initState();
    final container = context.read<AppContainer>();
    _provider = ReviewsModule(container).provideSubmitReviewProvider();
    _provider.addListener(_onProviderChanged);

    _selectedCollectionId = widget.collectionId;
    if (_selectedCollectionId == null && widget.establishmentId != null) {
      _provider.loadEligibility(widget.establishmentId!);
    }
  }

  @override
  void dispose() {
    _provider.removeListener(_onProviderChanged);
    _provider.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _onProviderChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _onSubmit() async {
    if (_rating == 0 || _selectedCollectionId == null) return;

    final success = await _provider.submit(
      collectionId: _selectedCollectionId!,
      rating: _rating,
      comment: _commentController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      AppToast.show(context, '¡Gracias por tu reseña!', type: ToastType.success);
      Navigator.of(context).pop(true);
    } else {
      AppToast.show(
        context,
        _provider.submitError ?? 'No se pudo enviar tu reseña',
        type: ToastType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  BackButton(color: colors.primary),
                  const SizedBox(width: 4),
                  Text(
                    'Dejar reseña',
                    style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(child: _buildBody(colors, textTheme)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(ColorScheme colors, TextTheme textTheme) {
    if (widget.collectionId == null) {
      if (_provider.eligibilityStatus == EligibilityStatus.loading ||
          _provider.eligibilityStatus == EligibilityStatus.idle) {
        return const Center(child: CircularProgressIndicator());
      }
      if (_provider.eligibilityStatus == EligibilityStatus.error) {
        return Center(
          child: Text(
            _provider.eligibilityError ?? 'No se pudo cargar tus compras',
            style: textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        );
      }
      if (_provider.eligibleCollections.isEmpty) {
        return Center(
          child: Text(
            'No tienes compras completadas sin reseñar con este local',
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        );
      }
    }

    if (widget.collectionId == null && _provider.eligibleCollections.length == 1) {
      _selectedCollectionId ??= _provider.eligibleCollections.first.collectionId;
    }

    return ListView(
      children: [
        if (widget.collectionId == null && _provider.eligibleCollections.length > 1) ...[
          Text(
            '¿Qué compra quieres reseñar?',
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ..._provider.eligibleCollections.map(
            (c) => RadioListTile<String>(
              value: c.collectionId,
              groupValue: _selectedCollectionId,
              title: Text(c.wasteTitle),
              onChanged: (value) => setState(() => _selectedCollectionId = value),
            ),
          ),
          const SizedBox(height: 16),
        ],
        Text(
          '¿Cómo calificarías tu experiencia?',
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (i) {
            final starValue = i + 1;
            return IconButton(
              onPressed: () => setState(() => _rating = starValue),
              icon: Icon(
                starValue <= _rating ? Icons.star : Icons.star_border,
                color: const Color(0xFFF5A623),
                size: 36,
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
        Text(
          'Comentario (opcional)',
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _commentController,
          maxLines: 4,
          maxLength: 500,
          decoration: InputDecoration(
            hintText: 'Cuéntanos cómo te fue...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),
        PrimaryButtonBlueWidget(
          text: 'Enviar reseña',
          isLoading: _provider.isSubmitting,
          onPressed: _rating > 0 && _selectedCollectionId != null ? _onSubmit : null,
        ),
      ],
    );
  }
}
