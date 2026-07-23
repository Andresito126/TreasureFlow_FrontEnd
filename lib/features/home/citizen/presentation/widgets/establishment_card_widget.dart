import 'package:flutter/material.dart';
import 'package:treasureflow/shared/widgets/premium_badge_widget.dart';

class EstablishmentCardWidget extends StatelessWidget {
  final String name;
  final String distance;
  final double rating;
  final int reviewCount;
  final List<String> materials;
  final bool isPremium;
  final bool isOpen;
  final String? photoUrl;
  final VoidCallback? onTap;

  const EstablishmentCardWidget({
    super.key,
    required this.name,
    required this.distance,
    required this.rating,
    required this.reviewCount,
    required this.materials,
    this.isPremium = false,
    this.isOpen = true,
    this.photoUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.sizeOf(context).width * 0.46,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.outline.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
              child: Container(
                height: 90,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                ),
                child: Stack(
                  children: [
                    if (photoUrl != null)
                      Positioned.fill(
                        child: Image.network(
                          photoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Center(
                            child: Icon(
                              Icons.storefront,
                              size: 36,
                              color: colors.primary.withValues(alpha: 0.4),
                            ),
                          ),
                        ),
                      )
                    else
                      Center(
                        child: Icon(
                          Icons.storefront,
                          size: 36,
                          color: colors.primary.withValues(alpha: 0.4),
                        ),
                      ),
                    Positioned(
                      left: 8,
                      bottom: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF293647),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 10,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              distance,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isPremium) ...[
                    const SizedBox(width: 6),
                    const PremiumBadgeWidget(),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 0),
              child: Wrap(
                spacing: 5,
                runSpacing: 4,
                children: materials.take(3).map((m) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: colors.onSurface.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      m,
                      style: TextStyle(fontSize: 10, color: colors.onSurface),
                    ),
                  );
                }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Row(
                children: [
                  const Icon(Icons.star, size: 14, color: Color(0xFFF5A623)),
                  const SizedBox(width: 3),
                  Text(
                    '$rating',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFFF5A623),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '($reviewCount)',
                    style: TextStyle(
                      fontSize: 10,
                      color: colors.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isOpen
                          ? colors.primary.withValues(alpha: 0.5)
                          : colors.error.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isOpen ? 'Abierto' : 'Cerrado',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
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
}
