import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kff_owner_admin/app/screens/booking/bloc/booking_bloc.dart';
import 'package:kff_owner_admin/app/screens/my_arena/bloc/my_arena_bloc.dart';
import 'package:excel/excel.dart' hide Border;
import 'dart:html' as html;
import 'dart:convert';

class BookingsOverviewWidget extends StatefulWidget {
  const BookingsOverviewWidget({super.key});

  @override
  State<BookingsOverviewWidget> createState() => _BookingsOverviewWidgetState();
}

class _BookingsOverviewWidgetState extends State<BookingsOverviewWidget> {
  DateTime selectedMonth = DateTime.now();
  String? selectedArenaFilter;
  String? selectedStatusFilter;
  DateTimeRange? customPeriod;
  bool isCustomPeriod = false;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  void _loadBookings() {
    DateTime startDate;
    DateTime endDate;

    if (isCustomPeriod && customPeriod != null) {
      startDate = customPeriod!.start;
      endDate = customPeriod!.end;
    } else {
      startDate = DateTime(selectedMonth.year, selectedMonth.month, 1);
      endDate = DateTime(selectedMonth.year, selectedMonth.month + 1, 0);
    }

    final startStr = DateFormat('yyyy-MM-dd').format(startDate);
    final endStr = DateFormat('yyyy-MM-dd').format(endDate);

    context.read<BookingBloc>().add(
      BookingGetByPeriod(startDate: startStr, endDate: endStr),
    );
  }

  void _previousMonth() {
    setState(() {
      isCustomPeriod = false;
      customPeriod = null;
      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month - 1);
      _loadBookings();
    });
  }

  void _nextMonth() {
    setState(() {
      isCustomPeriod = false;
      customPeriod = null;
      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month + 1);
      _loadBookings();
    });
  }

  void _selectCustomPeriod() async {
    DateTime? startDate;
    DateTime? endDate;
    DateTime displayMonth = DateTime.now();

    final screenWidth = MediaQuery.of(context).size.width;
    final dialogMaxWidth = screenWidth < 600 ? screenWidth * 0.95 : 400.0;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: EdgeInsets.all(screenWidth < 600 ? 16 : 24),
                constraints: BoxConstraints(maxWidth: dialogMaxWidth),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Выберите период',
                              style: TextStyle(
                                fontSize: screenWidth < 600 ? 18 : 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.all(screenWidth < 600 ? 12 : 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: screenWidth < 600
                            ? Column(
                                children: [
                                  _buildDateDisplay(
                                    'Начало',
                                    startDate,
                                    screenWidth,
                                  ),
                                  const SizedBox(height: 8),
                                  const Icon(
                                    Icons.arrow_downward,
                                    color: Colors.grey,
                                    size: 16,
                                  ),
                                  const SizedBox(height: 8),
                                  _buildDateDisplay(
                                    'Конец',
                                    endDate,
                                    screenWidth,
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  Expanded(
                                    child: _buildDateDisplay(
                                      'Начало',
                                      startDate,
                                      screenWidth,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildDateDisplay(
                                      'Конец',
                                      endDate,
                                      screenWidth,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {
                              setDialogState(() {
                                displayMonth = DateTime(
                                  displayMonth.year,
                                  displayMonth.month - 1,
                                );
                              });
                            },
                            icon: const Icon(Icons.chevron_left),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                _formatMonthYear(displayMonth),
                                style: TextStyle(
                                  fontSize: screenWidth < 600 ? 14 : 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setDialogState(() {
                                displayMonth = DateTime(
                                  displayMonth.year,
                                  displayMonth.month + 1,
                                );
                              });
                            },
                            icon: const Icon(Icons.chevron_right),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildCalendar(
                        displayMonth,
                        startDate,
                        endDate,
                        screenWidth,
                        (date) {
                          setDialogState(() {
                            if (startDate == null || endDate != null) {
                              startDate = date;
                              endDate = null;
                            } else {
                              if (date.isBefore(startDate!)) {
                                endDate = startDate;
                                startDate = date;
                              } else {
                                endDate = date;
                              }
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      screenWidth < 600
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    setDialogState(() {
                                      startDate = null;
                                      endDate = null;
                                    });
                                  },
                                  child: const Text(
                                    'Сбросить',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text(
                                          'Отмена',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed:
                                            startDate != null && endDate != null
                                            ? () {
                                                Navigator.pop(context, true);
                                              }
                                            : null,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        child: const Text('Применить'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    setDialogState(() {
                                      startDate = null;
                                      endDate = null;
                                    });
                                  },
                                  child: const Text(
                                    'Сбросить',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                                Row(
                                  children: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text(
                                        'Отмена',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    ElevatedButton(
                                      onPressed:
                                          startDate != null && endDate != null
                                          ? () {
                                              Navigator.pop(context, true);
                                            }
                                          : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      child: const Text('Применить'),
                                    ),
                                  ],
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
    ).then((result) {
      if (result == true && startDate != null && endDate != null) {
        setState(() {
          customPeriod = DateTimeRange(start: startDate!, end: endDate!);
          isCustomPeriod = true;
          _loadBookings();
        });
      }
    });
  }

  Widget _buildDateDisplay(String label, DateTime? date, double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: screenWidth < 600 ? 11 : 12,
            color: const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          date != null ? _formatDate(date) : 'Не выбрано',
          style: TextStyle(
            fontSize: screenWidth < 600 ? 14 : 16,
            fontWeight: FontWeight.w600,
            color: date != null ? Colors.black : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendar(
    DateTime month,
    DateTime? startDate,
    DateTime? endDate,
    double screenWidth,
    Function(DateTime) onDateSelected,
  ) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = firstDayOfMonth.weekday;

    final cellSize = screenWidth < 600 ? 36.0 : 40.0;
    final fontSize = screenWidth < 600 ? 11.0 : 12.0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс']
              .map(
                (day) => SizedBox(
                  width: cellSize,
                  child: Center(
                    child: Text(
                      day,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        Wrap(
          children: [
            ...List.generate(
              firstWeekday - 1,
              (index) => SizedBox(width: cellSize, height: cellSize),
            ),
            ...List.generate(daysInMonth, (index) {
              final date = DateTime(month.year, month.month, index + 1);
              final isStart =
                  startDate != null &&
                  date.year == startDate.year &&
                  date.month == startDate.month &&
                  date.day == startDate.day;
              final isEnd =
                  endDate != null &&
                  date.year == endDate.year &&
                  date.month == endDate.month &&
                  date.day == endDate.day;
              final isInRange =
                  startDate != null &&
                  endDate != null &&
                  date.isAfter(startDate) &&
                  date.isBefore(endDate);

              Color? bgColor;
              Color? textColor;
              bool isCircle = false;

              if (isStart || isEnd) {
                bgColor = Colors.blue;
                textColor = Colors.white;
                isCircle = true;
              } else if (isInRange) {
                bgColor = Colors.blue.withOpacity(0.1);
                textColor = Colors.black;
              }

              return InkWell(
                onTap: () => onDateSelected(date),
                child: Container(
                  width: cellSize,
                  height: cellSize,
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
                    borderRadius: isCircle ? null : BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: screenWidth < 600 ? 12 : 14,
                        fontWeight: isStart || isEnd
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: textColor ?? Colors.black,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  String _formatMonthYear(DateTime date) {
    const months = [
      'Январь',
      'Февраль',
      'Март',
      'Апрель',
      'Май',
      'Июнь',
      'Июль',
      'Август',
      'Сентябрь',
      'Октябрь',
      'Ноябрь',
      'Декабрь',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  void _resetPeriod() {
    setState(() {
      isCustomPeriod = false;
      customPeriod = null;
      selectedMonth = DateTime.now();
      _loadBookings();
    });
  }

  String _getPeriodText() {
    if (isCustomPeriod && customPeriod != null) {
      return '${DateFormat('dd.MM.yyyy').format(customPeriod!.start)} - ${DateFormat('dd.MM.yyyy').format(customPeriod!.end)}';
    }
    return DateFormat('MMMM yyyy', 'ru').format(selectedMonth);
  }

  // Функция экспорта в Excel
  // Функция экспорта в Excel
  // Функция экспорта в Excel
  Future<void> _exportToExcel(
    List<Map<String, dynamic>> bookings,
    Map<String, dynamic> statistics,
  ) async {
    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Бронирования'];

      // Удаляем дефолтный лист если он есть
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
      titleCell.value = TextCellValue('Отчет по бронированиям');
      titleCell.cellStyle = titleStyleCell;

      var periodCell = sheetObject.cell(CellIndex.indexByString('A2'));
      periodCell.value = TextCellValue('Период: ${_getPeriodText()}');

      // Статистика
      var stat1Label = sheetObject.cell(CellIndex.indexByString('A4'));
      stat1Label.value = TextCellValue('Всего бронирований:');
      stat1Label.cellStyle = totalStyle;

      var stat1Value = sheetObject.cell(CellIndex.indexByString('B4'));
      stat1Value.value = TextCellValue('${bookings.length}');

      var stat2Label = sheetObject.cell(CellIndex.indexByString('A5'));
      stat2Label.value = TextCellValue('Всего начислено (оборот):');
      stat2Label.cellStyle = totalStyle;

      var stat2Value = sheetObject.cell(CellIndex.indexByString('B5'));
      stat2Value.value = TextCellValue('${statistics['totalRevenue'] ?? 0} ₸');

      var stat3Label = sheetObject.cell(CellIndex.indexByString('A6'));
      stat3Label.value = TextCellValue('Оплачено:');
      stat3Label.cellStyle = totalStyle;

      var stat3Value = sheetObject.cell(CellIndex.indexByString('B6'));
      stat3Value.value = TextCellValue('${statistics['totalPrepaid'] ?? 0} ₸');

      var stat4Label = sheetObject.cell(CellIndex.indexByString('A7'));
      stat4Label.value = TextCellValue('К оплате:');
      stat4Label.cellStyle = totalStyle;

      var stat4Value = sheetObject.cell(CellIndex.indexByString('B7'));
      stat4Value.value = TextCellValue(
        '${statistics['totalRemaining'] ?? 0} ₸',
      );

      // Заголовки таблицы
      List<String> headers = [
        '№',
        'Дата',
        'Время',
        'Арена',
        'Клиент',
        'Телефон',
        'Общая сумма',
        'Предоплата',
        'Осталось',
        'Статус оплаты',
        'Статус',
        'Тип',
      ];

      for (int i = 0; i < headers.length; i++) {
        var cell = sheetObject.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 9),
        );
        cell.value = TextCellValue(headers[i]);
        cell.cellStyle = headerStyle;
      }

      // Данные бронирований
      for (int i = 0; i < bookings.length; i++) {
        final booking = bookings[i];
        final rowIndex = i + 10;

        // №
        var numCell = sheetObject.cell(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
        );
        numCell.value = TextCellValue('${i + 1}');

        // Дата
        var dateCell = sheetObject.cell(
          CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex),
        );
        dateCell.value = TextCellValue(booking['date'] ?? '');

        // Время
        var timeCell = sheetObject.cell(
          CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex),
        );
        timeCell.value = TextCellValue(booking['time'] ?? '');

        // Арена
        var arenaCell = sheetObject.cell(
          CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex),
        );
        arenaCell.value = TextCellValue(booking['arenaName'] ?? '');

        // Клиент
        var clientCell = sheetObject.cell(
          CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex),
        );
        clientCell.value = TextCellValue(booking['clientName'] ?? '');

        // Телефон
        var phoneCell = sheetObject.cell(
          CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex),
        );
        phoneCell.value = TextCellValue(booking['clientPhone'] ?? '');

        // Общая сумма
        var totalCell = sheetObject.cell(
          CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex),
        );
        totalCell.value = TextCellValue('${booking['totalPrice'] ?? 0}');

        // Предоплата
        var prepaidCell = sheetObject.cell(
          CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex),
        );
        prepaidCell.value = TextCellValue('${booking['prepaidAmount'] ?? 0}');

        // Осталось
        var remainingCell = sheetObject.cell(
          CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: rowIndex),
        );
        remainingCell.value = TextCellValue(
          '${booking['remainingAmount'] ?? 0}',
        );

        // Статус оплаты
        String paymentStatus = booking['paymentStatus'] ?? 'Unpaid';
        String paymentStatusRu = paymentStatus == 'FullyPaid'
            ? 'Оплачено'
            : paymentStatus == 'PartiallyPaid'
            ? 'Частично оплачено'
            : 'Не оплачено';

        var paymentStatusCell = sheetObject.cell(
          CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: rowIndex),
        );
        paymentStatusCell.value = TextCellValue(paymentStatusRu);

        // Статус бронирования
        String bookingStatus = booking['status'] ?? 'Pending';
        String bookingStatusRu = bookingStatus == 'Completed'
            ? 'Завершено'
            : bookingStatus == 'Cancelled'
            ? 'Отменено'
            : 'В ожидании';

        var statusCell = sheetObject.cell(
          CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: rowIndex),
        );
        statusCell.value = TextCellValue(bookingStatusRu);

        // Тип
        var typeCell = sheetObject.cell(
          CellIndex.indexByColumnRow(columnIndex: 11, rowIndex: rowIndex),
        );
        typeCell.value = TextCellValue(
          booking['isOfflineBooking'] == true ? 'Оффлайн' : 'Онлайн',
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
            'Бронирования_${DateFormat('dd-MM-yyyy').format(DateTime.now())}.xlsx',
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
      print('Error exporting to Excel: $e'); // Для отладки
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;

    final containerPadding = isMobile ? 16.0 : (isTablet ? 20.0 : 24.0);
    final titleFontSize = isMobile ? 20.0 : 24.0;
    final subtitleFontSize = isMobile ? 13.0 : 15.0;

    return Container(
      padding: EdgeInsets.all(containerPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          // Header with navigation
          if (isMobile)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Все бронирования',
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      isCustomPeriod ? Icons.date_range : Icons.calendar_month,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _getPeriodText(),
                        style: TextStyle(
                          fontSize: subtitleFontSize,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (!isCustomPeriod) ...[
                      IconButton(
                        icon: const Icon(Icons.chevron_left, size: 20),
                        onPressed: _previousMonth,
                        tooltip: 'Предыдущий месяц',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.chevron_right, size: 20),
                        onPressed: _nextMonth,
                        tooltip: 'Следующий месяц',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _selectCustomPeriod,
                        icon: const Icon(Icons.date_range, size: 16),
                        label: Text(
                          'Период',
                          style: TextStyle(fontSize: isMobile ? 13 : 14),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue,
                          side: const BorderSide(color: Colors.blue),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                    if (isCustomPeriod) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: _resetPeriod,
                        tooltip: 'Сбросить период',
                        color: Colors.red,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ],
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Все бронирования',
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            isCustomPeriod
                                ? Icons.date_range
                                : Icons.calendar_month,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _getPeriodText(),
                            style: TextStyle(
                              fontSize: subtitleFontSize,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Кнопка экспорта в Excel
                BlocBuilder<BookingBloc, BookingState>(
                  builder: (context, state) {
                    if (state is BookingsByPeriodLoaded) {
                      var bookings = state.bookings;
                      final statistics = state.statistics;

                      // Применяем фильтры
                      if (selectedArenaFilter != null) {
                        bookings = bookings
                            .where((b) => b['arenaId'] == selectedArenaFilter)
                            .toList();
                      }

                      if (selectedStatusFilter != null) {
                        if (selectedStatusFilter == 'Active') {
                          bookings = bookings.where((b) {
                            final status = b['status'] ?? 'Pending';
                            return status != 'Completed' &&
                                status != 'Cancelled';
                          }).toList();
                        } else {
                          bookings = bookings
                              .where((b) => b['status'] == selectedStatusFilter)
                              .toList();
                        }
                      }

                      return IconButton(
                        icon: const Icon(Icons.file_download),
                        onPressed: bookings.isNotEmpty
                            ? () => _exportToExcel(bookings, statistics)
                            : null,
                        tooltip: 'Экспорт в Excel',
                        color: Colors.green,
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                if (!isCustomPeriod) ...[
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _previousMonth,
                    tooltip: 'Предыдущий месяц',
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _nextMonth,
                    tooltip: 'Следующий месяц',
                  ),
                ],
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _selectCustomPeriod,
                  icon: const Icon(Icons.date_range, size: 18),
                  label: const Text('Выбрать период'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue,
                    side: const BorderSide(color: Colors.blue),
                  ),
                ),
                if (isCustomPeriod) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _resetPeriod,
                    tooltip: 'Сбросить период',
                    color: Colors.red,
                  ),
                ],
              ],
            ),

          SizedBox(height: isMobile ? 16 : 20),

          // Filters
          BlocBuilder<MyArenaBloc, MyArenaState>(
            builder: (context, arenaState) {
              if (arenaState is MyArenaLoaded) {
                final arenas = arenaState.arenas;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Арена:',
                      style: TextStyle(
                        fontSize: isMobile ? 13 : 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilterChip(
                          label: Text(
                            'Все',
                            style: TextStyle(fontSize: isMobile ? 12 : 14),
                          ),
                          selected: selectedArenaFilter == null,
                          onSelected: (selected) {
                            setState(() {
                              selectedArenaFilter = null;
                            });
                          },
                          selectedColor: Colors.blue.shade100,
                          checkmarkColor: Colors.blue,
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 8 : 12,
                            vertical: isMobile ? 4 : 8,
                          ),
                        ),
                        ...arenas.map((arena) {
                          final arenaId = arena['_id'];
                          final arenaName = arena['name'] ?? 'Без названия';

                          return FilterChip(
                            label: Text(
                              arenaName,
                              style: TextStyle(fontSize: isMobile ? 12 : 14),
                            ),
                            selected: selectedArenaFilter == arenaId,
                            onSelected: (selected) {
                              setState(() {
                                selectedArenaFilter = selected ? arenaId : null;
                              });
                            },
                            selectedColor: Colors.blue.shade100,
                            checkmarkColor: Colors.blue,
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 8 : 12,
                              vertical: isMobile ? 4 : 8,
                            ),
                          );
                        }),
                      ],
                    ),
                    SizedBox(height: isMobile ? 12 : 16),
                    Text(
                      'Статус:',
                      style: TextStyle(
                        fontSize: isMobile ? 13 : 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilterChip(
                          label: Text(
                            'Все',
                            style: TextStyle(fontSize: isMobile ? 12 : 14),
                          ),
                          selected: selectedStatusFilter == null,
                          onSelected: (selected) {
                            setState(() {
                              selectedStatusFilter = null;
                            });
                          },
                          selectedColor: Colors.grey.shade200,
                          checkmarkColor: Colors.grey.shade700,
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 8 : 12,
                            vertical: isMobile ? 4 : 8,
                          ),
                        ),
                        _buildStatusFilterChip(
                          'Активные',
                          'Active',
                          Icons.access_time,
                          Colors.blue,
                          isMobile,
                        ),
                        _buildStatusFilterChip(
                          'Завершенные',
                          'Completed',
                          Icons.check_circle,
                          Colors.green,
                          isMobile,
                        ),
                        _buildStatusFilterChip(
                          'Отмененные',
                          'Cancelled',
                          Icons.cancel,
                          Colors.red,
                          isMobile,
                        ),
                      ],
                    ),
                  ],
                );
              }
              return const SizedBox();
            },
          ),

          SizedBox(height: isMobile ? 20 : 24),
          const Divider(),
          SizedBox(height: isMobile ? 12 : 16),

          // Bookings list
          BlocBuilder<BookingBloc, BookingState>(
            builder: (context, state) {
              if (state is BookingsByPeriodLoaded) {
                final statistics = state.statistics;
                var bookings = state.bookings;

                // Filter by arena
                if (selectedArenaFilter != null) {
                  bookings = bookings
                      .where((b) => b['arenaId'] == selectedArenaFilter)
                      .toList();
                }

                // Filter by status
                if (selectedStatusFilter != null) {
                  if (selectedStatusFilter == 'Active') {
                    bookings = bookings.where((b) {
                      final status = b['status'] ?? 'Pending';
                      return status != 'Completed' && status != 'Cancelled';
                    }).toList();
                  } else {
                    bookings = bookings
                        .where((b) => b['status'] == selectedStatusFilter)
                        .toList();
                  }
                }

                if (bookings.isEmpty) {
                  return _buildEmptyState(isMobile);
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Statistics cards - responsive layout
                    _buildStatisticsGrid(statistics, bookings.length, isMobile),
                    SizedBox(height: isMobile ? 16 : 20),
                    ...bookings.map(
                      (booking) => _buildBookingCard(booking, isMobile),
                    ),
                  ],
                );
              }

              if (state is BookingLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              return _buildEmptyState(isMobile);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilterChip(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isMobile,
  ) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isMobile ? 14 : 16, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: isMobile ? 12 : 14)),
        ],
      ),
      selected: selectedStatusFilter == value,
      onSelected: (selected) {
        setState(() {
          selectedStatusFilter = selected ? value : null;
        });
      },
      selectedColor: color.withOpacity(0.2),
      checkmarkColor: color,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 12,
        vertical: isMobile ? 4 : 8,
      ),
    );
  }

  Widget _buildStatisticsGrid(
    Map<String, dynamic> statistics,
    int bookingsCount,
    bool isMobile,
  ) {
    final statCards = [
      _StatCardData(
        'Всего бронирований',
        '$bookingsCount',
        Icons.event_note,
        Colors.blue,
      ),
      _StatCardData(
        'Всего начислено (оборот)',
        '${statistics['totalRevenue'] ?? 0} ₸',
        Icons.account_balance_wallet,
        Colors.green,
      ),
      _StatCardData(
        'Оплачено',
        '${statistics['totalPrepaid'] ?? 0} ₸',
        Icons.check_circle,
        Colors.teal,
      ),
      _StatCardData(
        'К оплате',
        '${statistics['totalRemaining'] ?? 0} ₸',
        Icons.pending,
        Colors.orange,
      ),
    ];

    if (isMobile) {
      // Mobile: 2 columns grid
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildStatCard(statCards[0], isMobile)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard(statCards[1], isMobile)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStatCard(statCards[2], isMobile)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard(statCards[3], isMobile)),
            ],
          ),
        ],
      );
    } else {
      // Tablet & Desktop: Single row
      return Row(
        children: statCards
            .map(
              (data) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _buildStatCard(data, isMobile),
                ),
              ),
            )
            .toList(),
      );
    }
  }

  Widget _buildStatCard(_StatCardData data, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: data.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: data.color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(data.icon, color: data.color, size: isMobile ? 18 : 20),
          SizedBox(height: isMobile ? 6 : 8),
          Text(
            data.value,
            style: TextStyle(
              fontSize: isMobile ? 16 : 20,
              fontWeight: FontWeight.bold,
              color: data.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.title,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: isMobile ? 11 : 12,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking, bool isMobile) {
    final arenaName = booking['arenaName'] ?? 'Неизвестная арена';
    final date = booking['date'] ?? '';
    final time = booking['time'] ?? '';
    final clientName = booking['clientName'] ?? 'Не указан';
    final clientPhone = booking['clientPhone'] ?? 'Не указан';
    final totalPrice = booking['totalPrice'] ?? 0;
    final prepaidAmount = booking['prepaidAmount'] ?? 0;
    final remainingAmount = booking['remainingAmount'] ?? 0;
    final paymentStatus = booking['paymentStatus'] ?? 'Unpaid';
    final bookingStatus = booking['status'] ?? 'Pending';
    final isOffline = booking['isOfflineBooking'] ?? false;

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
      margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      arenaName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 14 : 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$date • $time',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: isMobile ? 12 : 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 6 : 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isOffline
                      ? Colors.grey.shade200
                      : Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isOffline ? 'Оффлайн' : 'Онлайн',
                  style: TextStyle(
                    fontSize: isMobile ? 10 : 11,
                    fontWeight: FontWeight.bold,
                    color: isOffline ? Colors.grey.shade700 : Colors.purple,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 10 : 12),
          const Divider(height: 1),
          SizedBox(height: isMobile ? 10 : 12),
          if (isMobile)
            // Mobile: Stack vertically
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Клиент:',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      clientName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      clientPhone,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(statusIcon, size: 14, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$totalPrice ₸',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (prepaidAmount > 0)
                          Text(
                            'Предоплата: $prepaidAmount ₸',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        if (remainingAmount > 0)
                          Text(
                            'Осталось: $remainingAmount ₸',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            )
          else
            // Tablet & Desktop: Side by side
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Клиент:',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        clientName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        clientPhone,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Icon(statusIcon, size: 16, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$totalPrice ₸',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (prepaidAmount > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Предоплата: $prepaidAmount ₸',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                    if (remainingAmount > 0) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Осталось: $remainingAmount ₸',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isMobile) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 32.0 : 48.0),
        child: Column(
          children: [
            Icon(
              Icons.event_busy,
              size: isMobile ? 48 : 64,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: isMobile ? 12 : 16),
            Text(
              'Нет бронирований за выбранный период',
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Helper class for stat card data
class _StatCardData {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  _StatCardData(this.title, this.value, this.icon, this.color);
}
