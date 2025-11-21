// lib/screens/owner/components/arena_status_badge.dart
import 'package:flutter/material.dart';

class ArenaStatusBadge extends StatelessWidget {
  final String status; // ← Изменено с ArenaStatus на String

  const ArenaStatusBadge({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        config.text,
        style: TextStyle(
          color: config.textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  _StatusConfig _getStatusConfig() {
    // Приводим к нижнему регистру для сравнения
    switch (status.toLowerCase()) {
      case 'active':
      case 'approved':
        return _StatusConfig(
          text: 'Активна',
          backgroundColor: const Color(0xFFD1FAE5),
          textColor: const Color(0xFF065F46),
        );
      case 'moderation':
      case 'pending':
        return _StatusConfig(
          text: 'Модерация',
          backgroundColor: const Color(0xFFFEF3C7),
          textColor: const Color(0xFF92400E),
        );
      case 'inactive':
      case 'rejected':
      case 'blocked':
        return _StatusConfig(
          text: 'Неактивна',
          backgroundColor: const Color(0xFFFEE2E2),
          textColor: const Color(0xFF991B1B),
        );
      default:
        return _StatusConfig(
          text: status,
          backgroundColor: const Color(0xFFE5E7EB),
          textColor: const Color(0xFF374151),
        );
    }
  }
}

class _StatusConfig {
  final String text;
  final Color backgroundColor;
  final Color textColor;

  _StatusConfig({
    required this.text,
    required this.backgroundColor,
    required this.textColor,
  });
}
