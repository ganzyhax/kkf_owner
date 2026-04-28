// lib/screens/finance/finance_dashboard.dart
import 'dart:developer';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kff_owner_admin/app/api/api.dart';
import 'package:kff_owner_admin/app/screens/finance/bloc/finance_bloc.dart';
import 'package:excel/excel.dart' hide Border;

// ✅ ENUM ДЛЯ РЕЖИМОВ ПРОСМОТРА
enum TransactionViewMode {
  byBooking, // По бронированиям
  byPayment, // По платежам
}

// ✅ ENUM ДЛЯ ФИЛЬТРОВ
enum PaymentStatusFilter {
  all, // Все
  paid, // Оплачено
  partial, // Частично
  unpaid, // Не оплачено
}

class FinanceDashboard extends StatelessWidget {
  const FinanceDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FinanceBloc()
        ..add(
          FinanceLoad(
            startDate: DateTime(DateTime.now().year, DateTime.now().month, 1),
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
  DateTime startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime endDate = DateTime.now();

  String searchQuery = '';
  String sortOption = 'dateDesc';
  String? selectedArenaId;

  // ✅ НОВЫЕ СОСТОЯНИЯ
  TransactionViewMode _viewMode = TransactionViewMode.byBooking;
  PaymentStatusFilter _statusFilter = PaymentStatusFilter.all;

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
                padding: EdgeInsets.all(isMobile ? 16 : 20),
                constraints: BoxConstraints(
                  maxWidth: isMobile ? double.infinity : 400,
                  maxHeight: isMobile
                      ? MediaQuery.of(context).size.height * 0.8
                      : 600,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Выберите период',
                              style: TextStyle(
                                fontSize: isMobile ? 18 : 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(dialogContext).pop(),
                          ),
                        ],
                      ),
                      SizedBox(height: isMobile ? 16 : 20),

                      // Start Date
                      Text(
                        'Дата начала:',
                        style: TextStyle(
                          fontSize: isMobile ? 13 : 14,
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
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 12 : 16,
                            vertical: isMobile ? 10 : 12,
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
                                size: isMobile ? 16 : 18,
                                color: Colors.blue.shade600,
                              ),
                              SizedBox(width: isMobile ? 8 : 12),
                              Text(
                                DateFormat(
                                  'dd MMMM yyyy',
                                ).format(tempStartDate ?? DateTime.now()),
                                style: TextStyle(
                                  fontSize: isMobile ? 13 : 14,
                                  color: Colors.grey.shade800,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: isMobile ? 16 : 20),

                      // End Date
                      Text(
                        'Дата окончания:',
                        style: TextStyle(
                          fontSize: isMobile ? 13 : 14,
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
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 12 : 16,
                            vertical: isMobile ? 10 : 12,
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
                                size: isMobile ? 16 : 18,
                                color: Colors.blue.shade600,
                              ),
                              SizedBox(width: isMobile ? 8 : 12),
                              Text(
                                DateFormat(
                                  'dd MMMM yyyy',
                                ).format(tempEndDate ?? DateTime.now()),
                                style: TextStyle(
                                  fontSize: isMobile ? 13 : 14,
                                  color: Colors.grey.shade800,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: isMobile ? 20 : 24),

                      // Quick Select Buttons
                      Text(
                        'Быстрый выбор:',
                        style: TextStyle(
                          fontSize: isMobile ? 13 : 14,
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
                          }, isMobile),
                          _buildQuickSelectChip('Этот месяц', () {
                            final now = DateTime.now();
                            setDialogState(() {
                              tempStartDate = DateTime(now.year, now.month, 1);
                              tempEndDate = DateTime(
                                now.year,
                                now.month + 1,
                                0,
                              );
                            });
                          }, isMobile),
                          _buildQuickSelectChip('Последние 30 дней', () {
                            final now = DateTime.now();
                            setDialogState(() {
                              tempStartDate = now.subtract(
                                const Duration(days: 30),
                              );
                              tempEndDate = now;
                            });
                          }, isMobile),
                        ],
                      ),

                      SizedBox(height: isMobile ? 20 : 24),

                      // Action Buttons
                      isMobile
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ElevatedButton(
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
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                  ),
                                  child: const Text('Применить'),
                                ),
                                const SizedBox(height: 8),
                                OutlinedButton(
                                  onPressed: () =>
                                      Navigator.of(dialogContext).pop(),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                  ),
                                  child: const Text('Отмена'),
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () =>
                                        Navigator.of(dialogContext).pop(),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
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
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                    ),
                                    child: const Text('Применить'),
                                  ),
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildQuickSelectChip(
    String label,
    VoidCallback onTap,
    bool isMobile,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 10 : 12,
          vertical: isMobile ? 6 : 8,
        ),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.blue.shade700,
            fontSize: isMobile ? 11 : 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Future<void> _exportToExcel(
    List<Map<String, dynamic>> transactions,
    Map<String, dynamic> summary,
  ) async {
    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Финансы'];

      // Удаляем стандартный лист, если он создался
      if (excel.sheets.containsKey('Sheet1')) {
        excel.delete('Sheet1');
      }

      // --- СТИЛИ ---
      CellStyle headerStyle = CellStyle(
        bold: true,
        fontSize: 12,
        backgroundColorHex: ExcelColor.blue,
        fontColorHex: ExcelColor.white,
        horizontalAlign: HorizontalAlign.Center,
      );

      CellStyle titleStyle = CellStyle(bold: true, fontSize: 14);

      // --- 1. ЗАГОЛОВОК ---
      sheetObject.cell(CellIndex.indexByString('A1')).value = TextCellValue(
        'ФИНАНСОВЫЙ ОТЧЕТ',
      );
      sheetObject.cell(CellIndex.indexByString('A1')).cellStyle = titleStyle;

      sheetObject.cell(CellIndex.indexByString('A2')).value = TextCellValue(
        'Период: ${DateFormat('dd.MM.yyyy').format(startDate)} - ${DateFormat('dd.MM.yyyy').format(endDate)}',
      );

      // --- 2. ОСНОВНЫЕ ПОКАЗАТЕЛИ ---
      int currentRow = 4;
      sheetObject
          .cell(
            CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
          )
          .value = TextCellValue(
        'ОСНОВНЫЕ ПОКАЗАТЕЛИ',
      );
      sheetObject
              .cell(
                CellIndex.indexByColumnRow(
                  columnIndex: 0,
                  rowIndex: currentRow,
                ),
              )
              .cellStyle =
          headerStyle;

      currentRow++;
      sheetObject
          .cell(
            CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
          )
          .value = TextCellValue(
        'Оборот:',
      );
      sheetObject
          .cell(
            CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow),
          )
          .value = TextCellValue(
        '${summary['grossRevenue'] ?? 0} ₸',
      );

      currentRow++;
      sheetObject
          .cell(
            CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
          )
          .value = TextCellValue(
        'Чистый доход:',
      );
      sheetObject
          .cell(
            CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow),
          )
          .value = TextCellValue(
        '${summary['netRevenue'] ?? 0} ₸',
      );

      // --- 3. ДЕТАЛИЗАЦИЯ ОПЛАТ (из вложенного paymentBreakdown) ---
      currentRow += 2;
      final mainBreakdown =
          summary['paymentBreakdown'] as Map<String, dynamic>? ?? {};

      // Суммируем все банки для итоговой таблицы
      final double totalBanks =
          ((mainBreakdown['kaspi'] ?? 0) +
                  (mainBreakdown['halyk'] ?? 0) +
                  (mainBreakdown['bcc'] ?? 0) +
                  (mainBreakdown['rbk'] ?? 0) +
                  (mainBreakdown['forte'] ?? 0) +
                  (mainBreakdown['jusan'] ?? 0) +
                  (mainBreakdown['bereke'] ?? 0))
              .toDouble();

      sheetObject
          .cell(
            CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
          )
          .value = TextCellValue(
        'ДЕТАЛИЗАЦИЯ ОПЛАТ',
      );
      sheetObject
              .cell(
                CellIndex.indexByColumnRow(
                  columnIndex: 0,
                  rowIndex: currentRow,
                ),
              )
              .cellStyle =
          headerStyle;

      currentRow++;
      sheetObject
          .cell(
            CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
          )
          .value = TextCellValue(
        'Наличные:',
      );
      sheetObject
          .cell(
            CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow),
          )
          .value = TextCellValue(
        '${mainBreakdown['cash'] ?? 0} ₸',
      );

      currentRow++;
      sheetObject
          .cell(
            CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
          )
          .value = TextCellValue(
        'Безнал (Всего):',
      );
      sheetObject
          .cell(
            CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow),
          )
          .value = TextCellValue(
        '${totalBanks + (mainBreakdown['online'] ?? 0)} ₸',
      );

      currentRow++;
      sheetObject
          .cell(
            CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
          )
          .value = TextCellValue(
        '   - Банки:',
      );
      sheetObject
          .cell(
            CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow),
          )
          .value = TextCellValue(
        '$totalBanks ₸',
      );

      currentRow++;
      sheetObject
          .cell(
            CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
          )
          .value = TextCellValue(
        '   - Онлайн (Платежка):',
      );
      sheetObject
          .cell(
            CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow),
          )
          .value = TextCellValue(
        '${mainBreakdown['online'] ?? 0} ₸',
      );

      // --- 4. СТАТИСТИКА БРОНИРОВАНИЙ ---
      currentRow += 2;
      final bks = summary['bookings'] as Map<String, dynamic>? ?? {};
      sheetObject
          .cell(
            CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
          )
          .value = TextCellValue(
        'СТАТИСТИКА БРОНИРОВАНИЙ',
      );
      sheetObject
              .cell(
                CellIndex.indexByColumnRow(
                  columnIndex: 0,
                  rowIndex: currentRow,
                ),
              )
              .cellStyle =
          headerStyle;

      currentRow++;
      sheetObject
          .cell(
            CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
          )
          .value = TextCellValue(
        'Всего / Онлайн / Оффлайн:',
      );
      sheetObject
          .cell(
            CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow),
          )
          .value = TextCellValue(
        '${bks['total'] ?? 0} / ${bks['online'] ?? 0} / ${bks['offline'] ?? 0}',
      );

      // --- 5. ТАБЛИЦА ТРАНЗАКЦИЙ ---
      currentRow += 2;
      List<String> headers = [
        '№',
        'Дата',
        'Время',
        'Клиент',
        'Арена',
        'Сумма',
        'Наличные',
        'Банк',
        'Онлайн',
      ];

      // Рисуем шапку таблицы
      for (int i = 0; i < headers.length; i++) {
        var cell = sheetObject.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: currentRow),
        );
        cell.value = TextCellValue(headers[i]);
        cell.cellStyle = headerStyle;
      }

      int dataStartRow = currentRow + 1;

      // Цикл по всем транзакциям
      for (int i = 0; i < transactions.length; i++) {
        final t = transactions[i];
        final rowBreakdown =
            t['paymentBreakdown'] as Map<String, dynamic>? ?? {};

        double amt = (t['amount'] ?? 0).toDouble();
        double rowCash = (rowBreakdown['cash'] ?? 0).toDouble();
        double rowOnline = (rowBreakdown['online'] ?? 0).toDouble();

        // Суммируем банки внутри конкретной транзакции
        double rowBanks =
            ((rowBreakdown['kaspi'] ?? 0) +
                    (rowBreakdown['halyk'] ?? 0) +
                    (rowBreakdown['bcc'] ?? 0) +
                    (rowBreakdown['rbk'] ?? 0) +
                    (rowBreakdown['forte'] ?? 0) +
                    (rowBreakdown['jusan'] ?? 0) +
                    (rowBreakdown['bereke'] ?? 0))
                .toDouble();

        int r = dataStartRow + i;

        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: r))
            .value = TextCellValue(
          '${i + 1}',
        );
        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: r))
            .value = TextCellValue(
          t['date']?.toString().split('T')[0] ?? '',
        );
        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: r))
            .value = TextCellValue(
          '${t['startTime']}-${t['endTime']}',
        );
        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: r))
            .value = TextCellValue(
          t['clientName'] ?? 'N/A',
        );
        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: r))
            .value = TextCellValue(
          t['arena'] ?? 'N/A',
        );
        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: r))
            .value = TextCellValue(
          '$amt',
        );

        // Распределение суммы по колонкам
        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: r))
            .value = TextCellValue(
          rowCash > 0 ? '$rowCash' : '0',
        );
        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: r))
            .value = TextCellValue(
          rowBanks > 0 ? '$rowBanks' : '0',
        );
        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: r))
            .value = TextCellValue(
          rowOnline > 0 ? '$rowOnline' : '0',
        );
      }

      // --- ФИНАЛИЗАЦИЯ И СКАЧИВАНИЕ ---
      var fileBytes = excel.encode();
      if (fileBytes != null) {
        final blob = html.Blob([
          fileBytes,
        ], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute(
            'download',
            'Финансовый_отчет_${DateFormat('dd-MM-yyyy').format(DateTime.now())}.xlsx',
          )
          ..click();
        html.Url.revokeObjectUrl(url);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Excel файл успешно загружен'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      print('Excel Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при экспорте: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
              final screenWidth = constraints.maxWidth;
              final isMobile = screenWidth < 600;
              final isTablet = screenWidth >= 600 && screenWidth < 1024;
              final isDesktop = screenWidth >= 1024;

              return RefreshIndicator(
                onRefresh: _refreshData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.all(
                      isMobile ? 16.0 : (isTablet ? 24.0 : 32.0),
                    ),
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
                                  Icon(
                                    Icons.error_outline,
                                    size: isMobile ? 48 : 64,
                                    color: Colors.red,
                                  ),
                                  SizedBox(height: isMobile ? 12 : 16),
                                  Text(
                                    state.message,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: isMobile ? 14 : 16,
                                    ),
                                  ),
                                  SizedBox(height: isMobile ? 12 : 16),
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
                              _buildHeader(context, isMobile, isTablet),
                              SizedBox(
                                height: isMobile ? 20 : (isTablet ? 28 : 32),
                              ),
                              _buildMainRevenueRow(
                                isMobile,
                                isTablet,
                                isDesktop,
                                summary,
                              ),
                              _buildCancellationsRow(
                                isMobile,
                                isTablet,
                                isDesktop,
                                summary,
                              ), // ✅ ДОБАВЬ

                              SizedBox(height: isMobile ? 16 : 24),
                              _buildBookingsRow(
                                isMobile,
                                isTablet,
                                isDesktop,
                                summary,
                              ),
                              SizedBox(
                                height: isMobile ? 20 : (isTablet ? 28 : 32),
                              ),
                              _buildCommissionRow(
                                isMobile,
                                isTablet,
                                isDesktop,
                                summary,
                              ),

                              SizedBox(
                                height: isMobile ? 20 : (isTablet ? 28 : 32),
                              ),
                              _buildTransactionsSection(
                                context,
                                isMobile,
                                isTablet,
                                transactions,
                                summary,
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

  Widget _buildHeader(BuildContext context, bool isMobile, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Финансы',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${DateFormat('dd.MM.yyyy').format(startDate)} - ${DateFormat('dd.MM.yyyy').format(endDate)}',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('Обновить'),
                          onPressed: _refreshData,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: BlocBuilder<FinanceBloc, FinanceState>(
                          builder: (context, state) {
                            if (state is FinanceLoaded) {
                              return OutlinedButton.icon(
                                icon: const Icon(Icons.download, size: 18),
                                label: const Text('Excel'),
                                onPressed: () => _exportToExcel(
                                  state.filteredTransactions,
                                  state.summary,
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  foregroundColor: Colors.green,
                                  side: const BorderSide(color: Colors.green),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Финансы',
                          style: TextStyle(
                            fontSize: isTablet ? 30 : 36,
                            fontWeight: FontWeight.w800,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${DateFormat('dd.MM.yyyy').format(startDate)} - ${DateFormat('dd.MM.yyyy').format(endDate)}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      BlocBuilder<FinanceBloc, FinanceState>(
                        builder: (context, state) {
                          if (state is FinanceLoaded) {
                            return IconButton(
                              icon: const Icon(Icons.file_download),
                              onPressed: () => _exportToExcel(
                                state.filteredTransactions,
                                state.summary,
                              ),
                              tooltip: 'Экспорт в Excel',
                              iconSize: 28,
                              color: Colors.green,
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _refreshData,
                        tooltip: 'Обновить',
                        iconSize: 28,
                      ),
                    ],
                  ),
                ],
              ),
      ],
    );
  }

  Widget _buildMainRevenueRow(
    bool isMobile,
    bool isTablet,
    bool isDesktop,
    Map<String, dynamic> s,
  ) {
    final cards = [
      {
        'label': 'Получено',
        'value': s['paidAmount'],
        'color': const Color(0xFF059669),
        'icon': Icons.check_circle_rounded,
        'subtitle': 'Поступило на счет',
      },
      {
        'label': 'Ожидается',
        'value': s['pendingAmount'],
        'color': const Color(0xFFEAB308),
        'icon': Icons.schedule_rounded,
        'subtitle': 'Долги клиентов',
      },
      {
        'label': 'Оборот',
        'value': s['grossRevenue'],
        'color': const Color(0xFF2563EB),
        'icon': Icons.trending_up_rounded,
        'subtitle': 'Все бронирования',
      },
      {
        'label': 'Чистый доход',
        'value': s['netRevenue'],
        'color': const Color(0xFF8B5CF6),
        'icon': Icons.account_balance_wallet_rounded,
        'subtitle': 'После комиссии',
      },
    ];

    return _buildCardRow(isMobile, isTablet, isDesktop, cards);
  }

  Widget _buildBookingsRow(
    bool isMobile,
    bool isTablet,
    bool isDesktop,
    Map<String, dynamic> s,
  ) {
    final cards = [
      {
        'label': 'Всего броней',
        'value': s['totalBookings'],
        'color': Colors.blue.shade700,
        'icon': Icons.calendar_today_rounded,
        'subtitle': 'За период',
      },
      {
        'label': 'Онлайн',
        'value': s['onlineBookings'],
        'color': Colors.indigo.shade600,
        'icon': Icons.credit_card_rounded,
        'subtitle': 'Через платформу',
      },
      {
        'label': 'Оффлайн',
        'value': s['offlineBookings'],
        'color': Colors.amber.shade700,
        'icon': Icons.storefront_rounded,
        'subtitle': 'Вне платформы',
      },
    ];

    return _buildCardRow(isMobile, isTablet, isDesktop, cards);
  }

  Widget _buildCommissionRow(
    bool isMobile,
    bool isTablet,
    bool isDesktop,
    Map<String, dynamic> s,
  ) {
    final totalBookings = s['totalBookings'] as int? ?? 0;
    final grossRevenue = s['grossRevenue'] as num? ?? 0;

    final cards = [
      {
        'label': 'Комиссия платформы',
        'value': s['platformCommission'],
        'color': Colors.red.shade600,
        'icon': Icons.percent_rounded,
        'subtitle': 'Плата за обслуживание',
      },
      {
        'label': 'Средний чек',
        'value': totalBookings > 0
            ? (grossRevenue / totalBookings).toStringAsFixed(0)
            : '0',
        'color': Colors.purple.shade600,
        'icon': Icons.receipt_long_rounded,
        'subtitle': 'На одну бронь',
      },
    ];

    return Column(
      children: [
        _buildCardRow(isMobile, isTablet, isDesktop, cards),
        SizedBox(height: isMobile ? 16 : 24),
        _buildPaymentBreakdown(isMobile, isTablet, s),
      ],
    );
  }

  Widget _buildPaymentBreakdown(
    bool isMobile,
    bool isTablet,
    Map<String, dynamic> summary,
  ) {
    final paymentBreakdown =
        summary['paymentBreakdown'] as Map<String, dynamic>? ?? {};

    final online = paymentBreakdown['online'] as num? ?? 0;
    final cash = paymentBreakdown['cash'] as num? ?? 0;
    final kaspi = paymentBreakdown['kaspi'] as num? ?? 0;
    final halyk = paymentBreakdown['halyk'] as num? ?? 0;
    final bcc = paymentBreakdown['bcc'] as num? ?? 0;
    final forte = paymentBreakdown['forte'] as num? ?? 0;
    final rbk = paymentBreakdown['rbk'] as num? ?? 0;
    final jusan = paymentBreakdown['jusan'] as num? ?? 0;
    final bereke = paymentBreakdown['bereke'] as num? ?? 0;
    final unknown = paymentBreakdown['unknown'] as num? ?? 0;

    final onlineTotal = online;
    final offlineTotal =
        cash + kaspi + halyk + bcc + forte + rbk + jusan + bereke + unknown;
    final grandTotal = onlineTotal + offlineTotal;

    if (grandTotal == 0) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
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
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.blue.shade600,
                  size: isMobile ? 18 : 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Детализация платежей',
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    Text(
                      'Распределение по каналам',
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 16 : 20),
          if (isMobile)
            Column(
              children: [
                if (onlineTotal > 0)
                  _buildChannelCard(
                    'Через платформу',
                    onlineTotal,
                    Colors.blue,
                    Icons.language,
                    isMobile,
                    null,
                  ),
                if (onlineTotal > 0 && offlineTotal > 0)
                  const SizedBox(height: 12),
                if (offlineTotal > 0)
                  _buildChannelCard(
                    'Вне платформы',
                    offlineTotal,
                    Colors.orange,
                    Icons.storefront,
                    isMobile,
                    _buildOfflineBreakdown(
                      cash,
                      kaspi,
                      halyk,
                      bcc,
                      forte,
                      rbk,
                      jusan,
                      bereke,
                      unknown,
                      isMobile,
                    ),
                  ),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (onlineTotal > 0) ...[
                  Expanded(
                    child: _buildChannelCard(
                      'Через платформу',
                      onlineTotal,
                      Colors.blue,
                      Icons.language,
                      isMobile,
                      null,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                if (offlineTotal > 0)
                  Expanded(
                    child: _buildChannelCard(
                      'Вне платформы',
                      offlineTotal,
                      Colors.orange,
                      Icons.storefront,
                      isMobile,
                      _buildOfflineBreakdown(
                        cash,
                        kaspi,
                        halyk,
                        bcc,
                        forte,
                        rbk,
                        jusan,
                        bereke,
                        unknown,
                        isMobile,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildChannelCard(
    String label,
    num amount,
    Color color,
    IconData icon,
    bool isMobile,
    Widget? details,
  ) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: isMobile ? 20 : 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatCurrency(amount),
                      style: TextStyle(
                        fontSize: isMobile ? 18 : 20,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (details != null) ...[
            SizedBox(height: isMobile ? 12 : 16),
            const Divider(),
            SizedBox(height: isMobile ? 8 : 12),
            details,
          ],
        ],
      ),
    );
  }

  Widget _buildOfflineBreakdown(
    num cash,
    num kaspi,
    num halyk,
    num bcc,
    num forte,
    num rbk,
    num jusan,
    num bereke,
    num unknown,
    bool isMobile,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Методы оплаты:',
          style: TextStyle(
            fontSize: isMobile ? 11 : 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        if (cash > 0) ...[
          _buildPaymentMethodRow(
            'Наличные',
            cash,
            Colors.green,
            Icons.money,
            isMobile,
          ),
          const SizedBox(height: 6),
        ],
        if (unknown > 0) ...[
          // ← добавить
          _buildPaymentMethodRow(
            'Неизвестно',
            unknown,
            Colors.grey.shade700,
            Icons.storefront,
            isMobile,
          ),
          const SizedBox(height: 6),
        ],
        if (kaspi > 0 ||
            halyk > 0 ||
            bcc > 0 ||
            forte > 0 ||
            rbk > 0 ||
            jusan > 0 ||
            bereke > 0)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (cash > 0 || unknown > 0) ...[
                // ← offline тоже
                Padding(
                  padding: EdgeInsets.symmetric(vertical: isMobile ? 4 : 6),
                  child: Text(
                    'Переводы:',
                    style: TextStyle(
                      fontSize: isMobile ? 10 : 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
              ],
              Wrap(
                spacing: isMobile ? 6 : 8,
                runSpacing: isMobile ? 6 : 8,
                children: [
                  if (kaspi > 0)
                    _buildBankChip('Kaspi', kaspi, Colors.red, isMobile),
                  if (halyk > 0)
                    _buildBankChip('Halyk', halyk, Colors.blue, isMobile),
                  if (bcc > 0)
                    _buildBankChip('БЦК', bcc, Colors.orange, isMobile),
                  if (forte > 0)
                    _buildBankChip('Forte', forte, Colors.purple, isMobile),
                  if (rbk > 0)
                    _buildBankChip('RBK', rbk, Colors.indigo, isMobile),
                  if (jusan > 0)
                    _buildBankChip('Jusan', jusan, Colors.teal, isMobile),
                  if (bereke > 0)
                    _buildBankChip('Bereke', bereke, Colors.amber, isMobile),
                ],
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildCancellationsRow(
    bool isMobile,
    bool isTablet,
    bool isDesktop,
    Map<String, dynamic> s,
  ) {
    final cancelledRetained = s['cancelledRetained'] ?? 0;

    // Если нет отмен с удержанием, не показываем
    if (cancelledRetained == 0) return const SizedBox.shrink();

    final cards = [
      {
        'label': 'Удержано при отменах',
        'value': cancelledRetained,
        'color': Colors.orange.shade700,
        'icon': Icons.cancel_presentation_rounded,
        'subtitle': 'Не возвращено клиентам',
      },
    ];

    return Column(
      children: [
        SizedBox(height: isMobile ? 16 : 24),
        _buildCardRow(isMobile, isTablet, isDesktop, cards),
      ],
    );
  }

  Widget _buildPaymentMethodRow(
    String label,
    num amount,
    Color color,
    IconData icon,
    bool isMobile,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: color, size: isMobile ? 14 : 16),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: isMobile ? 12 : 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(width: 8),

        Text(
          _formatCurrency(amount, withSign: false),
          style: TextStyle(
            fontSize: isMobile ? 12 : 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          ' ₸',
          style: TextStyle(
            fontSize: isMobile ? 10 : 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildBankChip(String bank, num amount, Color color, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 10 : 12,
        vertical: isMobile ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isMobile ? 6 : 8,
            height: isMobile ? 6 : 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: isMobile ? 6 : 8),
          Text(
            bank,
            style: TextStyle(
              fontSize: isMobile ? 11 : 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(width: isMobile ? 4 : 6),
          Text(
            NumberFormat('#,###').format(amount),
            style: TextStyle(
              fontSize: isMobile ? 11 : 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            ' ₸',
            style: TextStyle(
              fontSize: isMobile ? 10 : 11,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardRow(
    bool isMobile,
    bool isTablet,
    bool isDesktop,
    List<Map<String, dynamic>> cards,
  ) {
    if (isMobile) {
      return Column(
        children: [
          for (var i = 0; i < cards.length; i += 2)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: _buildEnhancedSummaryCard(
                      cards[i]['label']!,
                      _formatCurrency(
                        cards[i]['value'],
                        withSign: !_isCountField(cards[i]['label']!),
                      ),
                      cards[i]['color']!,
                      cards[i]['icon']!,
                      cards[i]['subtitle']!,
                      isMobile,
                    ),
                  ),
                  if (i + 1 < cards.length) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildEnhancedSummaryCard(
                        cards[i + 1]['label']!,
                        _formatCurrency(
                          cards[i + 1]['value'],
                          withSign: !_isCountField(cards[i + 1]['label']!),
                        ),
                        cards[i + 1]['color']!,
                        cards[i + 1]['icon']!,
                        cards[i + 1]['subtitle']!,
                        isMobile,
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      );
    } else if (isTablet && cards.length > 3) {
      return Column(
        children: [
          Row(
            children: cards.take(2).map((card) {
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 8, bottom: 12),
                  child: _buildEnhancedSummaryCard(
                    card['label']!,
                    _formatCurrency(
                      card['value'],
                      withSign: !_isCountField(card['label']!),
                    ),
                    card['color']!,
                    card['icon']!,
                    card['subtitle']!,
                    isMobile,
                  ),
                ),
              );
            }).toList(),
          ),
          Row(
            children: cards.skip(2).map((card) {
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: _buildEnhancedSummaryCard(
                    card['label']!,
                    _formatCurrency(
                      card['value'],
                      withSign: !_isCountField(card['label']!),
                    ),
                    card['color']!,
                    card['icon']!,
                    card['subtitle']!,
                    isMobile,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      );
    } else {
      return Row(
        children: cards.map((card) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: _buildEnhancedSummaryCard(
                card['label']!,
                _formatCurrency(
                  card['value'],
                  withSign: !_isCountField(card['label']!),
                ),
                card['color']!,
                card['icon']!,
                card['subtitle']!,
                isMobile,
              ),
            ),
          );
        }).toList(),
      );
    }
  }

  bool _isCountField(String label) {
    return label == 'Бронирования' ||
        label == 'Онлайн' ||
        label == 'Оффлайн' ||
        label == 'Всего броней';
  }

  Widget _buildEnhancedSummaryCard(
    String label,
    String value,
    Color color,
    IconData icon,
    String subtitle,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
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
                        fontSize: isMobile ? 12 : 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: isMobile ? 10 : 11,
                        color: Colors.grey.shade500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: EdgeInsets.all(isMobile ? 6 : 8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
                ),
                child: Icon(icon, color: color, size: isMobile ? 18 : 20),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 8 : 12),
          Text(
            value,
            style: TextStyle(
              fontSize: isMobile ? 16 : 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsSection(
    BuildContext context,
    bool isMobile,
    bool isTablet,
    List<Map<String, dynamic>> transactions,
    Map<String, dynamic> summary,
  ) {
    List<Map<String, dynamic>> filteredTransactions = transactions;

    if (_statusFilter != PaymentStatusFilter.all) {
      filteredTransactions = transactions.where((t) {
        final paymentStatus = t['paymentStatus']?.toString() ?? 'Unpaid';

        switch (_statusFilter) {
          case PaymentStatusFilter.paid:
            return paymentStatus == 'FullyPaid';
          case PaymentStatusFilter.partial:
            return paymentStatus == 'PartiallyPaid';
          case PaymentStatusFilter.unpaid:
            return paymentStatus == 'Unpaid';
          default:
            return true;
        }
      }).toList();
    }

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : (isTablet ? 20 : 24)),
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
          _buildTransactionsHeader(
            context,
            isMobile,
            isTablet,
            transactions,
            summary,
          ),
          SizedBox(height: isMobile ? 12 : 16),
          _buildFilters(isMobile),
          SizedBox(height: isMobile ? 12 : 16),
          TextField(
            onChanged: (value) {
              context.read<FinanceBloc>().add(FinanceSearch(value));
            },
            decoration: InputDecoration(
              hintText: 'Поиск по имени, арене или телефону...',
              hintStyle: TextStyle(fontSize: isMobile ? 13 : 14),
              prefixIcon: Icon(Icons.search, size: isMobile ? 20 : 24),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: isMobile ? 12 : 16,
              ),
            ),
            style: TextStyle(fontSize: isMobile ? 14 : 16),
          ),
          SizedBox(height: isMobile ? 20 : 24),
          if (filteredTransactions.isEmpty)
            _buildEmptyState(isMobile)
          else if (_viewMode == TransactionViewMode.byBooking)
            _buildTransactionsByBooking(isMobile, filteredTransactions)
          else
            _buildTransactionsByPayment(isMobile, filteredTransactions),
        ],
      ),
    );
  }

  Widget _buildTransactionsHeader(
    BuildContext context,
    bool isMobile,
    bool isTablet,
    List<Map<String, dynamic>> transactions,
    Map<String, dynamic> summary,
  ) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Транзакции',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 12),
          _buildViewModeToggle(isMobile),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _showCompactDatePicker(context, isMobile),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
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
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${DateFormat('dd.MM.yy').format(startDate)} - ${DateFormat('dd.MM.yy').format(endDate)}',
                            style: TextStyle(
                              color: Colors.grey.shade800,
                              fontWeight: FontWeight.w500,
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  Icons.file_download,
                  color: Colors.green.shade600,
                  size: 20,
                ),
                onPressed: () => _exportToExcel(transactions, summary),
                tooltip: 'Экспорт в Excel',
              ),
            ],
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Транзакции',
              style: TextStyle(
                fontSize: isTablet ? 22 : 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            _buildViewModeToggle(isMobile),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.file_download, color: Colors.green.shade600),
              onPressed: () => _exportToExcel(transactions, summary),
              tooltip: 'Экспорт в Excel',
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
    );
  }

  Widget _buildViewModeToggle(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildViewModeButton(
            'По бронированиям',
            Icons.calendar_today,
            TransactionViewMode.byBooking,
            isMobile,
          ),
          const SizedBox(width: 4),
          _buildViewModeButton(
            'По платежам',
            Icons.payments,
            TransactionViewMode.byPayment,
            isMobile,
          ),
        ],
      ),
    );
  }

  Widget _buildViewModeButton(
    String label,
    IconData icon,
    TransactionViewMode mode,
    bool isMobile,
  ) {
    final isActive = _viewMode == mode;

    return InkWell(
      onTap: () => setState(() => _viewMode = mode),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16,
          vertical: isMobile ? 8 : 10,
        ),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: isMobile ? 16 : 18,
              color: isActive ? Colors.blue : Colors.grey.shade600,
            ),
            SizedBox(width: isMobile ? 6 : 8),
            Text(
              label,
              style: TextStyle(
                fontSize: isMobile ? 12 : 13,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? Colors.blue : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters(bool isMobile) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildFilterChip(
          'Все',
          PaymentStatusFilter.all,
          Icons.all_inclusive,
          isMobile,
        ),
        _buildFilterChip(
          'Оплачено',
          PaymentStatusFilter.paid,
          Icons.check_circle,
          isMobile,
        ),
        _buildFilterChip(
          'Частично',
          PaymentStatusFilter.partial,
          Icons.payment,
          isMobile,
        ),
        _buildFilterChip(
          'Не оплачено',
          PaymentStatusFilter.unpaid,
          Icons.schedule,
          isMobile,
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    String label,
    PaymentStatusFilter filter,
    IconData icon,
    bool isMobile,
  ) {
    final isActive = _statusFilter == filter;

    return InkWell(
      onTap: () => setState(() => _statusFilter = filter),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 14,
          vertical: isMobile ? 6 : 8,
        ),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue.shade50 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? Colors.blue.shade300 : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: isMobile ? 14 : 16,
              color: isActive ? Colors.blue.shade700 : Colors.grey.shade600,
            ),
            SizedBox(width: isMobile ? 4 : 6),
            Text(
              label,
              style: TextStyle(
                fontSize: isMobile ? 11 : 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? Colors.blue.shade700 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsByBooking(
    bool isMobile,
    List<Map<String, dynamic>> transactions,
  ) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      separatorBuilder: (context, index) => SizedBox(height: isMobile ? 8 : 12),
      itemBuilder: (context, index) {
        return _buildBookingCard(transactions[index], isMobile);
      },
    );
  }

  Widget _buildTransactionsByPayment(
    bool isMobile,
    List<Map<String, dynamic>> transactions,
  ) {
    final allPayments = <Map<String, dynamic>>[];

    for (var transaction in transactions) {
      final paymentHistory =
          transaction['paymentHistory'] as List<dynamic>? ?? [];

      for (var i = 0; i < paymentHistory.length; i++) {
        final payment = paymentHistory[i] as Map<String, dynamic>;

        allPayments.add({
          'amount': payment['amount'] ?? 0,
          'method': payment['method'] ?? 'Cash',
          'paidAt': payment['paidAt'],
          'arenaName': transaction['arena'] ?? 'N/A',
          'clientName': transaction['clientName'] ?? 'N/A',
          'phone': transaction['phone'] ?? 'Не указан',
          'startTime': transaction['startTime'] ?? '',
          'endTime': transaction['endTime'] ?? '',
          'isOffline': transaction['paymentType'] == 'offline',
          'paymentType': _getPaymentType(
            i,
            paymentHistory.length,
            transaction,
          ), // ✅ ИСПРАВЛЕНО
          'booking': transaction, // ✅ ДОБАВЬ ЭТО для использования в карточке
        });
      }
    }

    allPayments.sort((a, b) {
      final dateA = a['paidAt'] as String? ?? '';
      final dateB = b['paidAt'] as String? ?? '';
      return dateB.compareTo(dateA);
    });

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: allPayments.length,
      separatorBuilder: (context, index) => SizedBox(height: isMobile ? 8 : 12),
      itemBuilder: (context, index) {
        return _buildPaymentCard(allPayments[index], isMobile);
      },
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking, bool isMobile) {
    final arenaName = booking['arena'] ?? 'N/A';
    final clientName = booking['clientName'] ?? 'N/A';
    final phone = booking['phone'] ?? 'Не указан';

    // ✅ КРАСИВАЯ ДАТА
    final dateStr = booking['date']?.toString() ?? '';
    String formattedDate = '';
    if (dateStr.isNotEmpty) {
      try {
        final date = DateTime.parse(dateStr);
        formattedDate = DateFormat('dd MMMM yyyy', 'ru').format(date);
      } catch (e) {
        formattedDate = dateStr;
      }
    }

    final startTime = booking['startTime'] ?? '';
    final endTime = booking['endTime'] ?? '';
    final amount = booking['amount'] ?? 0;
    final totalPrice = booking['totalPrice'] ?? 0;
    final prepaidAmount = booking['prepaidAmount'] ?? 0;
    final remainingAmount = booking['remainingAmount'] ?? 0;
    final paymentStatus = booking['paymentStatus'] ?? 'Unpaid';
    final bookingStatus = booking['bookingStatus'] ?? 'Pending';
    final paymentType = booking['paymentType'] == 'online'
        ? 'Онлайн'
        : 'Оффлайн';

    // Определяем статус и цвет
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (bookingStatus == 'Completed') {
      statusColor = Colors.green;
      statusText = 'Завершено';
      statusIcon = Icons.check_circle;
    } else if (bookingStatus == 'Cancelled') {
      statusColor = Colors.red;
      statusText = 'Отменено';
      statusIcon = Icons.cancel;
    } else if (paymentStatus == 'PartiallyPaid') {
      statusColor = Colors.orange;
      statusText = 'Частично оплачено';
      statusIcon = Icons.payment;
    } else if (paymentStatus == 'FullyPaid') {
      statusColor = Colors.green;
      statusText = 'Оплачено';
      statusIcon = Icons.check_circle;
    } else {
      statusColor = Colors.blue;
      statusText = 'В ожидании';
      statusIcon = Icons.schedule;
    }

    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ HEADER: Арена + Тип брони
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 6 : 8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.stadium,
                  color: Colors.blue,
                  size: isMobile ? 18 : 20,
                ),
              ),
              SizedBox(width: isMobile ? 8 : 12),
              Expanded(
                child: Text(
                  arenaName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 14 : 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: booking['paymentType'] == 'online'
                      ? Colors.purple.shade50
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  paymentType,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: booking['paymentType'] == 'online'
                        ? Colors.purple
                        : Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: isMobile ? 10 : 12),
          const Divider(height: 1),
          SizedBox(height: isMobile ? 10 : 12),

          // ✅ ИНФОРМАЦИЯ О КЛИЕНТЕ
          Row(
            children: [
              Icon(
                Icons.person_outline,
                size: isMobile ? 16 : 18,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clientName,
                      style: TextStyle(
                        fontSize: isMobile ? 13 : 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // ✅ ТЕЛЕФОН
                    Row(
                      children: [
                        Icon(
                          Icons.phone_outlined,
                          size: isMobile ? 12 : 14,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          phone,
                          style: TextStyle(
                            fontSize: isMobile ? 11 : 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: isMobile ? 8 : 10),

          // ✅ ДАТА И ВРЕМЯ
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: isMobile ? 14 : 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$startTime - $endTime',
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: isMobile ? 10 : 12),
          const Divider(height: 1),
          SizedBox(height: isMobile ? 10 : 12),

          // ✅ СТАТУС И СУММА
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    statusIcon,
                    size: isMobile ? 14 : 16,
                    color: statusColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: isMobile ? 12 : 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatCurrency(totalPrice),
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  if (remainingAmount > 0) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Осталось: ${_formatCurrency(remainingAmount)}',
                      style: TextStyle(
                        fontSize: isMobile ? 10 : 11,
                        color: Colors.red.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),

          // ✅ ИСТОРИЯ ПЛАТЕЖЕЙ (если есть)
          if ((booking['paymentHistory'] as List<dynamic>?)?.isNotEmpty ??
              false) ...[
            SizedBox(height: isMobile ? 10 : 12),
            const Divider(height: 1),
            SizedBox(height: isMobile ? 8 : 10),
            _buildPaymentHistory(
              booking['paymentHistory'] as List<dynamic>,
              isMobile,
              booking, // ✅ ДОБАВЬ
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentHistory(
    List<dynamic> paymentHistory,
    bool isMobile,
    Map<String, dynamic> booking, // ✅ ДОБАВЬ ПАРАМЕТР
  ) {
    final methodColors = {
      'Online': Colors.blue,
      'Cash': Colors.green,
      'Kaspi': Colors.red,
      'Halyk': Colors.blue,
      'BCC': Colors.orange,
      'Forte': Colors.purple,
      'RBK': Colors.indigo,
      'Jusan': Colors.teal,
      'Bereke': Colors.amber,
    };

    final methodNames = {
      'Online': 'Онлайн',
      'Cash': 'Наличные',
      'Kaspi': 'Kaspi',
      'Halyk': 'Halyk',
      'BCC': 'БЦК',
      'Forte': 'Forte',
      'RBK': 'RBK',
      'Jusan': 'Jusan',
      'Bereke': 'Bereke',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'История оплаты:',
          style: TextStyle(
            fontSize: isMobile ? 11 : 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 6),
        ...paymentHistory.asMap().entries.map((entry) {
          final index = entry.key;
          final payment = entry.value as Map<String, dynamic>;

          final amount = payment['amount'] ?? 0;
          final method = payment['method'] as String? ?? 'Cash';
          final methodName = methodNames[method] ?? method;
          final methodColor = methodColors[method] ?? Colors.grey;

          // ✅ ИСПОЛЬЗУЕМ ФУНКЦИЮ
          String paymentType = _getPaymentType(
            index,
            paymentHistory.length,
            booking,
          );

          // Дата платежа
          final paidAt = payment['paidAt'] as String? ?? '';
          String formattedDateTime = '';
          if (paidAt.isNotEmpty) {
            try {
              final dt = DateTime.parse(paidAt).toLocal();
              formattedDateTime = DateFormat(
                'dd MMM yyyy, HH:mm',
                'ru',
              ).format(dt);
            } catch (e) {
              formattedDateTime = paidAt;
            }
          }

          return Padding(
            padding: EdgeInsets.only(bottom: isMobile ? 6 : 8),
            child: Row(
              children: [
                // Иконка
                Container(
                  padding: EdgeInsets.all(isMobile ? 5 : 6),
                  decoration: BoxDecoration(
                    color: methodColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    _getPaymentIcon(method),
                    color: methodColor,
                    size: isMobile ? 12 : 14,
                  ),
                ),
                SizedBox(width: isMobile ? 8 : 10),

                // Информация
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$paymentType • $methodName',
                        style: TextStyle(
                          fontSize: isMobile ? 11 : 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      if (formattedDateTime.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          formattedDateTime,
                          style: TextStyle(
                            fontSize: isMobile ? 9 : 10,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Сумма
                Text(
                  _formatCurrency(amount),
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 13,
                    fontWeight: FontWeight.bold,
                    color: methodColor,
                  ),
                ),
                if (method == 'Unknown') ...[
                  SizedBox(width: isMobile ? 6 : 8),
                  GestureDetector(
                    onTap: () => _showUpdatePaymentMethodDialog(
                      context,
                      booking['id'] as String,
                      payment['_id'] as String,
                      amount,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.orange.shade300),
                      ),
                      child: Text(
                        'Уточнить',
                        style: TextStyle(
                          fontSize: isMobile ? 9 : 10,
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  void _showUpdatePaymentMethodDialog(
    BuildContext context,
    String bookingId,
    String paymentId,
    dynamic amount,
  ) {
    String selectedMethod = 'Cash';
    final methods = [
      'Cash',
      'Kaspi',
      'Halyk',
      'BCC',
      'Forte',
      'RBK',
      'Jusan',
      'Bereke',
    ];
    final methodNames = {
      'Cash': 'Наличные',
      'Kaspi': 'Kaspi',
      'Halyk': 'Halyk',
      'BCC': 'БЦК',
      'Forte': 'Forte',
      'RBK': 'RBK',
      'Jusan': 'Jusan',
      'Bereke': 'Bereke',
    };

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Уточнить способ оплаты'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Сумма: ${_formatCurrency(amount)}'),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedMethod,
                items: methods
                    .map(
                      (m) => DropdownMenuItem(
                        value: m,
                        child: Text(methodNames[m] ?? m),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() => selectedMethod = val!),
                decoration: const InputDecoration(
                  labelText: 'Способ оплаты',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await _updatePaymentMethod(
                  bookingId,
                  paymentId,
                  selectedMethod,
                );
              },
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updatePaymentMethod(
    String bookingId,
    String paymentId,
    String method,
  ) async {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, 1);
    final endDate = now;

    context.read<FinanceBloc>().add(
      FinanceUpdatePaymentMethod(
        bookingId: bookingId,
        paymentId: paymentId,
        method: method,
        startDate: startDate,
        endDate: endDate,
      ),
    );
  }

  Widget _buildPaymentCard(Map<String, dynamic> payment, bool isMobile) {
    final amount = payment['amount'] ?? 0;
    final method = payment['method'] as String? ?? 'Cash';
    final paidAt = payment['paidAt'] as String? ?? '';
    final arenaName = payment['arenaName'] as String? ?? 'N/A';
    final clientName = payment['clientName'] as String? ?? 'N/A';
    final phone = payment['phone'] as String? ?? 'Не указан'; // ✅ ДОБАВИЛИ
    final startTime = payment['startTime'] as String? ?? '';
    final endTime = payment['endTime'] as String? ?? '';
    final paymentType = payment['paymentType'] as String? ?? 'Платеж';
    final isOffline = payment['isOffline'] as bool? ?? false;

    final methodColors = {
      'Online': Colors.blue,
      'Cash': Colors.green,
      'Kaspi': Colors.red,
      'Halyk': Colors.blue,
      'BCC': Colors.orange,
      'Forte': Colors.purple,
      'RBK': Colors.indigo,
      'Jusan': Colors.teal,
      'Bereke': Colors.amber,
    };

    final methodNames = {
      'Online': 'Онлайн',
      'Cash': 'Наличные',
      'Kaspi': 'Kaspi',
      'Halyk': 'Halyk',
      'BCC': 'БЦК',
      'Forte': 'Forte',
      'RBK': 'RBK',
      'Jusan': 'Jusan',
      'Bereke': 'Bereke',
    };

    final methodColor = methodColors[method] ?? Colors.grey;
    final methodName = methodNames[method] ?? method;

    // ✅ КРАСИВАЯ ДАТА И ВРЕМЯ
    String formattedDateTime = '';
    if (paidAt.isNotEmpty) {
      try {
        final dt = DateTime.parse(paidAt);
        formattedDateTime = DateFormat('dd MMMM yyyy, HH:mm', 'ru').format(dt);
      } catch (e) {
        formattedDateTime = paidAt;
      }
    }

    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ HEADER: Тип платежа + Метод
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 8 : 10),
                decoration: BoxDecoration(
                  color: methodColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getPaymentIcon(method),
                  color: methodColor,
                  size: isMobile ? 18 : 20,
                ),
              ),
              SizedBox(width: isMobile ? 10 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$paymentType • $methodName',
                      style: TextStyle(
                        fontSize: isMobile ? 13 : 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // ✅ КРАСИВАЯ ДАТА
                    Text(
                      formattedDateTime,
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatCurrency(amount),
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color: methodColor,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isOffline
                          ? Colors.grey.shade100
                          : Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isOffline ? 'Оффлайн' : 'Онлайн',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: isOffline ? Colors.grey.shade600 : Colors.purple,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: isMobile ? 8 : 10),
          const Divider(height: 1),
          SizedBox(height: isMobile ? 8 : 10),

          // ✅ ИНФОРМАЦИЯ О БРОНИРОВАНИИ
          Row(
            children: [
              Icon(
                Icons.stadium,
                size: isMobile ? 14 : 16,
                color: Colors.grey.shade500,
              ),
              SizedBox(width: isMobile ? 6 : 8),
              Expanded(
                child: Text(
                  arenaName,
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 13,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (startTime.isNotEmpty && endTime.isNotEmpty) ...[
                Icon(
                  Icons.access_time,
                  size: isMobile ? 14 : 16,
                  color: Colors.grey.shade500,
                ),
                SizedBox(width: isMobile ? 4 : 6),
                Text(
                  '$startTime - $endTime',
                  style: TextStyle(
                    fontSize: isMobile ? 11 : 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ],
          ),

          SizedBox(height: isMobile ? 6 : 8),

          // ✅ ИНФОРМАЦИЯ О КЛИЕНТЕ
          Row(
            children: [
              Icon(
                Icons.person_outline,
                size: isMobile ? 14 : 16,
                color: Colors.grey.shade500,
              ),
              SizedBox(width: isMobile ? 6 : 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clientName,
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 13,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // ✅ ТЕЛЕФОН
                    Row(
                      children: [
                        Icon(
                          Icons.phone_outlined,
                          size: isMobile ? 10 : 12,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          phone,
                          style: TextStyle(
                            fontSize: isMobile ? 10 : 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getPaymentType(int index, int total, Map<String, dynamic>? booking) {
    // Если передана информация о бронировании
    if (booking != null) {
      final prepaid = booking['prepaidAmount'] ?? 0;
      final totalPrice = booking['totalPrice'] ?? 0;
      final status = booking['bookingStatus'] ?? booking['status'] ?? '';

      // ✅ ДЛЯ ОТМЕНЕННЫХ БРОНЕЙ
      if (status == 'Cancelled') {
        if (total == 1) {
          // Один платеж - проверяем закрыл ли он всю сумму
          if (prepaid >= totalPrice) {
            return 'Полная оплата';
          } else {
            return 'Предоплата'; // ✅ ВОТ ЭТО!
          }
        }
        // Если несколько платежей - используем стандартную логику
        if (index == 0) return 'Предоплата';
        if (index == total - 1) return 'Доплата';
        return 'Платеж ${index + 1}';
      }

      // ✅ ДЛЯ АКТИВНЫХ БРОНЕЙ
      if (total == 1) {
        // Один платеж - проверяем закрыл ли он всю сумму
        if (prepaid >= totalPrice) {
          return 'Полная оплата';
        } else {
          return 'Предоплата';
        }
      }
    }

    // ✅ СТАНДАРТНАЯ ЛОГИКА ДЛЯ МНОЖЕСТВЕННЫХ ПЛАТЕЖЕЙ
    if (total == 1) return 'Полная оплата';
    if (index == 0) return 'Предоплата';
    if (index == total - 1) return 'Доплата';
    return 'Платеж ${index + 1}';
  }

  IconData _getPaymentIcon(String method) {
    switch (method) {
      case 'Online':
        return Icons.credit_card;
      case 'Cash':
        return Icons.money;
      default:
        return Icons.account_balance;
    }
  }

  String _formatDateTime(String dateTime) {
    if (dateTime.isEmpty) return '';
    try {
      final dt = DateTime.parse(dateTime);
      return DateFormat('dd.MM.yyyy HH:mm').format(dt);
    } catch (e) {
      return dateTime;
    }
  }

  Widget _buildEmptyState(bool isMobile) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 32.0 : 48.0),
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              size: isMobile ? 48 : 64,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: isMobile ? 12 : 16),
            Text(
              'Транзакции не найдены',
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(dynamic amount, {bool withSign = true}) {
    final formatter = NumberFormat('#,###');
    final numAmount = (amount is num) ? amount : 0;
    return withSign
        ? '${formatter.format(numAmount)} ₸'
        : formatter.format(numAmount);
  }
}
