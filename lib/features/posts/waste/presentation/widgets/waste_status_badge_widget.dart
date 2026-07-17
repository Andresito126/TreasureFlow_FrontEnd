import 'package:flutter/material.dart';
import 'package:treasureflow/shared/utils/post_status_translator.dart';

class WasteStatusBadge extends StatelessWidget {
  final String status;
  const WasteStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final info = PostStatusTranslator.translate(status);
    final textTheme = Theme.of(context).textTheme;
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
}
