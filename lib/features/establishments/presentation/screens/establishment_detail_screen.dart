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
const _goldStar = Color(0xFFF5A623);

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
  final _heroPageController = PageController();

  int _selectedTab = 0;
  int _heroPage = 0;
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
    _heroPageController.dispose();
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
      body: _buildBody(colors, textTheme),
    );
  }

  Widget _buildBody(ColorScheme colors, TextTheme textTheme) {
    switch (_provider.status) {
      case EstablishmentDetailStatus.loading:
      case EstablishmentDetailStatus.idle:
        return SafeArea(
          child: Column(
            children: [
              _buildMinimalAppBar(colors),
              const Expanded(child: Center(child: CircularProgressIndicator())),
            ],
          ),
        );
      case EstablishmentDetailStatus.error:
        return SafeArea(
          child: Column(
            children: [
              _buildMinimalAppBar(colors),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline_rounded, size: 48, color: colors.error),
                        const SizedBox(height: 16),
                        Text(
                          _provider.errorMessage ?? 'No se pudo cargar el establecimiento',
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
                ),
              ),
            ],
          ),
        );
      case EstablishmentDetailStatus.success:
        return _buildDetail(_provider.detail!, colors, textTheme);
    }
  }

  Widget _buildMinimalAppBar(ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: colors.primary,
            child: Icon(Icons.arrow_back, size: 18, color: colors.onPrimary),
          ),
        ),
      ),
    );
  }

  Widget _buildDetail(
    EstablishmentDetail detail,
    ColorScheme colors,
    TextTheme textTheme,
  ) {
    final images = detail.photoUrls.isNotEmpty
        ? detail.photoUrls
        : (detail.profilePictureUrl != null ? [detail.profilePictureUrl!] : <String>[]);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          stretch: true,
          expandedHeight: 260,
          backgroundColor: colors.surfaceContainerLowest,
          surfaceTintColor: Colors.transparent,
          leading: Padding(
            padding: const EdgeInsets.only(left: 8, top: 4),
            child: GestureDetector(
              onTap: () => Navigator.of(context).maybePop(),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.black.withValues(alpha: 0.35),
                child: const Icon(Icons.arrow_back, size: 18, color: Colors.white),
              ),
            ),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: _buildHeroCarousel(images, detail, colors),
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIdentityCard(detail, colors, textTheme),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: _buildSegmentedControl(colors, textTheme),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: _selectedTab == 0
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildContactCard(detail, colors, textTheme),
                          const SizedBox(height: 14),
                          _buildScheduleCard(detail, colors, textTheme),
                          const SizedBox(height: 14),
                          _buildMaterialsCard(detail, colors, textTheme),
                        ],
                      )
                    : _buildReviewsTab(detail, colors, textTheme),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCarousel(
    List<String> images,
    EstablishmentDetail detail,
    ColorScheme colors,
  ) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (images.isEmpty)
          Container(
            color: colors.primary.withValues(alpha: 0.15),
            child: Icon(Icons.storefront_rounded, size: 64, color: colors.primary),
          )
        else if (images.length == 1)
          Image.network(
            images.first,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(color: colors.primary.withValues(alpha: 0.15)),
          )
        else
          PageView.builder(
            controller: _heroPageController,
            itemCount: images.length,
            onPageChanged: (i) => setState(() => _heroPage = i),
            itemBuilder: (context, i) => Image.network(
              images[i],
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(color: colors.primary.withValues(alpha: 0.15)),
            ),
          ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.4, 1],
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.65),
              ],
            ),
          ),
        ),
        if (images.length > 1)
          Positioned(
            bottom: 14,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                images.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _heroPage ? 16 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: i == _heroPage ? 0.95 : 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildIdentityCard(
    EstablishmentDetail detail,
    ColorScheme colors,
    TextTheme textTheme,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  detail.storeName,
                  style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              _statusPill(
                text: detail.isOpen ? 'Abierto' : 'Cerrado',
                color: detail.isOpen ? colors.primary : colors.error,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.star_rounded, size: 20, color: _goldStar),
              const SizedBox(width: 4),
              Text(
                detail.averageRating.toStringAsFixed(1),
                style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 4),
              Text(
                '(${_reviewsProvider.total} ${_reviewsProvider.total == 1 ? 'reseña' : 'reseñas'})',
                style: textTheme.bodySmall?.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.5),
                ),
              ),
              if (detail.addressText != null) ...[
                const SizedBox(width: 10),
                Container(width: 3, height: 3, decoration: BoxDecoration(color: colors.onSurface.withValues(alpha: 0.3), shape: BoxShape.circle)),
                const SizedBox(width: 10),
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.place_outlined, size: 14, color: colors.onSurface.withValues(alpha: 0.5)),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          detail.addressText!,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusPill({required String text, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedControl(ColorScheme colors, TextTheme textTheme) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Expanded(child: _segmentedTab('Información', Icons.info_outline_rounded, 0, colors, textTheme)),
          Expanded(child: _segmentedTab('Reseñas', Icons.star_outline_rounded, 1, colors, textTheme)),
        ],
      ),
    );
  }

  Widget _segmentedTab(
    String label,
    IconData icon,
    int index,
    ColorScheme colors,
    TextTheme textTheme,
  ) {
    final isSelected = _selectedTab == index;
    return InkWell(
      borderRadius: BorderRadius.circular(11),
      onTap: () => setState(() => _selectedTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary : null,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? colors.onPrimary : colors.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                color: isSelected ? colors.onPrimary : colors.onSurface.withValues(alpha: 0.5),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsTab(
    EstablishmentDetail detail,
    ColorScheme colors,
    TextTheme textTheme,
  ) {
    final canReview =
        context.isCitizen && _submitReviewProvider.eligibleCollections.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRatingSummary(detail, colors, textTheme),
        const SizedBox(height: 16),
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

  Widget _buildRatingSummary(
    EstablishmentDetail detail,
    ColorScheme colors,
    TextTheme textTheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outline.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                detail.averageRating.toStringAsFixed(1),
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _goldStar,
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < detail.averageRating.round() ? Icons.star_rounded : Icons.star_border_rounded,
                    size: 14,
                    color: _goldStar,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 18),
          Container(height: 44, width: 1, color: colors.outline.withValues(alpha: 0.2)),
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              _reviewsProvider.total == 0
                  ? 'Aún no hay reseñas de este establecimiento'
                  : 'Basado en ${_reviewsProvider.total} ${_reviewsProvider.total == 1 ? 'reseña' : 'reseñas'} de ciudadanos',
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsList(ColorScheme colors, TextTheme textTheme) {
    if (_reviewsProvider.status == ReviewsListStatus.loading ||
        _reviewsProvider.status == ReviewsListStatus.idle) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_reviewsProvider.status == ReviewsListStatus.error) {
      return Text(
        _reviewsProvider.errorMessage ?? 'No se pudieron cargar las reseñas',
        style: textTheme.bodyMedium,
      );
    }

    if (_reviewsProvider.items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Icon(Icons.rate_review_outlined, size: 32, color: colors.onSurface.withValues(alpha: 0.25)),
            const SizedBox(height: 8),
            Text(
              'Este establecimiento aún no tiene reseñas',
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
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
                          color: _goldStar,
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

  Widget _sectionHeader(String label, IconData icon, ColorScheme colors, TextTheme textTheme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: colors.primary),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildContactCard(
    EstablishmentDetail detail,
    ColorScheme colors,
    TextTheme textTheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Contacto y ubicación', Icons.location_on_outlined, colors, textTheme),
          const SizedBox(height: 14),
          _contactRow(
            icon: Icons.location_on_outlined,
            label: 'Dirección',
            value: detail.addressText ?? 'Sin registrar',
            colors: colors,
            textTheme: textTheme,
          ),
          Divider(height: 24, color: colors.outline.withValues(alpha: 0.15)),
          _contactRow(
            icon: Icons.phone_outlined,
            label: 'Teléfono',
            value: detail.phone,
            colors: colors,
            textTheme: textTheme,
          ),
          Divider(height: 24, color: colors.outline.withValues(alpha: 0.15)),
          _contactRow(
            icon: Icons.local_shipping_outlined,
            label: 'Transporte propio',
            value: null,
            badgeText: detail.hasVehicle ? 'Disponible' : 'No disponible',
            badgeColor: detail.hasVehicle ? colors.primary : colors.error,
            colors: colors,
            textTheme: textTheme,
          ),
        ],
      ),
    );
  }

  Widget _contactRow({
    required IconData icon,
    required String label,
    required String? value,
    String? badgeText,
    Color? badgeColor,
    required ColorScheme colors,
    required TextTheme textTheme,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 17, color: colors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
        const SizedBox(width: 12),
        if (badgeText != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              badgeText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        else
          Flexible(
            child: Text(
              value ?? '',
              textAlign: TextAlign.right,
              style: textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
          ),
      ],
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
    final today = DateTime.now().weekday;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Horarios de atención', Icons.access_time_rounded, colors, textTheme),
          const SizedBox(height: 10),
          for (final day in _dayOrder)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: colors.outline.withValues(alpha: 0.12)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _dayLabels[day]!,
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: day == today ? FontWeight.w700 : FontWeight.normal,
                      color: day == today
                          ? colors.onSurface
                          : colors.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  if (byDay[day] == null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                        color: colors.error.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Cerrado',
                        style: TextStyle(
                          color: colors.error,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  else
                    Text(
                      byDay[day]!.map((s) => '${s.startTime} - ${s.endTime}').join(', '),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Materiales aceptados', Icons.recycling_rounded, colors, textTheme),
          const SizedBox(height: 14),
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
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.eco_rounded, size: 13, color: colors.primary),
                          const SizedBox(width: 5),
                          Text(
                            m,
                            style: textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: colors.primary,
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
