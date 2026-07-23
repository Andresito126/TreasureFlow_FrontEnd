import 'package:flutter/material.dart';

class SettingsProfileCardWidget extends StatefulWidget {
  final String name;
  final String email;
  final String? avatarUrl;
  final IconData fallbackIcon;
  final VoidCallback onTap;

  const SettingsProfileCardWidget({
    super.key,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.fallbackIcon = Icons.person,
    required this.onTap,
  });

  @override
  State<SettingsProfileCardWidget> createState() =>
      _SettingsProfileCardWidgetState();
}

class _SettingsProfileCardWidgetState extends State<SettingsProfileCardWidget> {
  bool _imageFailed = false;

  @override
  void didUpdateWidget(covariant SettingsProfileCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.avatarUrl != widget.avatarUrl) _imageFailed = false;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final showAvatar = widget.avatarUrl != null && !_imageFailed;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.outline.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: colors.primary.withValues(alpha: 0.1),
              backgroundImage: showAvatar
                  ? NetworkImage(widget.avatarUrl!)
                  : null,
              onBackgroundImageError: showAvatar
                  ? (_, _) => setState(() => _imageFailed = true)
                  : null,
              child: !showAvatar
                  ? Icon(widget.fallbackIcon, size: 28, color: colors.primary)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.email,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: colors.onSurface.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }
}
