import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:treasureflow/features/feed/domain/entities/recommended_post.dart';
import 'package:treasureflow/features/feed/presentation/providers/recommended_feed_provider.dart';
import 'package:treasureflow/features/posts/waste/navigation/waste_detail_navigation.dart';
import 'package:treasureflow/shared/utils/responsive_grid.dart';
import 'package:treasureflow/shared/widgets/post_card_widget.dart';

const _fallbackCenter = LatLng(16.7569, -93.1292);
const _sheetOverlap = 20.0;

class RecommendedFeedTabWidget extends StatefulWidget {
  const RecommendedFeedTabWidget({super.key});

  @override
  State<RecommendedFeedTabWidget> createState() =>
      _RecommendedFeedTabWidgetState();
}

class _RecommendedFeedTabWidgetState extends State<RecommendedFeedTabWidget> {
  final _scrollController = ScrollController();
  GoogleMapController? _mapController;
  final Map<String, BitmapDescriptor> _markerIconCache = {};
  final Set<String> _pendingIconKeys = {};
  double _currentZoom = 13;
  CameraPosition? _lastCameraPosition;

  @override
  void initState() {
    super.initState();
    debugPrint('[RecommendedFeedTabWidget] initState');
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<RecommendedFeedProvider>();
      debugPrint('[RecommendedFeedTabWidget] triggering loadPosts()');
      await provider.loadPosts();
      debugPrint(
        '[RecommendedFeedTabWidget] loadPosts done, status:${provider.status} posts:${provider.posts.length}',
      );
      if (!mounted) return;
      _moveCameraToPosts(provider.posts);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<RecommendedFeedProvider>().loadMore();
    }
  }

  Future<void> _moveCameraToPosts(List<RecommendedPost> posts) async {
    if (posts.isEmpty || _mapController == null) return;
    await _mapController!.animateCamera(
      CameraUpdate.newLatLngZoom(_centerOf(posts), 13),
    );
  }

  LatLng _centerOf(List<RecommendedPost> posts) {
    if (posts.isEmpty) return _fallbackCenter;
    final lat =
        posts.map((p) => p.latitude).reduce((a, b) => a + b) / posts.length;
    final lng =
        posts.map((p) => p.longitude).reduce((a, b) => a + b) / posts.length;
    return LatLng(lat, lng);
  }

  double _degreesPerCell(double zoom) {
    const targetPixels = 64.0;
    final worldWidth = 256 * math.pow(2, zoom);
    return (targetPixels / worldWidth) * 360;
  }

  Map<String, List<RecommendedPost>> _clusterPosts(
    List<RecommendedPost> posts,
    double zoom,
  ) {
    final cellSize = _degreesPerCell(zoom);
    final clusters = <String, List<RecommendedPost>>{};
    for (final post in posts) {
      final cellLat = (post.latitude / cellSize).floor();
      final cellLng = (post.longitude / cellSize).floor();
      clusters.putIfAbsent('$cellLat:$cellLng', () => []).add(post);
    }
    return clusters;
  }

  LatLng _centroidOf(List<RecommendedPost> group) {
    final lat =
        group.map((p) => p.latitude).reduce((a, b) => a + b) / group.length;
    final lng =
        group.map((p) => p.longitude).reduce((a, b) => a + b) / group.length;
    return LatLng(lat, lng);
  }

  Set<Marker> _markersOf(
    List<RecommendedPost> posts,
    double pixelRatio,
    double zoom,
  ) {
    final clusters = _clusterPosts(posts, zoom);
    final markers = <Marker>{};

    for (final entry in clusters.entries) {
      final group = entry.value;
      final isFeatured = group.any((p) => p.isFeatured);
      final count = group.length;
      final materialNames = group.map((p) => p.materialTypeName).toSet();
      final label = materialNames.length == 1 ? materialNames.first : 'Varios';
      final key = '$label|$isFeatured|$count';

      var icon = _markerIconCache[key];
      if (icon == null) {
        icon = isFeatured
            ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange)
            : BitmapDescriptor.defaultMarker;
        if (_pendingIconKeys.add(key)) {
          _generateAndCacheIcon(key, label, isFeatured, count, pixelRatio);
        }
      }

      markers.add(
        Marker(
          markerId: MarkerId(entry.key),
          position: _centroidOf(group),
          icon: icon,
          infoWindow: InfoWindow(
            title: count > 1 ? '$count publicaciones aquí' : label,
            snippet: count > 1
                ? 'Toca para ver todas'
                : group.first.publishedAt,
          ),
          onTap: () => count == 1
              ? pushWasteDetail(context, group.first.id)
              : _showLocationPicker(group),
        ),
      );
    }

    return markers;
  }

  Future<void> _generateAndCacheIcon(
    String key,
    String label,
    bool isFeatured,
    int count,
    double pixelRatio,
  ) async {
    final bytes = await _drawMarkerBytes(
      label: label,
      isFeatured: isFeatured,
      count: count,
      pixelRatio: pixelRatio,
    );
    final icon = BitmapDescriptor.bytes(bytes, imagePixelRatio: pixelRatio);
    _pendingIconKeys.remove(key);
    if (!mounted) return;
    setState(() => _markerIconCache[key] = icon);
  }

  Future<Uint8List> _drawMarkerBytes({
    required String label,
    required bool isFeatured,
    required int count,
    required double pixelRatio,
  }) async {
    const double baseWidth = 140;
    const double baseHeight = 44;
    const double pointerHeight = 12;
    final width = baseWidth * pixelRatio;
    final height = (baseHeight + pointerHeight) * pixelRatio;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, width, height));
    canvas.scale(pixelRatio);

    final bgColor = isFeatured
        ? const Color(0xFFF59E0B)
        : const Color(0xFF418839);
    final paint = Paint()..color = bgColor;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, baseWidth, baseHeight),
        Radius.circular(baseHeight / 2),
      ),
      paint,
    );

    final pointerPath = Path()
      ..moveTo(baseWidth / 2 - 8, baseHeight)
      ..lineTo(baseWidth / 2 + 8, baseHeight)
      ..lineTo(baseWidth / 2, baseHeight + pointerHeight)
      ..close();
    canvas.drawPath(pointerPath, paint);

    TextPainter? starPainter;
    if (isFeatured) {
      starPainter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(Icons.star_rounded.codePoint),
          style: TextStyle(
            fontSize: 16,
            fontFamily: Icons.star_rounded.fontFamily,
            package: Icons.star_rounded.fontPackage,
            color: Colors.white,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
    }

    const starSpacing = 4.0;
    final reservedForStar = starPainter != null
        ? starPainter.width + starSpacing
        : 0.0;
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: baseWidth - 20 - reservedForStar);

    final contentWidth = reservedForStar + textPainter.width;
    var dx = (baseWidth - contentWidth) / 2;
    if (starPainter != null) {
      starPainter.paint(
        canvas,
        Offset(dx, (baseHeight - starPainter.height) / 2),
      );
      dx += starPainter.width + starSpacing;
    }
    textPainter.paint(
      canvas,
      Offset(dx, (baseHeight - textPainter.height) / 2),
    );

    if (count > 1) {
      const badgeRadius = 12.0;
      const badgeMargin = 2.0;
      final badgeCenter = Offset(
        baseWidth - badgeRadius - badgeMargin,
        badgeRadius + badgeMargin,
      );
      canvas.drawCircle(
        badgeCenter,
        badgeRadius,
        Paint()..color = Colors.white,
      );
      canvas.drawCircle(
        badgeCenter,
        badgeRadius,
        Paint()
          ..color = bgColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      final countPainter = TextPainter(
        text: TextSpan(
          text: '$count',
          style: TextStyle(
            color: bgColor,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      countPainter.paint(
        canvas,
        badgeCenter - Offset(countPainter.width / 2, countPainter.height / 2),
      );
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(width.round(), height.round());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<void> _showLocationPicker(List<RecommendedPost> group) async {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${group.length} publicaciones en este punto',
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: group.length,
                    itemBuilder: (_, i) => _buildLocationPickerRow(
                      sheetContext,
                      group[i],
                      colors,
                      textTheme,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationPickerRow(
    BuildContext sheetContext,
    RecommendedPost post,
    ColorScheme colors,
    TextTheme textTheme,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        Navigator.of(sheetContext).pop();
        pushWasteDetail(context, post.id);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.primary.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Icon(
                Icons.recycling_outlined,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          post.materialTypeName,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (post.isFeatured)
                        Icon(
                          Icons.star_rounded,
                          size: 16,
                          color: colors.primary,
                        ),
                    ],
                  ),
                  Text(
                    post.publishedAt,
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _formatDistance(post.distanceMeters),
              style: textTheme.bodySmall?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right,
              color: colors.onSurface.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDistance(double meters) {
    if (meters < 1000) return '${meters.round()} m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final mapHeight = screenHeight * 0.42;
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;

    return SafeArea(
      child: Consumer<RecommendedFeedProvider>(
        builder: (context, provider, _) {
          return Stack(
            children: [
              SizedBox(
                height: mapHeight,
                width: double.infinity,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _centerOf(provider.posts),
                    zoom: 13,
                  ),
                  markers: _markersOf(provider.posts, pixelRatio, _currentZoom),
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,

                  gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                    Factory<OneSequenceGestureRecognizer>(
                      () => EagerGestureRecognizer(),
                    ),
                  },
                  onMapCreated: (controller) {
                    _mapController = controller;
                    _moveCameraToPosts(provider.posts);
                  },
                  onCameraMove: (position) {
                    _lastCameraPosition = position;
                  },
                  onCameraIdle: () {
                    final newZoom = _lastCameraPosition?.zoom;
                    if (newZoom != null &&
                        newZoom.round() != _currentZoom.round()) {
                      setState(() => _currentZoom = newZoom);
                    }
                  },
                ),
              ),
              Positioned(
                top: mapHeight - _sheetOverlap,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colors.shadow,
                        blurRadius: 12,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      if (provider.status == RecommendedFeedStatus.success &&
                          provider.posts.isNotEmpty)
                        _buildHeader(provider, colors, textTheme),
                      Expanded(
                        child: _buildContent(provider, colors, textTheme),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(
    RecommendedFeedProvider provider,
    ColorScheme colors,
    TextTheme textTheme,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        children: [
          Icon(Icons.location_on_outlined, size: 16, color: colors.primary),
          const SizedBox(width: 6),
          Text(
            '${provider.total} publicaciones cerca de ti',
            style: textTheme.bodySmall?.copyWith(
              color: colors.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStateIcon(IconData icon, Color iconColor, Color boxColor) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: boxColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, size: 26, color: iconColor),
    );
  }

  Widget _buildContent(
    RecommendedFeedProvider provider,
    ColorScheme colors,
    TextTheme textTheme,
  ) {
    if (provider.status == RecommendedFeedStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.status == RecommendedFeedStatus.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStateIcon(
                Icons.error_outline,
                colors.error,
                colors.error.withValues(alpha: 0.12),
              ),
              const SizedBox(height: 12),
              Text(
                provider.errorMessage ?? 'Error al cargar',
                style: textTheme.bodyMedium?.copyWith(color: colors.error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => provider.loadPosts(reset: true),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStateIcon(
              Icons.location_off_outlined,
              colors.onSurface.withValues(alpha: 0.7),
              colors.outline.withValues(alpha: 0.15),
            ),
            const SizedBox(height: 12),
            Text(
              'Aún no hay publicaciones recomendadas cerca de ti',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
      gridDelegate: responsiveGridDelegate(
        context,
        crossAxisCount: 2,

        imageAspectRatio: 1.3,
        contentHeight: 100,
      ),
      itemCount: provider.posts.length + (provider.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == provider.posts.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        final post = provider.posts[index];
        return PostCardWidget(
          imageUrl: post.mainPhotoUrl,
          title: post.materialTypeName,
          subtitle: post.publishedAt,
          statusLabel: post.isFeatured ? 'Destacado' : null,
          statusColor: post.isFeatured ? colors.primary : null,
          distanceLabel: _formatDistance(post.distanceMeters),
          onTap: () => pushWasteDetail(context, post.id),
        );
      },
    );
  }
}
