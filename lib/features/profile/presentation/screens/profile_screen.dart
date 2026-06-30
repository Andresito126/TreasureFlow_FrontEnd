import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:treasureflow/features/profile/presentation/providers/profile_posts_provider.dart';
import 'package:treasureflow/shared/utils/post_status_translator.dart';
import 'package:treasureflow/shared/widgets/floating_nav_bar_widget.dart';
import 'package:treasureflow/shared/widgets/post_card_widget.dart';
import 'package:treasureflow/shared/widgets/post_filter_bar_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final int _currentNavIndex = 1;
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
            child: Row(
              children: [
                _topIconButton(Icons.notifications_outlined, colors, badgeCount: 3),
                const SizedBox(width: 8),
                _topIconButton(
                  Icons.settings_outlined,
                  colors,
                  onTap: () => context.push('/settingsCitizen'),
                ),
              ],
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FloatingNavBarWidget(
              currentIndex: _currentNavIndex,
              onTap: (index) {
                if (index == 0) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ),
        ],
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
            child: Container(
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
                child: Icon(Icons.person, size: 40, color: colors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameSection(ColorScheme colors, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Carlos Méndez',
          style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 2),
        Text(
          '@carlosmendez',
          style: textTheme.bodySmall?.copyWith(color: colors.onSurface.withValues(alpha: 0.5)),
        ),
      ],
    );
  }

  Widget _topIconButton(IconData icon, ColorScheme colors, {int? badgeCount, VoidCallback? onTap}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: 0.9),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: colors.onSurface),
          ),
        ),
        if (badgeCount != null && badgeCount > 0)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                '$badgeCount',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
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
                  onMenuTap: () {},
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
