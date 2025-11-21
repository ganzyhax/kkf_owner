// lib/screens/finance/finance_dashboard.dart
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kff_owner_admin/app/screens/finance/bloc/finance_bloc.dart';

class FinanceDashboard extends StatelessWidget {
  const FinanceDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FinanceBloc()
        ..add(
          FinanceLoad(
            startDate: DateTime.now().subtract(const Duration(days: 30)),
            endDate: DateTime.now(),
          ),
        ),
      child: const _FinanceDashboardContent(),
    );
  }
}

class _FinanceDashboardContent extends StatefulWidget {
  const _FinanceDashboardContent();

  @override
  State<_FinanceDashboardContent> createState() =>
      _FinanceDashboardContentState();
}

class _FinanceDashboardContentState extends State<_FinanceDashboardContent> {
  DateTime startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime endDate = DateTime.now();
  String searchQuery = '';
  String sortOption = 'dateDesc';
  String? selectedArenaId;

  void _loadData() {
    context.read<FinanceBloc>().add(
      FinanceLoad(
        startDate: startDate,
        endDate: endDate,
        arenaId: selectedArenaId,
      ),
    );
  }

  Future<void> _refreshData() async {
    context.read<FinanceBloc>().add(
      FinanceRefresh(
        startDate: startDate,
        endDate: endDate,
        arenaId: selectedArenaId,
      ),
    );
  }

  void _showCompactDatePicker(BuildContext context, bool isMobile) async {
    DateTime? tempStartDate = startDate;
    DateTime? tempEndDate = endDate;

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                constraints: BoxConstraints(
                  maxWidth: isMobile ? double.infinity : 400,
                  maxHeight: isMobile
                      ? MediaQuery.of(context).size.height * 0.8
                      : 600,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Выберите период',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(dialogContext).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Start Date
                    Text(
                      'Дата начала:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: dialogContext,
                          initialDate: tempStartDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setDialogState(() {
                            tempStartDate = picked;
                            if (tempEndDate != null &&
                                picked.isAfter(tempEndDate!)) {
                              tempEndDate = picked;
                            }
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.shade50,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 18,
                              color: Colors.blue.shade600,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              DateFormat(
                                'dd MMMM yyyy',
                              ).format(tempStartDate ?? DateTime.now()),
                              style: TextStyle(
                                color: Colors.grey.shade800,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // End Date
                    Text(
                      'Дата окончания:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: dialogContext,
                          initialDate: tempEndDate ?? DateTime.now(),
                          firstDate: tempStartDate ?? DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setDialogState(() {
                            tempEndDate = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.shade50,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 18,
                              color: Colors.blue.shade600,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              DateFormat(
                                'dd MMMM yyyy',
                              ).format(tempEndDate ?? DateTime.now()),
                              style: TextStyle(
                                color: Colors.grey.shade800,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Quick Select Buttons
                    Text(
                      'Быстрый выбор:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildQuickSelectChip('Сегодня', () {
                          setDialogState(() {
                            tempStartDate = DateTime.now();
                            tempEndDate = DateTime.now();
                          });
                        }),
                        _buildQuickSelectChip('Этот месяц', () {
                          final now = DateTime.now();
                          setDialogState(() {
                            tempStartDate = DateTime(now.year, now.month, 1);
                            tempEndDate = DateTime(now.year, now.month + 1, 0);
                          });
                        }),
                        _buildQuickSelectChip('Последние 30 дней', () {
                          final now = DateTime.now();
                          setDialogState(() {
                            tempStartDate = now.subtract(
                              const Duration(days: 30),
                            );
                            tempEndDate = now;
                          });
                        }),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('Отмена'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (tempStartDate != null &&
                                  tempEndDate != null) {
                                setState(() {
                                  startDate = tempStartDate!;
                                  endDate = tempEndDate!;
                                });
                                _loadData();
                              }
                              Navigator.of(dialogContext).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('Применить'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildQuickSelectChip(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.blue.shade700,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _exportToCsv() {
    context.read<FinanceBloc>().add(
      FinanceExportCSV(
        startDate: startDate,
        endDate: endDate,
        arenaId: selectedArenaId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: BlocListener<FinanceBloc, FinanceState>(
          listener: (context, state) {
            if (state is FinanceExportSuccess) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            } else if (state is FinanceError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 768;

              return RefreshIndicator(
                onRefresh: _refreshData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.all(isMobile ? 16.0 : 32.0),
                    child: BlocBuilder<FinanceBloc, FinanceState>(
                      builder: (context, state) {
                        if (state is FinanceLoading) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(64.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        if (state is FinanceError) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(64.0),
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    size: 64,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    state.message,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: _loadData,
                                    child: const Text('Повторить'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        if (state is FinanceLoaded) {
                          final summary = state.summary;
                          final transactions = state.filteredTransactions;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeader(context, isMobile),
                              SizedBox(height: isMobile ? 24 : 32),
                              _buildMainRevenueRow(isMobile, summary),
                              SizedBox(height: isMobile ? 16 : 24),
                              _buildBookingsRow(isMobile, summary),
                              SizedBox(height: isMobile ? 16 : 24),
                              _buildPaymentMethodsRow(isMobile, summary),
                              SizedBox(height: isMobile ? 24 : 32),
                              _buildTransactionsSection(
                                context,
                                isMobile,
                                transactions,
                              ),
                            ],
                          );
                        }

                        return const SizedBox();
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Финансы',
                    style: TextStyle(
                      fontSize: isMobile ? 24 : 36,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${DateFormat('dd.MM.yyyy').format(startDate)} - ${DateFormat('dd.MM.yyyy').format(endDate)}',
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _refreshData,
                  tooltip: 'Обновить',
                  iconSize: isMobile ? 24 : 28,
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: _exportToCsv,
                  tooltip: 'Экспорт CSV',
                  iconSize: isMobile ? 24 : 28,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMainRevenueRow(bool isMobile, Map<String, dynamic> s) {
    final cards = [
      {
        'label': 'Общий доход',
        'value': s['grossRevenue'],
        'color': Colors.green.shade700,
        'icon': Icons.paid_rounded,
        'subtitle': 'До вычета комиссий',
      },
      {
        'label': 'Комиссия платформы',
        'value': s['platformCommission'],
        'color': Colors.red.shade600,
        'icon': Icons.percent_rounded,
        'subtitle': 'Плата за обслуживание',
      },
      {
        'label': 'Чистый доход',
        'value': s['netRevenue'],
        'color': Colors.teal.shade700,
        'icon': Icons.account_balance_wallet_rounded,
        'subtitle': 'На руки',
      },
    ];

    return _buildCardRow(isMobile, cards);
  }

  Widget _buildBookingsRow(bool isMobile, Map<String, dynamic> s) {
    final bookings = s['bookings'] ?? {};
    final pending = s['pending'] ?? {};
    log(s.toString() + 'adadad!!!!');
    final cards = [
      {
        'label': 'Бронирования',
        'value': bookings['total'],
        'color': Colors.blue.shade700,
        'icon': Icons.calendar_today_rounded,
        'subtitle': 'Всего бронирований',
      },
      {
        'label': 'В ожидании',
        'value': s['pending']['totalRevenue'],
        'color': Colors.orange.shade600,
        'icon': Icons.timelapse_rounded,
        'subtitle': 'Неоплаченные',
      },
      {
        'label': 'Предоплата',
        'value': s['prepaid']['total'],
        'color': Colors.purple.shade600,
        'icon': Icons.payment_rounded,
        'subtitle': 'Ожидает оплаты',
      },
    ];

    return _buildCardRow(isMobile, cards);
  }

  Widget _buildPaymentMethodsRow(bool isMobile, Map<String, dynamic> s) {
    final online = s['online'] ?? {};
    final offline = s['offline'] ?? {};

    final cards = [
      {
        'label': 'Через платформу',
        'value': online['grossRevenue'],
        'color': Colors.indigo.shade600,
        'icon': Icons.credit_card_rounded,
        'subtitle': '${online['bookings'] ?? 0} бронирований',
      },
      {
        'label': 'Вне платформы',
        'value': offline['grossRevenue'],
        'color': Colors.amber.shade700,
        'icon': Icons.storefront_rounded,
        'subtitle': '${offline['bookings'] ?? 0} бронирований',
      },
    ];

    return _buildCardRow(isMobile, cards);
  }

  Widget _buildCardRow(bool isMobile, List<Map<String, dynamic>> cards) {
    return Row(
      children: cards.map((card) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: _buildEnhancedSummaryCard(
              card['label']!,
              _formatCurrency(
                card['value'],
                withSign: (card['label'] == 'Бронирования') ? false : true,
              ),
              card['color']!,
              card['icon']!,
              card['subtitle']!,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEnhancedSummaryCard(
    String label,
    String value,
    Color color,
    IconData icon,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsSection(
    BuildContext context,
    bool isMobile,
    List<Map<String, dynamic>> transactions,
  ) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Транзакции',
                style: TextStyle(
                  fontSize: isMobile ? 20 : 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.download, color: Colors.grey.shade600),
                    onPressed: _exportToCsv,
                    tooltip: 'Экспорт CSV',
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _showCompactDatePicker(context, isMobile),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade50,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${DateFormat('dd.MM.yyyy').format(startDate)} - ${DateFormat('dd.MM.yyyy').format(endDate)}',
                            style: TextStyle(
                              color: Colors.grey.shade800,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_drop_down,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            onChanged: (value) {
              context.read<FinanceBloc>().add(FinanceSearch(value));
            },
            decoration: InputDecoration(
              hintText: 'Поиск по имени, арене или телефону...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (transactions.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(48.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Транзакции не найдены',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            _buildTransactionsList(isMobile, transactions),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(
    bool isMobile,
    List<Map<String, dynamic>> transactions,
  ) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        final dateStr = transaction['date']?.toString() ?? '';
        final date = dateStr.isNotEmpty
            ? DateTime.tryParse(dateStr) ?? DateTime.now()
            : DateTime.now();

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: (transaction['paymentType'] == 'online')
                ? Colors.blue.shade50
                : Colors.orange.shade50,
            child: Icon(
              transaction['paymentType'] == 'online'
                  ? Icons.credit_card
                  : Icons.storefront,
              color: (transaction['paymentType'] == 'online')
                  ? Colors.blue.shade600
                  : Colors.orange.shade600,
              size: 20,
            ),
          ),
          title: Text(
            transaction['clientName']?.toString() ?? 'N/A',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            '${transaction['arena'] ?? 'N/A'} • ${DateFormat('dd.MM.yyyy').format(date)}\n${transaction['startTime'] ?? ''} - ${transaction['endTime'] ?? ''}',
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatCurrency(transaction['amount']),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
              Text(
                transaction['paymentType'] == 'online' ? 'Онлайн' : 'Оффлайн',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
              // Text(
              //   transaction['paymentStatus'] == 'PartiallyPaid'
              //       ? 'Предоплата'
              //       : transaction['paymentStatus'] == 'FullyPaid'
              //       ? 'Полная оплата'
              //       : '',
              //   style: TextStyle(color: Colors.grey.shade500, fontSize: 6),
              // ),
            ],
          ),
          isThreeLine: true,
        );
      },
    );
  }

  String _formatCurrency(dynamic amount, {bool withSign = true}) {
    final formatter = NumberFormat('#,###');
    final numAmount = (amount is num) ? amount : 0;
    final prefix = '';
    return (withSign)
        ? '$prefix${formatter.format(numAmount)} ₸'
        : '$prefix${formatter.format(numAmount)}';
  }
}
