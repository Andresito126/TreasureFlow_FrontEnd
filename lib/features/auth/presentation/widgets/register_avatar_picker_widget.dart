import 'dart:io';

import 'package:flutter/material.dart';

class RegisterAvatarPickerWidget extends StatelessWidget {
  final File? selectedImage;
  final VoidCallback onTap;
  final double avatarSize;
  final IconData placeholderIcon;

  const RegisterAvatarPickerWidget({
    super.key,
    required this.selectedImage,
    required this.onTap,
    this.avatarSize = 88,
    this.placeholderIcon = Icons.person,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SizedBox(
      height: 160,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            height: 120,
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(18)),
            child: Image.asset(
              'assets/auth/banner.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: colors.surface,
                child: const Center(child: Icon(Icons.image, size: 50)),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: GestureDetector(
              onTap: onTap,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: avatarSize,
                    height: avatarSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.surface,
                      border: Border.all(color: colors.background, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .10),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: selectedImage != null
                          ? Image.file(selectedImage!, fit: BoxFit.cover)
                          : Image.asset(
                              'assets/auth/basurini_ball.png',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  Icon(placeholderIcon, size: 42),
                            ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: colors.secondary,
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.background, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 15,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
