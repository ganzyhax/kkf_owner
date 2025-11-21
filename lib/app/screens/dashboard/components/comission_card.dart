// lib/screens/owner/dashboard/components/commission_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CommissionCard extends StatelessWidget {
  final Map<String, dynamic> commission;
  final VoidCallback? onPayPressed;

  const CommissionCard({Key? key, required this.commission, this.onPayPressed})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalDue = commission['totalDue'] ?? 0;
    final isBlocked = commission['isBlocked'] ?? false;
    final warningLevel = commission['warningLevel'] ?? 0;
    final commissions = commission['commissions'] as List<dynamic>? ?? [];
    final nearestOverdue =
        commission['nearestOverdue'] as Map<String, dynamic>?;

    // Определяем цвет карточки в зависимости от статуса
    Color cardColor;
    Color accentColor;
    IconData statusIcon;
    String statusText;

    if (isBlocked) {
      cardColor = const Color(0xFFFEF2F2);
      accentColor = const Color(0xFFDC2626);
      statusIcon = Icons.block;
      statusText = 'Заблокировано';
    } else if (warningLevel >= 2) {
      cardColor = const Color(0xFFFEF3C7);
      accentColor = const Color(0xFFF59E0B);
      statusIcon = Icons.warning;
      statusText = 'Срочно требуется оплата';
    } else if (totalDue > 0) {
      cardColor = const Color(0xFFFEF3C7);
      accentColor = const Color(0xFFF59E0B);
      statusIcon = Icons.info_outline;
      statusText = 'Требуется оплата';
    } else {
      cardColor = const Color(0xFFF0FDF4);
      accentColor = const Color(0xFF059669);
      statusIcon = Icons.check_circle_outline;
      statusText = 'Все оплачено';
    }

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(statusIcon, color: accentColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Статус комиссий',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (totalDue > 0) ...[
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),

            // Total Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Сумма к оплате:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
                Text(
                  '${NumberFormat('#,###').format(totalDue)} ₸',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
              ],
            ),

            // Nearest Overdue Warning
            if (nearestOverdue != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: accentColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time, color: accentColor, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Просрочено на ${nearestOverdue['daysOverdue']} дней',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: accentColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Сумма: ${NumberFormat('#,###').format(nearestOverdue['amount'])} ₸',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Commission List
            if (commissions.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                'Детали комиссий (${commissions.length}):',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 12),
              ...commissions.take(3).map((comm) {
                final amount = comm['amount'] ?? 0;
                final dueDate = comm['dueDate'];
                final status = comm['status'] ?? 'pending';
                final daysOverdue = comm['daysOverdue'] ?? 0;

                String dueDateText = 'Не указана';
                if (dueDate != null) {
                  try {
                    final date = DateTime.parse(dueDate);
                    dueDateText = DateFormat('dd.MM.yyyy').format(date);
                  } catch (e) {
                    dueDateText = dueDate.toString();
                  }
                }

                Color statusColor = Colors.grey;
                String statusLabel = '';

                if (status == 'overdue' || status == 'blocked') {
                  statusColor = const Color(0xFFDC2626);
                  statusLabel = 'Просрочено ($daysOverdue дн.)';
                } else if (status == 'pending') {
                  statusColor = const Color(0xFFF59E0B);
                  statusLabel = 'Ожидает оплаты';
                } else {
                  statusColor = const Color(0xFF059669);
                  statusLabel = 'Оплачено';
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${NumberFormat('#,###').format(amount)} ₸',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1F2937),
                                  ),
                                ),
                                Text(
                                  statusLabel,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: statusColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Срок: $dueDateText',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),

              if (commissions.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'И еще ${commissions.length - 3} комиссий...',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],

            // Pay Button
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isBlocked ? null : onPayPressed,
                icon: Icon(isBlocked ? Icons.block : Icons.payment, size: 20),
                label: Text(
                  isBlocked ? 'Аккаунт заблокирован' : 'Оплатить комиссию',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isBlocked ? Colors.grey : accentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),

            if (isBlocked)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Color(0xFFDC2626),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Ваш аккаунт заблокирован из-за неоплаты. Пожалуйста, свяжитесь с поддержкой.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
