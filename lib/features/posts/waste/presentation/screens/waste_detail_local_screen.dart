import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:treasureflow/core/di/app_container.dart';
import 'package:treasureflow/features/posts/object/presentation/widgets/image_gallery_widget.dart';
import 'package:treasureflow/features/posts/waste/di/waste_post_module.dart';
import 'package:treasureflow/features/posts/waste/domain/entities/available_slot.dart';
import 'package:treasureflow/features/posts/waste/domain/entities/my_offer.dart';
import 'package:treasureflow/features/posts/waste/domain/entities/waste_post_detail.dart';
import 'package:treasureflow/features/posts/waste/presentation/providers/waste_detail_local_provider.dart';
import 'package:treasureflow/features/posts/waste/presentation/widgets/info_banner_widget.dart';
import 'package:treasureflow/features/posts/waste/presentation/widgets/make_offer_card_widget.dart';
import 'package:treasureflow/shared/utils/material_type_translator.dart';
import 'package:treasureflow/shared/utils/pickup_label_formatter.dart';
import 'package:treasureflow/shared/utils/post_status_translator.dart';
import 'package:treasureflow/shared/widgets/app_toast.dart';
import 'package:treasureflow/shared/widgets/image_viewer_screen.dart';

class WasteDetailLocalScreen extends StatefulWidget {
  final String postId;

  const WasteDetailLocalScreen({super.key, required this.postId});

  @override
  State<WasteDetailLocalScreen> createState() => _WasteDetailLocalScreenState();
}

class _WasteDetailLocalScreenState extends State<WasteDetailLocalScreen> {
  late final WasteDetailLocalProvider _provider;
  bool _descriptionExpanded = false;
  final _priceController = TextEditingController();
  String _selectedUnit = 'kg';
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _offerPrefilled = false;

  @override
  void initState() {
    super.initState();
    _provider = WastePostModule(
      context.read<AppContainer>(),
    ).provideDetailLocalProvider();
    _provider.addListener(_prefillOfferOnce);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _provider.load(widget.postId);
      final container = context.read<AppContainer>();
      final establishmentId = await container.userStorage.getUserId() ?? '';
      if (mounted) _provider.loadSlots(establishmentId);
    });
  }

  void _prefillOfferOnce() {
    if (_offerPrefilled) return;
    final offer = _provider.post?.myOffer;
    if (offer == null) return;
    _offerPrefilled = true;
    _priceController.text = offer.pricePerUnit.toString();
    final prefillDate = DateTime.tryParse(offer.proposedPickupDate);
    setState(() {
      _selectedUnit = offer.unit;
      _selectedDate = prefillDate;
      _startTime = _parseTime(offer.proposedPickupStart);
      _endTime = _parseTime(offer.proposedPickupEnd);
    });
  }

  @override
  void dispose() {
    _provider.removeListener(_prefillOfferOnce);
    _priceController.dispose();
    super.dispose();
  }

  static TimeOfDay? _parseTime(String value) {
    if (value.isEmpty) return null;
    final parts = value.split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  static String _dateToIso(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  static String _timeToString(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  AvailableSlot? get _matchingSlot {
    if (_selectedDate == null) return null;
    final iso = _dateToIso(_selectedDate!);
    for (final slot in _provider.slots) {
      if (slot.date == iso) return slot;
    }
    return null;
  }

  Future<void> _pickStartTime() async {
    final slot = _matchingSlot;
    final initial =
        _startTime ??
        (slot != null ? _parseTime(slot.start) : null) ??
        const TimeOfDay(hour: 9, minute: 0);
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null && mounted) setState(() => _startTime = picked);
  }

  Future<void> _pickEndTime() async {
    final slot = _matchingSlot;
    final initial =
        _endTime ??
        (slot != null ? _parseTime(slot.end) : null) ??
        const TimeOfDay(hour: 18, minute: 0);
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null && mounted) setState(() => _endTime = picked);
  }

  Future<void> _showSlotPicker() async {
    if (_provider.slotsLoading) {
      AppToast.show(
        context,
        'Cargando días disponibles, espera un momento',
        type: ToastType.info,
      );
      return;
    }

    if (_provider.slots.isEmpty) {
      AppToast.show(
        context,
        'No tienes días laborales registrados en las próximas 2 semanas',
        type: ToastType.warning,
      );
      return;
    }

    final selected = await showModalBottomSheet<AvailableSlot>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _SlotPickerSheet(slots: _provider.slots),
    );

    if (selected != null && mounted) {
      setState(() {
        _selectedDate = DateTime.parse(selected.date);
        _startTime = null;
        _endTime = null;
      });
    }
  }

  Future<void> _onSendOffer() async {
    final priceText = _priceController.text.trim();
    if (priceText.isEmpty) {
      AppToast.show(
        context,
        'Ingresa el precio que ofreces',
        type: ToastType.warning,
      );
      return;
    }

    final price = double.tryParse(priceText);
    if (price == null || price <= 0) {
      AppToast.show(
        context,
        'Ingresa un precio válido',
        type: ToastType.warning,
      );
      return;
    }

    if (_selectedDate == null) {
      AppToast.show(
        context,
        'Selecciona el día de recolección',
        type: ToastType.warning,
      );
      return;
    }

    if (_startTime == null || _endTime == null) {
      AppToast.show(
        context,
        'Selecciona el horario de recolección',
        type: ToastType.warning,
      );
      return;
    }

    final startMin = _startTime!.hour * 60 + _startTime!.minute;
    final endMin = _endTime!.hour * 60 + _endTime!.minute;

    if (endMin <= startMin) {
      AppToast.show(
        context,
        'La hora de fin debe ser mayor a la de inicio',
        type: ToastType.warning,
      );
      return;
    }

    final slot = _matchingSlot;
    if (slot != null) {
      final slotStart = _parseTime(slot.start);
      final slotEnd = _parseTime(slot.end);
      if (slotStart != null && slotEnd != null) {
        final slotStartMin = slotStart.hour * 60 + slotStart.minute;
        final slotEndMin = slotEnd.hour * 60 + slotEnd.minute;
        if (startMin < slotStartMin || endMin > slotEndMin) {
          AppToast.show(
            context,
            'El horario debe estar dentro de tu jornada laboral: ${slot.start} – ${slot.end}',
            type: ToastType.warning,
          );
          return;
        }
      }
    }

    final confirmed = await _showConfirmDialog(priceText);
    if (confirmed != true || !mounted) return;

    final success = await _provider.createOffer(
      postId: widget.postId,
      pricePerUnit: price,
      unit: _selectedUnit,
      proposedPickupDate: _dateToIso(_selectedDate!),
      proposedPickupStart: _timeToString(_startTime!),
      proposedPickupEnd: _timeToString(_endTime!),
    );

    if (!mounted) return;

    if (success) {
      _priceController.clear();
      setState(() {
        _selectedDate = null;
        _startTime = null;
        _endTime = null;
      });
      AppToast.show(
        context,
        'Oferta enviada correctamente',
        type: ToastType.success,
      );
    } else {
      AppToast.show(
        context,
        _provider.offerError ?? 'Error al enviar la oferta',
        type: ToastType.error,
      );
      _provider.resetOfferStatus();
    }
  }

  Future<bool?> _showConfirmDialog(String price) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final pickupLabel = formatPickupLabel(
      _dateToIso(_selectedDate!),
      _timeToString(_startTime!),
      _timeToString(_endTime!),
    );

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Confirmar oferta',
          style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Seguro que quieres ofertar \$$price/$_selectedUnit para este residuo?',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: colors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      pickupLabel,
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: colors.primary),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Consumer<WasteDetailLocalProvider>(
        builder: (context, provider, _) {
          if (provider.status == WasteDetailLocalStatus.loading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (provider.status == WasteDetailLocalStatus.error) {
            return Scaffold(
              appBar: AppBar(),
              body: Center(
                child: Text(provider.errorMessage ?? 'Error al cargar'),
              ),
            );
          }

          final post = provider.post;
          if (post == null) {
            return const Scaffold(body: SizedBox.shrink());
          }

          return _buildContent(context, post, provider);
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WastePostDetail post,
    WasteDetailLocalProvider provider,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                final userStorage = context.read<AppContainer>().userStorage;
                await _provider.load(widget.postId);
                final establishmentId = await userStorage.getUserId() ?? '';
                await _provider.loadSlots(establishmentId);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ImageGalleryWidget(
                      imageUrls: post.photoUrls,
                      onImageTap: (index) => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ImageViewerScreen(
                            imageUrls: post.photoUrls,
                            initialIndex: index,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  MaterialTypeTranslator.translate(
                                    post.materialTypeName,
                                  ),
                                  style: textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _statusBadge(post.status, textTheme),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _publisherRow(post, colors, textTheme),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _infoChip(
                                Icons.recycling,
                                MaterialTypeTranslator.translate(
                                  post.materialTypeName,
                                ),
                                colors,
                                textTheme,
                              ),
                              if (post.distance != null)
                                _infoChip(
                                  Icons.location_on_outlined,
                                  post.distance!,
                                  colors,
                                  textTheme,
                                ),
                              _infoChip(
                                Icons.access_time,
                                post.publishedAt,
                                colors,
                                textTheme,
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _deliveryModeBanner(
                            post.deliveryMode,
                            textTheme,
                            colors,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Descripción',
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            post.description,
                            style: textTheme.bodySmall?.copyWith(
                              color: colors.onSurface.withValues(alpha: 0.7),
                            ),
                            maxLines: _descriptionExpanded ? null : 3,
                            overflow: _descriptionExpanded
                                ? null
                                : TextOverflow.ellipsis,
                          ),
                          GestureDetector(
                            onTap: () => setState(
                              () =>
                                  _descriptionExpanded = !_descriptionExpanded,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                _descriptionExpanded
                                    ? 'Leer menos'
                                    : 'Leer más',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const InfoBannerWidget(
                            svgPath: 'assets/posts/money_icon.svg',
                            title: 'Las ofertas se calculan por unidad.',
                            subtitle:
                                'El monto final se confirma al pesar el material en la recolección.',
                          ),
                          const SizedBox(height: 20),
                          if (post.myOffer != null)
                            _existingOfferBanner(
                              post.myOffer!,
                              colors,
                              textTheme,
                            ),
                          if (post.myOffer != null) const SizedBox(height: 16),
                          MakeOfferCardWidget(
                            priceController: _priceController,
                            isLoading: provider.isSubmitting,
                            onSubmit: _onSendOffer,
                            selectedUnit: _selectedUnit,
                            onUnitChanged: (unit) =>
                                setState(() => _selectedUnit = unit),
                            selectedDate: _selectedDate,
                            startTime: _startTime,
                            endTime: _endTime,
                            onPickDate: _showSlotPicker,
                            onPickStartTime: _pickStartTime,
                            onPickEndTime: _pickEndTime,
                            matchingSlot: _matchingSlot,
                            slotsLoading: provider.slotsLoading,
                            buttonLabel: post.myOffer != null
                                ? 'Actualizar oferta'
                                : 'Enviar oferta',
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _buildBottomBar(post, colors, textTheme, provider),
        ],
      ),
    );
  }

  Widget _buildBottomBar(
    WastePostDetail post,
    ColorScheme colors,
    TextTheme textTheme,
    WasteDetailLocalProvider provider,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (post.distance != null)
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: colors.primary),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Distancia: ${post.distance}',
                        style: textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: GestureDetector(
                onTap: provider.isSubmitting ? null : _onSendOffer,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: provider.isSubmitting
                        ? colors.primary.withValues(alpha: 0.5)
                        : colors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (provider.isSubmitting)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      else ...[
                        Text(
                          post.myOffer != null
                              ? 'Actualizar oferta'
                              : 'Confirmar oferta',
                          style: textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: Colors.white,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _existingOfferBanner(
    MyOffer offer,
    ColorScheme colors,
    TextTheme textTheme,
  ) {
    final isAccepted = offer.status == 'accepted';
    final color = isAccepted ? Colors.green : colors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            isAccepted
                ? Icons.check_circle_outline
                : Icons.local_offer_outlined,
            size: 20,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAccepted
                      ? 'Tu oferta fue aceptada'
                      : 'Ya enviaste una oferta',
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '\$${offer.pricePerUnit.toStringAsFixed(2)} / ${offer.unit}',
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                if (offer.pickupLabel.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    offer.pickupLabel,
                    style: textTheme.bodySmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status, TextTheme textTheme) {
    final info = PostStatusTranslator.translate(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: info.color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        info.label,
        style: textTheme.bodySmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _publisherRow(
    WastePostDetail post,
    ColorScheme colors,
    TextTheme textTheme,
  ) {
    final hasPhoto = post.citizenProfilePictureUrl.isNotEmpty;
    return Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: colors.primary.withValues(alpha: 0.1),
          backgroundImage: hasPhoto
              ? NetworkImage(post.citizenProfilePictureUrl)
              : null,
          child: hasPhoto
              ? null
              : Icon(Icons.person, size: 16, color: colors.primary),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            post.citizenName.isNotEmpty ? post.citizenName : 'Ciudadano',
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _deliveryModeBanner(
    String deliveryMode,
    TextTheme textTheme,
    ColorScheme colors,
  ) {
    final (icon, label, color) = switch (deliveryMode) {
      'home_delivery' => (
        Icons.local_shipping_outlined,
        'Disponible para recolección a domicilio',
        colors.primary,
      ),
      'drop_off' => (
        Icons.storefront_outlined,
        'Debes llevarlo a un punto de acopio',
        const Color(0xFF30A3F3),
      ),
      _ => (
        Icons.swap_horiz_rounded,
        'Recolección a domicilio o entrega en punto',
        const Color(0xFF6D53ED),
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(
    IconData icon,
    String label,
    ColorScheme colors,
    TextTheme textTheme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outline.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.06),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colors.onSurface.withValues(alpha: 0.6)),
          const SizedBox(width: 6),
          Text(label, style: textTheme.bodySmall?.copyWith(fontSize: 11)),
        ],
      ),
    );
  }
}

class _SlotPickerSheet extends StatelessWidget {
  final List<AvailableSlot> slots;

  const _SlotPickerSheet({required this.slots});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Selecciona un día',
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Text(
                'Solo aparecen los días en que tu establecimiento trabaja',
                style: textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: slots.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) => _SlotCard(slot: slots[index]),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SlotCard extends StatelessWidget {
  final AvailableSlot slot;

  const _SlotCard({required this.slot});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isFull = slot.isFull;

    return InkWell(
      onTap: () => Navigator.of(context).pop(slot),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.outline.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.calendar_today_outlined,
                size: 20,
                color: colors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${slot.dayLabel} · ${_displayDate(slot.date)}',
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 12,
                        color: colors.onSurface.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${slot.start} – ${slot.end}',
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: colors.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isFull)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8930C).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFE8930C).withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  'Lleno',
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: const Color(0xFFE8930C),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else
              Text(
                '${slot.slotsUsed}/${slot.maxSlots}',
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  color: colors.onSurface.withValues(alpha: 0.45),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _displayDate(String isoDate) {
    final parts = isoDate.split('-');
    if (parts.length < 3) return isoDate;
    final day = int.tryParse(parts[2]) ?? 0;
    final monthNum = int.tryParse(parts[1]) ?? 1;
    const months = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ];
    return '$day ${months[monthNum - 1]}';
  }
}
