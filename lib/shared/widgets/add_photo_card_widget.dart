import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';

class AddPhotoCardWidget extends StatelessWidget {
  const AddPhotoCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return DottedBorder(
      options: RoundedRectDottedBorderOptions(
        color: theme.colorScheme.outline,
        strokeWidth: 1.5,
        dashPattern: const [9, 4],
        radius: const Radius.circular(12),
      ),
      child: Container(
        width: double.infinity, 
        height: 90, 
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              color: Colors.grey.shade400,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              'Agregar foto',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}