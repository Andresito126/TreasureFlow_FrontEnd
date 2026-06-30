import 'package:flutter/material.dart';

class PostCardWidget extends StatelessWidget {
  final String? imageUrl;
  final String title;
  final String subtitle;
  final String statusLabel;
  final Color statusColor;
  final int viewsCount;
  final int offersCount;
  final VoidCallback? onTap;
  final VoidCallback? onMenuTap;

  const PostCardWidget({
    super.key,
    this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.statusLabel,
    required this.statusColor,
    required this.viewsCount,
    required this.offersCount,
    this.onTap,
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.outline.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.3,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: imageUrl != null
                        ? Image.network(imageUrl!, fit: BoxFit.cover)
                        : Container(
                            color: colors.surfaceContainerHighest,
                            child: Icon(Icons.image_outlined, color: colors.onSurface.withValues(alpha: 0.3)),
                          ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        statusLabel,
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                  if (onMenuTap != null)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: IconButton(
                        onPressed: onMenuTap,
                        icon: const Icon(Icons.more_vert, color: Colors.white, size: 20),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black.withValues(alpha: 0.25),
                          minimumSize: const Size(28, 28),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.visibility_outlined, size: 14, color: colors.onSurface.withValues(alpha: 0.5)),
                      const SizedBox(width: 4),
                      Text('$viewsCount', style: textTheme.bodySmall?.copyWith(fontSize: 11)),
                      const SizedBox(width: 12),
                      Icon(Icons.chat_bubble_outline, size: 14, color: colors.onSurface.withValues(alpha: 0.5)),
                      const SizedBox(width: 4),
                      Text('$offersCount ofertas', style: textTheme.bodySmall?.copyWith(fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
