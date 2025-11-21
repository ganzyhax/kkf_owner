// lib/screens/owner/commission/commission_screen.dart
import 'package:flutter/material.dart';
import 'package:kff_owner_admin/app/api/api.dart';
import 'package:intl/intl.dart';

class CommissionScreen extends StatefulWidget {
  const CommissionScreen({Key? key}) : super(key: key);

  @override
  State<CommissionScreen> createState() => _CommissionScreenState();
}

class _CommissionScreenState extends State<CommissionScreen> {
  bool isLoading = true;
  Map<String, dynamic>? commissionData;
  String? errorMessage;
  int selectedTab = 0; // 0 = Неоплаченные, 1 = История

  @override
  void initState() {
    super.initState();
    _loadCommissionData();
  }

  Future<void> _loadCommissionData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await ApiClient.get('api/commission/dashboard');

      if (response['success'] == true) {
        setState(() {
          commissionData = response['data'];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = response['message'] ?? 'Ошибка загрузки данных';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _generateInvoice() async {
    try {
      final response = await ApiClient.post('api/commission/generate', {});

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Счет на комиссию создан'),
            backgroundColor: Colors.green,
          ),
        );
        _loadCommissionData();
      } else {
        throw Exception(response['message']);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Ошибка: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _payCommission(String commissionId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Подтверждение оплаты'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Отсканируйте QR код для оплаты через Kaspi'),
            const SizedBox(height: 16),
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'QR КОД\n(В РАЗРАБОТКЕ)',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Я оплатил'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final response = await ApiClient.post(
        'api/commission/$commissionId/pay',
        {'paymentMethod': 'kaspi_qr', 'paymentProof': 'manual_confirmation'},
      );

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Комиссия успешно оплачена'),
            backgroundColor: Colors.green,
          ),
        );
        _loadCommissionData();
      } else {
        throw Exception(response['message']);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Ошибка: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF9FAFB),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[700],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Комиссии и Платежи',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      'Управление комиссиями с онлайн бронирований',
                      style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadCommissionData,
                  tooltip: 'Обновить',
                ),
              ],
            ),

            const SizedBox(height: 32),

            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(64.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (errorMessage != null)
              Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text('Ошибка: $errorMessage'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadCommissionData,
                      child: const Text('Повторить'),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: [
                  // Сводка
                  _buildSummaryCards(),

                  const SizedBox(height: 32),

                  // Табы
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildTabButton(
                                  'Неоплаченные',
                                  0,
                                  Icons.pending_actions,
                                ),
                              ),
                              Expanded(
                                child: _buildTabButton(
                                  'История платежей',
                                  1,
                                  Icons.history,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(24),
                          child: selectedTab == 0
                              ? _buildUnpaidTab()
                              : _buildHistoryTab(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    final summary = commissionData?['summary'] ?? {};
    final isBlocked = summary['isBlocked'] ?? false;
    final warningLevel = summary['warningLevel'] ?? 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 1200
            ? 4
            : constraints.maxWidth > 768
            ? 2
            : 1;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 2.5,
          children: [
            _buildSummaryCard(
              'К оплате',
              '${summary['totalDue'] ?? 0} ₸',
              isBlocked
                  ? Colors.red
                  : warningLevel > 0
                  ? Colors.orange
                  : Colors.blue,
              Icons.payment,
            ),
            _buildSummaryCard(
              'Оплачено всего',
              '${summary['totalPaid'] ?? 0} ₸',
              Colors.green,
              Icons.check_circle,
            ),
            _buildSummaryCard(
              'Ожидает начисления',
              '${summary['potentialCommission'] ?? 0} ₸',
              Colors.purple,
              Icons.hourglass_empty,
            ),
            _buildSummaryCard(
              'Статус',
              isBlocked
                  ? 'БЛОКИРОВКА'
                  : summary['overdueCount'] > 0
                  ? 'ПРОСРОЧКА'
                  : 'Активен',
              isBlocked
                  ? Colors.red
                  : summary['overdueCount'] > 0
                  ? Colors.orange
                  : Colors.green,
              isBlocked ? Icons.block : Icons.check_circle_outline,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, int index, IconData icon) {
    final isSelected = selectedTab == index;
    return InkWell(
      onTap: () => setState(() => selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.blue[700] : Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? Colors.blue[700] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnpaidTab() {
    final commissions = commissionData?['commissions'] ?? {};
    final pending = commissions['pending'] as List? ?? [];
    final overdue = commissions['overdue'] as List? ?? [];
    final blocked = commissions['blocked'] as List? ?? [];

    final all = [...blocked, ...overdue, ...pending];

    if (all.isEmpty) {
      return _buildEmptyState(
        'Нет неоплаченных комиссий',
        'У вас нет задолженности. Отлично!',
        Icons.check_circle_outline,
        Colors.green,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Счета к оплате',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _generateInvoice,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Создать новый счет'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...all.map((commission) => _buildCommissionCard(commission)),
      ],
    );
  }

  Widget _buildHistoryTab() {
    final commissions = commissionData?['commissions'] ?? {};
    final paid = commissions['paid'] as List? ?? [];

    if (paid.isEmpty) {
      return _buildEmptyState(
        'История пуста',
        'Здесь будут отображаться оплаченные комиссии',
        Icons.history,
        Colors.grey,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Оплаченные комиссии',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        ...paid.map(
          (commission) => _buildCommissionCard(commission, isPaid: true),
        ),
      ],
    );
  }

  Widget _buildCommissionCard(
    Map<String, dynamic> commission, {
    bool isPaid = false,
  }) {
    final status = commission['status'] as String;
    final daysOverdue = commission['daysOverdue'] ?? 0;
    final warningLevel = commission['warningLevel'] ?? 0;

    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status) {
      case 'blocked':
        statusColor = Colors.red;
        statusIcon = Icons.block;
        statusText = 'ЗАБЛОКИРОВАНО';
        break;
      case 'overdue':
        statusColor = Colors.orange;
        statusIcon = Icons.warning;
        statusText = 'ПРОСРОЧЕНО ($daysOverdue дн.)';
        break;
      case 'pending':
        statusColor = Colors.blue;
        statusIcon = Icons.pending;
        statusText = 'К оплате';
        break;
      case 'paid':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Оплачено';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
        statusText = status;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Период: ${_formatDate(commission['period']['start'])} - ${_formatDate(commission['period']['end'])}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 14,
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${commission['totalCommission']} ₸',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _buildDetailRow(
                  'Онлайн выручка:',
                  '${commission['onlineRevenue']} ₸',
                ),
                _buildDetailRow(
                  'Оффлайн выручка:',
                  '${commission['offlineRevenue']} ₸ (без комиссии)',
                ),
                const Divider(height: 16),
                _buildDetailRow(
                  'Комиссия онлайн (12%):',
                  '${commission['onlineCommission']} ₸',
                  bold: true,
                ),
                _buildDetailRow(
                  'Комиссия оффлайн:',
                  '${commission['offlineCommission']} ₸ (0%)',
                  bold: true,
                ),
                const Divider(height: 16),
                _buildDetailRow(
                  'Платформа (8%):',
                  '${commission['platformShare']} ₸',
                ),
                _buildDetailRow(
                  'Кэшбек юзерам (4%):',
                  '${commission['userCashback']} ₸',
                ),
              ],
            ),
          ),
          if (!isPaid) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _payCommission(commission['id']),
                    icon: const Icon(Icons.payment),
                    label: const Text('ОПЛАТИТЬ СЕЙЧАС'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: statusColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () => _showCommissionDetails(commission),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: statusColor,
                    side: BorderSide(color: statusColor),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Детали'),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Оплачено: ${_formatDate(commission['paidAt'])}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: bold ? FontWeight.bold : FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(64.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: color.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showCommissionDetails(Map<String, dynamic> commission) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Детали комиссии',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoSection(
                'Период',
                '${_formatDate(commission['period']['start'])} - ${_formatDate(commission['period']['end'])}',
                Icons.calendar_today,
                Colors.blue,
              ),
              const SizedBox(height: 16),
              _buildInfoSection(
                'Общая сумма',
                '${commission['totalCommission']} ₸',
                Icons.account_balance_wallet,
                Colors.green,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Детализация:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      'Онлайн выручка:',
                      '${commission['onlineRevenue']} ₸',
                    ),
                    _buildDetailRow(
                      'Оффлайн выручка:',
                      '${commission['offlineRevenue']} ₸',
                    ),
                    const Divider(height: 16),
                    _buildDetailRow(
                      'Онлайн комиссия (12%):',
                      '${commission['onlineCommission']} ₸',
                      bold: true,
                    ),
                    _buildDetailRow(
                      'Оффлайн комиссия:',
                      '${commission['offlineCommission']} ₸ (0%)',
                      bold: true,
                    ),
                    const Divider(height: 16),
                    _buildDetailRow(
                      'Платформа (8%):',
                      '${commission['platformShare']} ₸',
                    ),
                    _buildDetailRow(
                      'Кэшбек юзерам (4%):',
                      '${commission['userCashback']} ₸',
                    ),
                  ],
                ),
              ),
              if (commission['status'] != 'paid') ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Срок оплаты: ${_formatDate(commission['dueDate'])}',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
          if (commission['status'] != 'paid')
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _payCommission(commission['id']);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Оплатить'),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return '';
    try {
      final dt = DateTime.parse(date.toString());
      return DateFormat('dd.MM.yyyy').format(dt);
    } catch (e) {
      return date.toString();
    }
  }
}
