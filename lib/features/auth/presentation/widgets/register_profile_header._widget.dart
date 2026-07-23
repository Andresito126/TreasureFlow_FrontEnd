import 'package:flutter/material.dart';

class RegisterProfileHeaderWidget extends StatelessWidget {
  final VoidCallback onEditPhoto;

  const RegisterProfileHeaderWidget({super.key, required this.onEditPhoto});

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
            decoration: BoxDecoration(
              color: colors.surfaceVariant, // Placeholder color
            ),
            // child: SvgPicture.asset(
            //   'assets/images/banner_placeholder.svg',
            //   fit: BoxFit.cover,
            // ),
          ),

          Positioned(
            bottom: 0,
            child: GestureDetector(
              onTap: onEditPhoto,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.surface,
                      border: Border.all(
                        color: theme.scaffoldBackgroundColor,
                        width: 4,
                      ),
                    ),
                    child: ClipOval(
                      // child: Image.asset(
                      //   'assets/images/basurini_avatar.png',
                      //   fit: BoxFit.cover,
                      // ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: colors.secondary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.scaffoldBackgroundColor,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 14,
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
