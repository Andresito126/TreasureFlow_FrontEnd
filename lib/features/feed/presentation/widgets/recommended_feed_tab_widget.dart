import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:treasureflow/features/feed/domain/entities/recommended_post.dart';
import 'package:treasureflow/features/feed/presentation/providers/recommended_feed_provider.dart';
import 'package:treasureflow/features/posts/waste/navigation/waste_detail_navigation.dart';
import 'package:treasureflow/shared/widgets/post_card_widget.dart';

const _fallbackCenter = LatLng(16.7569, -93.1292);

class RecommendedFeedTabWidget extends StatefulWidget {
  const RecommendedFeedTabWidget({super.key});

  @override
  State<RecommendedFeedTabWidget> createState() =>
      _RecommendedFeedTabWidgetState();
}

class _RecommendedFeedTabWidgetState extends State<RecommendedFeedTabWidget> {
  final _scrollController = ScrollController();
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    debugPrint('[RecommendedFeedTabWidget] initState');
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<RecommendedFeedProvider>();
      debugPrint('[RecommendedFeedTabWidget] triggering loadPosts()');
      await provider.loadPosts();
      debugPrint('[RecommendedFeedTabWidget] loadPosts done, status:${provider.status} posts:${provider.posts.length}');
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

  Set<Marker> _markersOf(List<RecommendedPost> posts) {
    return {
      for (final post in posts)
        Marker(
          markerId: MarkerId(post.id),
          position: LatLng(post.latitude, post.longitude),
          infoWindow: InfoWindow(
            title: post.materialTypeName,
            snippet: post.publishedAt,
          ),
          onTap: () => pushWasteDetail(context, post.id),
        ),
    };
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

    return SafeArea(
      child: Consumer<RecommendedFeedProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              SizedBox(
                height: screenHeight * 0.42,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _centerOf(provider.posts),
                    zoom: 13,
                  ),
                  markers: _markersOf(provider.posts),
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  onMapCreated: (controller) {
                    _mapController = controller;
                    _moveCameraToPosts(provider.posts);
                  },
                ),
              ),
              Expanded(
                child: _buildContent(provider, colors, textTheme),
              ),
            ],
          );
        },
      ),
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
              Icon(Icons.error_outline,
                  size: 48, color: colors.error.withValues(alpha: 0.6)),
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
            Icon(Icons.location_off_outlined,
                size: 48, color: colors.onSurface.withValues(alpha: 0.3)),
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.78,
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
