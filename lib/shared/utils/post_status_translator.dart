import 'package:flutter/material.dart';

class PostStatusInfo {
  final String label;
  final Color color;

  const PostStatusInfo({required this.label, required this.color});
}

class PostStatusTranslator {
  static PostStatusInfo translate(String status) {
    switch (status) {
      case 'active':
        return const PostStatusInfo(label: 'Activa', color: Color(0xFF418839));
      case 'reserved':
        return const PostStatusInfo(label: 'Apartada', color: Color(0xFF30A3F3));
      case 'completed':
        return const PostStatusInfo(label: 'Finalizada', color: Color(0xFF6D53ED));
      case 'cancelled':
        return const PostStatusInfo(label: 'Vencida', color: Color(0xFFE05353));
      case 'pending_moderation':
        return const PostStatusInfo(label: 'En revisión', color: Color(0xFFF59E0B));
      case 'rejected':
        return const PostStatusInfo(label: 'Rechazada', color: Color(0xFFDC2626));
      default:
        return PostStatusInfo(label: status, color: Colors.grey);
    }
  }
}
