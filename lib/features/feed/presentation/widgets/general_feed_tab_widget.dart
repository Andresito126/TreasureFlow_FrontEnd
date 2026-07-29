import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:treasureflow/features/feed/presentation/providers/feed_provider.dart';
import 'package:treasureflow/features/posts/waste/navigation/waste_detail_navigation.dart';
import 'package:treasureflow/shared/utils/material_type_translator.dart';
import 'package:treasureflow/shared/utils/post_status_translator.dart';
import 'package:treasureflow/shared/utils/responsive_grid.dart';
import 'package:treasureflow/shared/widgets/post_card_widget.dart';

class GeneralFeedTabWidget extends StatefulWidget {
  const GeneralFeedTabWidget({super.key});

  @override
  State<GeneralFeedTabWidget> createState() => _GeneralFeedTabWidgetState();
}

class _GeneralFeedTabWidgetState extends State<GeneralFeedTabWidget> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeedProvider>().loadPosts();
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
      context.read<FeedProvider>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SafeArea(
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Explorar',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Publicaciones disponibles cerca de ti',
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          Consumer<FeedProvider>(
            builder: (context, provider, _) {
              if (provider.status == FeedStatus.loading) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (provider.status == FeedStatus.error) {
                return SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: colors.error.withValues(alpha: 0.6),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            provider.errorMessage ?? 'Error al cargar',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colors.error,
                            ),
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
                  ),
                );
              }

              if (provider.posts.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.explore_off_outlined,
                          size: 48,
                          color: colors.onSurface.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Sin publicaciones por ahora',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colors.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
                sliver: SliverGrid(
                  gridDelegate: responsiveGridDelegate(
                    context,
                    crossAxisCount: 2,

                    imageAspectRatio: 1.3,
                    contentHeight: 100,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
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
                      final statusInfo = PostStatusTranslator.translate(
                        post.status,
                      );
                      final title = post.publicationType == 'waste'
                          ? MaterialTypeTranslator.translate('residuo')
                          : 'Objeto';

                      return PostCardWidget(
                        imageUrl: post.mainPhotoUrl,
                        title: title,
                        subtitle: post.publishedAt,
                        statusLabel: statusInfo.label,
                        statusColor: statusInfo.color,
                        viewsCount: post.viewsCount,
                        offersCount: post.offerCount,
                        onTap: post.publicationType == 'waste'
                            ? () => pushWasteDetail(context, post.id)
                            : () => context.push('/objectDetail/${post.id}'),
                      );
                    },
                    childCount:
                        provider.posts.length +
                        (provider.isLoadingMore ? 1 : 0),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
