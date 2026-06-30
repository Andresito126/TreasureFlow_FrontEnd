import 'package:flutter/material.dart';

class ImageGalleryWidget extends StatefulWidget {
  final List<String> imageUrls;
  final VoidCallback? onBack;
  final ValueChanged<int>? onImageTap;

  const ImageGalleryWidget({
    super.key,
    required this.imageUrls,
    this.onBack,
    this.onImageTap,
  });

  @override
  State<ImageGalleryWidget> createState() => _ImageGalleryWidgetState();
}

class _ImageGalleryWidgetState extends State<ImageGalleryWidget> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: screenWidth * 0.55,
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: widget.imageUrls.length,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                itemBuilder: (context, index) {
                  final url = widget.imageUrls[index];
                  final isNetworkUrl = url.startsWith('http');

                  return GestureDetector(
                    onTap: isNetworkUrl && widget.onImageTap != null
                        ? () => widget.onImageTap!(index)
                        : null,
                    child: Container(
                      color: colors.primary.withValues(alpha: 0.08),
                      child: isNetworkUrl
                          ? Image.network(
                              url,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Center(
                                child: Icon(
                                  Icons.image_outlined,
                                  size: 60,
                                  color: colors.primary.withValues(alpha: 0.3),
                                ),
                              ),
                            )
                          : Center(
                              child: Icon(
                                Icons.image_outlined,
                                size: 60,
                                color: colors.primary.withValues(alpha: 0.3),
                              ),
                            ),
                    ),
                  );
                },
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 16,
                child: GestureDetector(
                  onTap: widget.onBack ?? () => Navigator.maybePop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colors.outline.withValues(alpha: 0.3)),
                    ),
                    child: Icon(Icons.arrow_back, size: 20, color: colors.onSurface),
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B2430),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_currentIndex + 1} / ${widget.imageUrls.length}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(widget.imageUrls.length, (index) {
                final isActive = _currentIndex == index;
                final url = widget.imageUrls[index];
                final isNetworkUrl = url.startsWith('http');

                return GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    width: 60,
                    height: 50,
                    margin: EdgeInsets.only(right: index < widget.imageUrls.length - 1 ? 8 : 0),
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isActive ? colors.primary : Colors.transparent,
                        width: isActive ? 2 : 0,
                      ),
                      color: colors.primary.withValues(alpha: 0.06),
                    ),
                    child: isNetworkUrl
                        ? Image.network(
                            url,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.image_outlined,
                              size: 20,
                              color: colors.primary.withValues(alpha: 0.3),
                            ),
                          )
                        : Center(
                            child: Icon(
                              Icons.image_outlined,
                              size: 20,
                              color: colors.primary.withValues(alpha: 0.3),
                            ),
                          ),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}