import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:treasureflow/features/profile/citizen/presentation/providers/profile_posts_provider.dart';
import 'package:treasureflow/shared/utils/post_status_translator.dart';
import 'package:treasureflow/shared/widgets/app_toast.dart';
import 'package:treasureflow/shared/widgets/floating_nav_bar_widget.dart';
import 'package:treasureflow/shared/widgets/post_card_widget.dart';
import 'package:treasureflow/shared/widgets/post_filter_bar_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfilePostsProvider>().loadPosts();
    });
    _scrollController.addListener(_onScroll);
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
      context.read<ProfilePostsProvider>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      body: Stack(
        children: [
          Positioned.fill(
            child: SafeArea(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.only(bottom: 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBannerAndAvatar(colors),
                    const SizedBox(height: 52),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildNameSection(colors, textTheme),
                          const SizedBox(height: 16),
                          _buildStats(colors, textTheme),
                          const SizedBox(height: 24),
                          Consumer<ProfilePostsProvider>(
                            builder: (context, provider, _) {
                              return PostFilterBarWidget(
                                filters: ProfilePostsProvider.filterLabels,
                                selectedIndex: provider.selectedFilterIndex,
                                onSelected: provider.setFilter,
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Mis publicaciones',
                            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          _buildPostsContent(colors, textTheme),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 16,
            child: _topIconButton(
              Icons.settings_outlined,
              colors,
              onTap: () => context.push('/settingsCitizen'),
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: const FloatingNavBarWidget(currentIndex: 3),
          ),
        ],
      ),
    );
  }

  void _onMenuTap(String postId, String publicationType, String status) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: colors.outline.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              if (publicationType == 'waste' && status == 'active')
                ListTile(
                  leading: Icon(Icons.edit_outlined, color: colors.primary),
                  title: Text(
                    'Editar publicación',
                    style: textTheme.bodyMedium,
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push('/editWaste/$postId');
                  },
                ),
              ListTile(
                leading: Icon(Icons.delete_outline, color: colors.error),
                title: Text(
                  'Eliminar publicación',
                  style: textTheme.bodyMedium?.copyWith(color: colors.error),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _confirmDelete(postId);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(String postId) async {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          '¿Eliminar publicación?',
          style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Esta acción no se puede deshacer.',
          style: textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: colors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final provider = context.read<ProfilePostsProvider>();
    final success = await provider.deletePost(postId);

    if (!mounted) return;
    if (success) {
      AppToast.show(context, 'Publicación eliminada', type: ToastType.success);
    } else {
      AppToast.show(
        context,
        provider.deleteError ?? 'Error al eliminar',
        type: ToastType.error,
      );
      provider.resetDeleteStatus();
    }
  }

  Widget _buildStats(ColorScheme colors, TextTheme textTheme) {
    return Consumer<ProfilePostsProvider>(
      builder: (context, provider, _) {
        final profile = provider.profile;
        return Row(
          children: [
            _statChip(
              label: 'Ganancias',
              value: profile != null ? '\$${profile.totalEarnings.toStringAsFixed(2)}' : '—',
              colors: colors,
              textTheme: textTheme,
            ),
            const SizedBox(width: 8),
            _statChip(
              label: 'Publicaciones',
              value: profile != null ? '${profile.totalPublications}' : '—',
              colors: colors,
              textTheme: textTheme,
            ),
            const SizedBox(width: 8),
            _statChip(
              label: 'Activas',
              value: profile != null ? '${profile.activePublications}' : '—',
              colors: colors,
              textTheme: textTheme,
            ),
          ],
        );
      },
    );
  }

  Widget _statChip({
    required String label,
    required String value,
    required ColorScheme colors,
    required TextTheme textTheme,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: colors.primary.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurface.withValues(alpha: 0.5),
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerAndAvatar(ColorScheme colors) {
    return SizedBox(
      height: 194,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/auth/banner.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(color: colors.primary.withValues(alpha: 0.15)),
            ),
          ),
          Positioned(
            left: 16,
            bottom: -44,
            child: Consumer<ProfilePostsProvider>(
              builder: (context, provider, _) {
                final pictureUrl = provider.profile?.profilePictureUrl;
                return Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: colors.primary.withValues(alpha: 0.1),
                    backgroundImage: pictureUrl != null ? NetworkImage(pictureUrl) : null,
                    child: pictureUrl == null
                        ? Icon(Icons.person, size: 40, color: colors.primary)
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameSection(ColorScheme colors, TextTheme textTheme) {
    return Consumer<ProfilePostsProvider>(
      builder: (context, provider, _) {
        final name = provider.profile?.fullName ?? '—';
        final email = provider.profile?.email ?? '';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 2),
            Text(
              email,
              style: textTheme.bodySmall?.copyWith(color: colors.onSurface.withValues(alpha: 0.5)),
            ),
          ],
        );
      },
    );
  }

  Widget _topIconButton(IconData icon, ColorScheme colors, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: colors.surface.withValues(alpha: 0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: colors.onSurface),
      ),
    );
  }

  Widget _buildPostsContent(ColorScheme colors, TextTheme textTheme) {
    return Consumer<ProfilePostsProvider>(
      builder: (context, provider, _) {
        if (provider.status == MyPostsStatus.loading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (provider.status == MyPostsStatus.error) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text(
                provider.errorMessage ?? 'Error al cargar tus publicaciones',
                style: textTheme.bodyMedium?.copyWith(color: colors.error),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        if (provider.posts.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text(
                'Aún no tienes publicaciones',
                style: textTheme.bodyMedium?.copyWith(color: colors.onSurface.withValues(alpha: 0.5)),
              ),
            ),
          );
        }

        return Column(
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.posts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.78,
              ),
              itemBuilder: (context, index) {
                final post = provider.posts[index];
                final statusInfo = PostStatusTranslator.translate(post.status);

                return PostCardWidget(
                  imageUrl: post.mainPhotoUrl,
                  title: post.publicationType == 'waste' ? 'Residuo' : 'Objeto',
                  subtitle: post.publishedAt,
                  statusLabel: statusInfo.label,
                  statusColor: statusInfo.color,
                  viewsCount: post.viewsCount,
                  offersCount: post.offerCount,
                  onTap: post.publicationType == 'waste'
                      ? () => context.push('/wasteDetail/${post.id}')
                      : null,
                  onMenuTap: () => _onMenuTap(post.id, post.publicationType, post.status),
                );
              },
            ),
            if (provider.isLoadingMore)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

}
