// lib/screens/owner/components/commission_info_card.dart
import 'package:flutter/material.dart';

/// Информационная карточка о том, как работает комиссия
class CommissionInfoCard extends StatelessWidget {
  const CommissionInfoCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[50]!, Colors.blue[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue[700],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Как работает комиссия',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E40AF),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Онлайн бронирования
          _buildInfoSection(
            icon: Icons.phone_android,
            iconColor: Colors.green,
            title: '📱 Онлайн бронирования',
            subtitle: 'Когда клиент бронирует через приложение',
            items: [
              '• Комиссия: 12% от суммы брони',
              '• 8% — платформе',
              '• 4% — кэшбек пользователю',
            ],
            bgColor: Colors.green[50]!,
          ),

          const SizedBox(height: 16),

          // Оффлайн бронирования
          _buildInfoSection(
            icon: Icons.store,
            iconColor: Colors.orange,
            title: '🏪 Оффлайн бронирования',
            subtitle: 'Когда вы создаете бронь вручную',
            items: [
              '• Комиссия: 0%',
              '• Никаких отчислений',
              '• Вся сумма остается у вас',
            ],
            bgColor: Colors.orange[50]!,
          ),

          const SizedBox(height: 16),

          // Отмена бронирования
          _buildInfoSection(
            icon: Icons.cancel,
            iconColor: Colors.red,
            title: '❌ При отмене брони',
            subtitle: 'Как рассчитывается комиссия',
            items: [
              '• Онлайн: комиссия только с удержанной суммы',
              '• Если возврат 100% → комиссия не берется',
              '• Оффлайн: комиссия всегда 0%',
            ],
            bgColor: Colors.red[50]!,
          ),

          const SizedBox(height: 20),

          // Пример
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.calculate, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Пример расчета',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Онлайн бронь на 10,000 ₸:\n'
                  '• Вы получаете: 8,800 ₸\n'
                  '• Комиссия: 1,200 ₸\n'
                  '  - Платформа: 800 ₸\n'
                  '  - Кэшбек клиенту: 400 ₸\n\n'
                  'Оффлайн бронь на 10,000 ₸:\n'
                  '• Вы получаете: 10,000 ₸\n'
                  '• Комиссия: 0 ₸',
                  style: TextStyle(fontSize: 13, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required List<String> items,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: iconColor.withOpacity(0.9),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                item,
                style: const TextStyle(fontSize: 13, height: 1.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
