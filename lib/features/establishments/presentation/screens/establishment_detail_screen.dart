import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:treasureflow/core/auth/user_role.dart';
import 'package:treasureflow/core/di/app_container.dart';
import 'package:treasureflow/features/establishments/di/establishments_module.dart';
import 'package:treasureflow/features/establishments/domain/entities/establishment_detail.dart';
import 'package:treasureflow/features/establishments/presentation/providers/establishment_detail_provider.dart';
import 'package:treasureflow/features/reviews/di/reviews_module.dart';
import 'package:treasureflow/features/reviews/domain/entities/review.dart';
import 'package:treasureflow/features/reviews/presentation/providers/establishment_reviews_provider.dart';
import 'package:treasureflow/features/reviews/presentation/providers/submit_review_provider.dart';
import 'package:treasureflow/features/reviews/presentation/widgets/review_item_widget.dart';
import 'package:treasureflow/shared/widgets/primary_button_blue_widget.dart';

const _dayOrder = [1, 2, 3, 4, 5, 6, 7];
const _dayLabels = {
  1: 'Lunes',
  2: 'Martes',
  3: 'Miércoles',
  4: 'Jueves',
  5: 'Viernes',
  6: 'Sábado',
  7: 'Domingo',
};

class EstablishmentDetailScreen extends StatefulWidget {
  final String establishmentId;

  const EstablishmentDetailScreen({super.key, required this.establishmentId});

  @override
  State<EstablishmentDetailScreen> createState() =>
      _EstablishmentDetailScreenState();
}

class _EstablishmentDetailScreenState extends State<EstablishmentDetailScreen> {
  late final EstablishmentDetailProvider _provider;
  late final EstablishmentReviewsProvider _reviewsProvider;
  late final SubmitReviewProvider _submitReviewProvider;

  int _selectedTab = 0;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    final container = context.read<AppContainer>();
    _provider = EstablishmentsModule(container).provideDetailProvider();
    _provider.addListener(_onProviderChanged);
    _provider.load(widget.establishmentId);

    final reviewsModule = ReviewsModule(container);
    _reviewsProvider = reviewsModule.provideReviewsProvider(
      establishmentId: widget.establishmentId,
    );
    _reviewsProvider.addListener(_onProviderChanged);
    _reviewsProvider.load();

    _submitReviewProvider = reviewsModule.provideSubmitReviewProvider();
    _submitReviewProvider.addListener(_onProviderChanged);
    if (context.isCitizen) {
      _submitReviewProvider.loadEligibility(widget.establishmentId);
      container.userStorage.getUserId().then((id) {
        if (mounted) setState(() => _currentUserId = id);
      });
    }
  }

  @override
  void dispose() {
    _provider.removeListener(_onProviderChanged);
    _provider.dispose();
    _reviewsProvider.removeListener(_onProviderChanged);
    _reviewsProvider.dispose();
    _submitReviewProvider.removeListener(_onProviderChanged);
    _submitReviewProvider.dispose();
    super.dispose();
  }

  void _onProviderChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppBar(colors, textTheme),
            Expanded(child: _buildBody(colors, textTheme)),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(ColorScheme colors, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colors.outline.withValues(alpha: 0.3)),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: colors.primary,
              child: Icon(Icons.arrow_back, size: 18, color: colors.onPrimary),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              _provider.detail?.storeName ?? 'Establecimiento',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ColorScheme colors, TextTheme textTheme) {
    switch (_provider.status) {
      case EstablishmentDetailStatus.loading:
      case EstablishmentDetailStatus.idle:
        return const Center(child: CircularProgressIndicator());
      case EstablishmentDetailStatus.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: colors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  _provider.errorMessage ??
                      'No se pudo cargar el establecimiento',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                PrimaryButtonBlueWidget(
                  text: 'Reintentar',
                  onPressed: () => _provider.load(widget.establishmentId),
                ),
              ],
            ),
          ),
        );
      case EstablishmentDetailStatus.success:
        return _buildDetail(_provider.detail!, colors, textTheme);
    }
  }

  Widget _buildDetail(
    EstablishmentDetail detail,
    ColorScheme colors,
    TextTheme textTheme,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroImage(detail, colors, textTheme),
          const SizedBox(height: 16),
          _buildSegmentedControl(colors, textTheme),
          const SizedBox(height: 16),
          if (_selectedTab == 0) ...[
            _buildContactCard(detail, colors, textTheme),
            const SizedBox(height: 16),
            _buildScheduleCard(detail, colors, textTheme),
            const SizedBox(height: 16),
            _buildMaterialsCard(detail, colors, textTheme),
          ] else
            _buildReviewsTab(colors, textTheme),
        ],
      ),
    );
  }

  Widget _buildHeroImage(
    EstablishmentDetail detail,
    ColorScheme colors,
    TextTheme textTheme,
  ) {
    final imageUrl = detail.photoUrls.isNotEmpty
        ? detail.photoUrls.first
        : detail.profilePictureUrl;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 192,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl != null)
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    Container(color: colors.primary.withValues(alpha: 0.15)),
              )
            else
              Container(
                color: colors.primary.withValues(alpha: 0.15),
                child: Icon(
                  Icons.storefront_rounded,
                  size: 56,
                  color: colors.primary,
                ),
              ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.15),
                    Colors.black.withValues(alpha: 0.55),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 12,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          detail.storeName,
                          style: textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          detail.isOpen ? 'Abierto ahora' : 'Cerrado ahora',
                          style: textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star,
                          size: 14,
                          color: Color(0xFFF5A623),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          detail.averageRating.toStringAsFixed(1),
                          style: textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentedControl(ColorScheme colors, TextTheme textTheme) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.outline.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(child: _segmentedTab('Información', 0, colors, textTheme)),
          Expanded(child: _segmentedTab('Reseñas', 1, colors, textTheme)),
        ],
      ),
    );
  }

  Widget _segmentedTab(
    String label,
    int index,
    ColorScheme colors,
    TextTheme textTheme,
  ) {
    final isSelected = _selectedTab == index;
    return InkWell(
      borderRadius: BorderRadius.circular(11),
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary : null,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Center(
          child: Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: isSelected
                  ? colors.onPrimary
                  : colors.onSurface.withValues(alpha: 0.5),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReviewsTab(ColorScheme colors, TextTheme textTheme) {
    final canReview =
        context.isCitizen && _submitReviewProvider.eligibleCollections.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (canReview) ...[
          PrimaryButtonBlueWidget(
            text: 'Dejar reseña',
            onPressed: () async {
              final result = await context.push<bool>(
                '/writeReview',
                extra: {'establishmentId': widget.establishmentId},
              );
              if (result == true) {
                _reviewsProvider.load();
                _submitReviewProvider.loadEligibility(widget.establishmentId);
              }
            },
          ),
          const SizedBox(height: 16),
        ],
        _buildReviewsList(colors, textTheme),
      ],
    );
  }

  Widget _buildReviewsList(ColorScheme colors, TextTheme textTheme) {
    if (_reviewsProvider.status == ReviewsListStatus.loading ||
        _reviewsProvider.status == ReviewsListStatus.idle) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_reviewsProvider.status == ReviewsListStatus.error) {
      return Text(
        _reviewsProvider.errorMessage ?? 'No se pudieron cargar las reseñas',
        style: textTheme.bodyMedium,
      );
    }

    if (_reviewsProvider.items.isEmpty) {
      return Text(
        'Este establecimiento aún no tiene reseñas',
        style: textTheme.bodySmall?.copyWith(
          color: colors.onSurface.withValues(alpha: 0.5),
        ),
      );
    }

    return Column(
      children: _reviewsProvider.items
          .map(
            (review) => ReviewItemWidget(
              review: review,
              isOwn: _currentUserId != null && review.citizenId == _currentUserId,
              onEdit: () => _showEditReviewDialog(review),
              onDelete: () => _confirmDeleteReview(review),
            ),
          )
          .toList(),
    );
  }

  Future<void> _showEditReviewDialog(Review review) async {
    int rating = review.rating;
    final commentController = TextEditingController(text: review.comment ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Editar reseña'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      final starValue = i + 1;
                      return IconButton(
                        onPressed: () => setDialogState(() => rating = starValue),
                        icon: Icon(
                          starValue <= rating ? Icons.star : Icons.star_border,
                          color: const Color(0xFFF5A623),
                        ),
                      );
                    }),
                  ),
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    maxLength: 500,
                    decoration: const InputDecoration(hintText: 'Comentario (opcional)'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true) {
      await _reviewsProvider.updateReview(
        reviewId: review.id,
        rating: rating,
        comment: commentController.text.trim(),
      );
    }
  }

  Future<void> _confirmDeleteReview(Review review) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar reseña'),
        content: const Text('¿Seguro que quieres eliminar tu reseña? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _reviewsProvider.deleteReview(review.id);
    }
  }

  Widget _buildContactCard(
    EstablishmentDetail detail,
    ColorScheme colors,
    TextTheme textTheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 20, color: colors.primary),
              const SizedBox(width: 8),
              Text(
                'Contacto y ubicación',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _contactColumn(
                    icon: Icons.location_on_outlined,
                    label: 'Dirección',
                    value: detail.addressText ?? 'Sin registrar',
                    colors: colors,
                    textTheme: textTheme,
                  ),
                ),
                VerticalDivider(color: colors.outline.withValues(alpha: 0.2)),
                Expanded(
                  child: _contactColumn(
                    icon: Icons.phone_outlined,
                    label: 'Teléfono',
                    value: detail.phone,
                    colors: colors,
                    textTheme: textTheme,
                  ),
                ),
                VerticalDivider(color: colors.outline.withValues(alpha: 0.2)),
                Expanded(
                  child: _contactColumn(
                    icon: Icons.local_shipping_outlined,
                    label: 'Transporte',
                    value: null,
                    badgeText: detail.hasVehicle
                        ? 'Disponible'
                        : 'No disponible',
                    badgeColor: detail.hasVehicle
                        ? colors.primary
                        : colors.error,
                    colors: colors,
                    textTheme: textTheme,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactColumn({
    required IconData icon,
    required String label,
    required String? value,
    String? badgeText,
    Color? badgeColor,
    required ColorScheme colors,
    required TextTheme textTheme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: colors.primary),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          if (badgeText != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badgeText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            Text(
              value ?? '',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(
                fontSize: 10,
                color: colors.onSurface.withValues(alpha: 0.6),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(
    EstablishmentDetail detail,
    ColorScheme colors,
    TextTheme textTheme,
  ) {
    final byDay = <int, List<EstablishmentDetailSchedule>>{};
    for (final s in detail.schedules) {
      (byDay[s.dayOfWeek] ??= []).add(s);
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.access_time, size: 20, color: colors.primary),
              const SizedBox(width: 8),
              Text(
                'Horarios de atención',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final day in _dayOrder)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: colors.outline.withValues(alpha: 0.15),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _dayLabels[day]!,
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  if (byDay[day] == null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colors.error,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Cerrado',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else
                    Text(
                      byDay[day]!
                          .map((s) => '${s.startTime} - ${s.endTime}')
                          .join(', '),
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMaterialsCard(
    EstablishmentDetail detail,
    ColorScheme colors,
    TextTheme textTheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.recycling, size: 20, color: colors.primary),
              const SizedBox(width: 8),
              Text(
                'Materiales aceptados',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (detail.materials.isEmpty)
            Text(
              'Sin materiales registrados',
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurface.withValues(alpha: 0.5),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: detail.materials
                  .map(
                    (m) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: colors.primary, width: 0.8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.eco_outlined,
                            size: 13,
                            color: colors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            m,
                            style: textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}
