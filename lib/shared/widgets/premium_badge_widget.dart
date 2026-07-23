import 'package:flutter/material.dart';

class PremiumBadgeWidget extends StatelessWidget {
  final double fontSize;

  const PremiumBadgeWidget({super.key, this.fontSize = 8});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF5A623),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'Premium',
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
