// lib/screens/finance/finance_dashboard.dart
import 'dart:developer';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kff_owner_admin/app/screens/finance/bloc/finance_bloc.dart';
import 'package:excel/excel.dart' hide Border;

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

  void _exportToCsv() {
    context.read<FinanceBloc>().add(
      FinanceExportCSV(
        startDate: startDate,
        endDate: endDate,
        arenaId: selectedArenaId,
      ),
    );
  }

  // Функция экспорта в Excel
  Future<void> _exportToExcel(
    List<Map<String, dynamic>> transactions,
    Map<String, dynamic> summary,
  ) async {
    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Финансы'];

      // Удаляем дефолтный лист
      if (excel.sheets.containsKey('Sheet1')) {
        excel.delete('Sheet1');
      }

      // Стили
      CellStyle headerStyle = CellStyle(
        bold: true,
        fontSize: 12,
        backgroundColorHex: ExcelColor.blue,
        fontColorHex: ExcelColor.white,
      );

      CellStyle totalStyle = CellStyle(
        bold: true,
        fontSize: 11,
        backgroundColorHex: ExcelColor.white54,
      );

      CellStyle titleStyleCell = CellStyle(bold: true, fontSize: 14);

      // Заголовок документа
      var titleCell = sheetObject.cell(CellIndex.indexByString('A1'));
      titleCell.value = TextCellValue('Финансовый отчет');
      titleCell.cellStyle = titleStyleCell;

      var periodCell = sheetObject.cell(CellIndex.indexByString('A2'));
      periodCell.value = TextCellValue(
        'Период: ${DateFormat('dd.MM.yyyy').format(startDate)} - ${DateFormat('dd.MM.yyyy').format(endDate)}',
      );

      // Статистика - Основные показатели
      sheetObject.cell(CellIndex.indexByString('A4')).value = TextCellValue(
        'ОСНОВНЫЕ ПОКАЗАТЕЛИ',
      );
      sheetObject.cell(CellIndex.indexByString('A4')).cellStyle = headerStyle;

      sheetObject.cell(CellIndex.indexByString('A5')).value = TextCellValue(
        'Получено:',
      );
      sheetObject.cell(CellIndex.indexByString('A5')).cellStyle = totalStyle;
      sheetObject.cell(CellIndex.indexByString('B5')).value = TextCellValue(
        '${summary['paidAmount'] ?? 0} ₸',
      );

      sheetObject.cell(CellIndex.indexByString('A6')).value = TextCellValue(
        'Ожидается:',
      );
      sheetObject.cell(CellIndex.indexByString('A6')).cellStyle = totalStyle;
      sheetObject.cell(CellIndex.indexByString('B6')).value = TextCellValue(
        '${summary['pendingAmount'] ?? 0} ₸',
      );

      sheetObject.cell(CellIndex.indexByString('A7')).value = TextCellValue(
        'Оборот:',
      );
      sheetObject.cell(CellIndex.indexByString('A7')).cellStyle = totalStyle;
      sheetObject.cell(CellIndex.indexByString('B7')).value = TextCellValue(
        '${summary['grossRevenue'] ?? 0} ₸',
      );

      sheetObject.cell(CellIndex.indexByString('A8')).value = TextCellValue(
        'Чистый доход:',
      );
      sheetObject.cell(CellIndex.indexByString('A8')).cellStyle = totalStyle;
      sheetObject.cell(CellIndex.indexByString('B8')).value = TextCellValue(
        '${summary['netRevenue'] ?? 0} ₸',
      );

      // Бронирования
      sheetObject.cell(CellIndex.indexByString('A10')).value = TextCellValue(
        'БРОНИРОВАНИЯ',
      );
      sheetObject.cell(CellIndex.indexByString('A10')).cellStyle = headerStyle;

      sheetObject.cell(CellIndex.indexByString('A11')).value = TextCellValue(
        'Всего броней:',
      );
      sheetObject.cell(CellIndex.indexByString('A11')).cellStyle = totalStyle;
      sheetObject.cell(CellIndex.indexByString('B11')).value = TextCellValue(
        '${summary['totalBookings'] ?? 0}',
      );

      sheetObject.cell(CellIndex.indexByString('A12')).value = TextCellValue(
        'Онлайн:',
      );
      sheetObject.cell(CellIndex.indexByString('A12')).cellStyle = totalStyle;
      sheetObject.cell(CellIndex.indexByString('B12')).value = TextCellValue(
        '${summary['onlineBookings'] ?? 0}',
      );

      sheetObject.cell(CellIndex.indexByString('A13')).value = TextCellValue(
        'Оффлайн:',
      );
      sheetObject.cell(CellIndex.indexByString('A13')).cellStyle = totalStyle;
      sheetObject.cell(CellIndex.indexByString('B13')).value = TextCellValue(
        '${summary['offlineBookings'] ?? 0}',
      );

      // Комиссия
      sheetObject.cell(CellIndex.indexByString('A15')).value = TextCellValue(
        'КОМИССИЯ',
      );
      sheetObject.cell(CellIndex.indexByString('A15')).cellStyle = headerStyle;

      sheetObject.cell(CellIndex.indexByString('A16')).value = TextCellValue(
        'Комиссия платформы:',
      );
      sheetObject.cell(CellIndex.indexByString('A16')).cellStyle = totalStyle;
      sheetObject.cell(CellIndex.indexByString('B16')).value = TextCellValue(
        '${summary['platformCommission'] ?? 0} ₸',
      );

      final totalBookings = summary['totalBookings'] as int? ?? 0;
      final grossRevenue = summary['grossRevenue'] as num? ?? 0;
      final avgCheck = totalBookings > 0
          ? (grossRevenue / totalBookings).toStringAsFixed(0)
          : '0';

      sheetObject.cell(CellIndex.indexByString('A17')).value = TextCellValue(
        'Средний чек:',
      );
      sheetObject.cell(CellIndex.indexByString('A17')).cellStyle = totalStyle;
      sheetObject.cell(CellIndex.indexByString('B17')).value = TextCellValue(
        '$avgCheck ₸',
      );

      // Заголовки таблицы транзакций
      List<String> headers = [
        '№',
        'Дата',
        'Время начала',
        'Время окончания',
        'Клиент',
        'Арена',
        'Сумма',
        'Тип оплаты',
      ];

      for (int i = 0; i < headers.length; i++) {
        var cell = sheetObject.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 19),
        );
        cell.value = TextCellValue(headers[i]);
        cell.cellStyle = headerStyle;
      }

      // Данные транзакций
      for (int i = 0; i < transactions.length; i++) {
        final transaction = transactions[i];
        final rowIndex = i + 20;

        final dateStr = transaction['date']?.toString() ?? '';
        final date = dateStr.isNotEmpty
            ? DateTime.tryParse(dateStr) ?? DateTime.now()
            : DateTime.now();

        // №
        sheetObject
            .cell(
              CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
            )
            .value = TextCellValue(
          '${i + 1}',
        );

        // Дата
        sheetObject
            .cell(
              CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex),
            )
            .value = TextCellValue(
          DateFormat('dd.MM.yyyy').format(date),
        );

        // Время начала
        sheetObject
            .cell(
              CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex),
            )
            .value = TextCellValue(
          transaction['startTime']?.toString() ?? '',
        );

        // Время окончания
        sheetObject
            .cell(
              CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex),
            )
            .value = TextCellValue(
          transaction['endTime']?.toString() ?? '',
        );

        // Клиент
        sheetObject
            .cell(
              CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex),
            )
            .value = TextCellValue(
          transaction['clientName']?.toString() ?? 'N/A',
        );

        // Арена
        sheetObject
            .cell(
              CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex),
            )
            .value = TextCellValue(
          transaction['arena']?.toString() ?? 'N/A',
        );

        // Сумма
        sheetObject
            .cell(
              CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex),
            )
            .value = TextCellValue(
          '${transaction['amount'] ?? 0}',
        );

        // Тип оплаты
        String paymentType = transaction['paymentType'] == 'online'
            ? 'Онлайн'
            : 'Оффлайн';
        sheetObject
            .cell(
              CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex),
            )
            .value = TextCellValue(
          paymentType,
        );
      }

      // Сохранение файла
      var fileBytes = excel.encode();

      if (fileBytes != null) {
        final blob = html.Blob([
          fileBytes,
        ], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute(
            'download',
            'Финансы_${DateFormat('dd-MM-yyyy').format(DateTime.now())}.xlsx',
          )
          ..click();
        html.Url.revokeObjectUrl(url);

        // Показать уведомление об успехе
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Excel файл успешно загружен'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      print('Error exporting to Excel: $e');
      // Показать ошибку
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при экспорте: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
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
                              SizedBox(height: isMobile ? 16 : 24),
                              _buildBookingsRow(
                                isMobile,
                                isTablet,
                                isDesktop,
                                summary,
                              ),
                              SizedBox(height: isMobile ? 16 : 24),
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
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.download),
                        onPressed: _exportToCsv,
                        tooltip: 'Экспорт CSV',
                        iconSize: 28,
                      ),
                    ],
                  ),
                ],
              ),
      ],
    );
  }

  // Остальные методы остаются без изменений...
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

    return _buildCardRow(isMobile, isTablet, isDesktop, cards);
  }

  Widget _buildCardRow(
    bool isMobile,
    bool isTablet,
    bool isDesktop,
    List<Map<String, dynamic>> cards,
  ) {
    if (isMobile) {
      // Mobile: 2 columns grid
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
      // Tablet: 2x2 grid for 4 cards, single row for 2-3 cards
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
      // Desktop or Tablet with <= 3 cards: Single row
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
          // Header section - responsive
          isMobile
              ? Column(
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
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () =>
                                _showCompactDatePicker(context, isMobile),
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
                          onPressed: () =>
                              _exportToExcel(transactions, summary),
                          tooltip: 'Экспорт в Excel',
                        ),
                      ],
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Транзакции',
                      style: TextStyle(
                        fontSize: isTablet ? 22 : 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.file_download,
                            color: Colors.green.shade600,
                          ),
                          onPressed: () =>
                              _exportToExcel(transactions, summary),
                          tooltip: 'Экспорт в Excel',
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () =>
                              _showCompactDatePicker(context, isMobile),
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
          if (transactions.isEmpty)
            Center(
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
          contentPadding: EdgeInsets.symmetric(
            horizontal: isMobile ? 0 : 16,
            vertical: isMobile ? 4 : 8,
          ),
          leading: CircleAvatar(
            radius: isMobile ? 18 : 20,
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
              size: isMobile ? 16 : 20,
            ),
          ),
          title: Text(
            transaction['clientName']?.toString() ?? 'N/A',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: isMobile ? 14 : 16,
            ),
          ),
          subtitle: Text(
            '${transaction['arena'] ?? 'N/A'} • ${DateFormat('dd.MM.yyyy').format(date)}\n${transaction['startTime'] ?? ''} - ${transaction['endTime'] ?? ''}',
            style: TextStyle(fontSize: isMobile ? 12 : 14),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatCurrency(transaction['amount']),
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
              Text(
                transaction['paymentType'] == 'online' ? 'Онлайн' : 'Оффлайн',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: isMobile ? 11 : 12,
                ),
              ),
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
