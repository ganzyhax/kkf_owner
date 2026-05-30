import 'dart:developer';

import 'package:excel/excel.dart' hide Border;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kff_owner_admin/app/api/api.dart';
import 'package:kff_owner_admin/app/models/service_model.dart';
import 'package:kff_owner_admin/app/screens/services/bloc/service_bloc.dart';
import 'package:kff_owner_admin/app/screens/services/bloc/service_event.dart';
import 'package:kff_owner_admin/app/screens/services/bloc/service_state.dart';
import 'package:kff_owner_admin/app/screens/services/components/service_form_dialog.dart';
import 'package:kff_owner_admin/app/screens/services/components/service_offline_booking_dialog.dart';
import 'dart:html' as html;

// ─────────────────────────────────────────────────────────────────────────────
// Type maps (same as other screens use)
// ─────────────────────────────────────────────────────────────────────────────
const _typeNames = <String, String>{
  'sauna': 'Сауна',
  'billiard': 'Бильярд',
  'hookah': 'Кальян',
  'tennis_table': 'Настольный теннис',
  'gym': 'Тренажёрный зал',
  'pool': 'Бассейн',
  'karaoke': 'Караоке',
  'other': 'Другое',
};

const _typeIcons = <String, IconData>{
  'sauna': Icons.thermostat,
  'billiard': Icons.sports,
  'hookah': Icons.smoke_free,
  'tennis_table': Icons.sports_tennis,
  'gym': Icons.fitness_center,
  'pool': Icons.pool,
  'karaoke': Icons.mic,
  'other': Icons.star,
};

// ─────────────────────────────────────────────────────────────────────────────
// Root entry point — sets up BLoC + state for bookings
// ─────────────────────────────────────────────────────────────────────────────
class ServiceDashboardScreen extends StatelessWidget {
  const ServiceDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ServiceBloc()..add(LoadServices()),
      child: const _ServiceDashboardContent(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Main content — single scrollable page, no tabs
// ─────────────────────────────────────────────────────────────────────────────
class _ServiceDashboardContent extends StatefulWidget {
  const _ServiceDashboardContent();

  @override
  State<_ServiceDashboardContent> createState() =>
      _ServiceDashboardContentState();
}

class _ServiceDashboardContentState extends State<_ServiceDashboardContent> {
  // ─── Bookings state ──────────────────────────────────────────────────────
  DateTime _startDate =
      DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _endDate =
      DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
  String _activeFilter = 'month';

  List<dynamic> _bookings = [];
  Map<String, dynamic> _statistics = {};
  List<dynamic> _byService = [];
  bool _isLoadingBookings = true;
  bool _isExporting = false;
  String? _selectedServiceId;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoadingBookings = true);
    try {
      final start = DateFormat('yyyy-MM-dd').format(_startDate);
      final end = DateFormat('yyyy-MM-dd').format(_endDate);
      final res = await ApiClient.get(
          'api/service-bookings/owner/by-period?startDate=$start&endDate=$end');
      if (res['success'] == true) {
        setState(() {
          _bookings = res['data']['bookings'] ?? [];
          _statistics = res['data']['statistics'] ?? {};
          _byService = res['data']['byService'] ?? [];
          _isLoadingBookings = false;
        });
      } else {
        setState(() => _isLoadingBookings = false);
      }
    } catch (e) {
      log('Error loading service bookings: $e');
      setState(() => _isLoadingBookings = false);
    }
  }

  List<dynamic> get _filteredBookings {
    if (_selectedServiceId == null) return _bookings;
    return _bookings.where((b) {
      final svc = b['service'] as Map<String, dynamic>?;
      return svc != null && svc['_id'] == _selectedServiceId;
    }).toList();
  }

  Map<String, dynamic> get _filteredStatistics {
    if (_selectedServiceId == null) return _statistics;
    final svcStats = _byService.firstWhere(
        (s) => s['serviceId'] == _selectedServiceId,
        orElse: () => null);
    if (svcStats == null) {
      return {
        'total': 0,
        'confirmed': 0,
        'pending': 0,
        'cancelled': 0,
        'completed': 0,
        'totalRevenue': 0,
      };
    }
    return {
      'total': svcStats['total'] ?? 0,
      'confirmed': svcStats['confirmed'] ?? 0,
      'pending': svcStats['pending'] ?? 0,
      'cancelled': svcStats['cancelled'] ?? 0,
      'completed': svcStats['completed'] ?? 0,
      'totalRevenue': svcStats['revenue'] ?? 0,
    };
  }

  void _selectToday() {
    final now = DateTime.now();
    setState(() {
      _startDate = DateTime(now.year, now.month, now.day);
      _endDate = DateTime(now.year, now.month, now.day);
      _activeFilter = 'today';
    });
    _loadBookings();
  }

  void _selectMonth() {
    final now = DateTime.now();
    setState(() {
      _startDate = DateTime(now.year, now.month, 1);
      _endDate = DateTime(now.year, now.month + 1, 0);
      _activeFilter = 'month';
    });
    _loadBookings();
  }

  Future<void> _selectCustomRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      helpText: 'Выберите период',
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _activeFilter = 'custom';
      });
      _loadBookings();
    }
  }

  Future<void> _markPaid(String id) async {
    try {
      final res = await ApiClient.patch(
          'api/service-bookings/$id/mark-paid', {'paymentMethod': 'Cash'});
      if (res['success'] == true) {
        _loadBookings();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('✅ Отмечено как оплачено'),
              backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      log('Error mark paid: $e');
    }
  }

  Future<void> _cancelBooking(String id) async {
    try {
      final res = await ApiClient.put('api/service-bookings/$id/cancel',
          {'cancellationReason': 'Отменено администратором'});
      if (res['success'] == true) {
        _loadBookings();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Бронь отменена'),
              backgroundColor: Colors.orange),
        );
      }
    } catch (e) {
      log('Error cancel: $e');
    }
  }

  // ─── Service helpers ─────────────────────────────────────────────────────
  void _showServiceDialog(BuildContext context, {ServiceModel? service}) {
    final bloc = context.read<ServiceBloc>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => BlocProvider.value(
        value: bloc,
        child: ServiceFormDialog(service: service),
      ),
    );
  }

  void _showOfflineBookingDialog(
      BuildContext context, List<ServiceModel> services) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ServiceOfflineBookingDialog(
        services: services,
        onCreated: _loadBookings,
      ),
    );
  }

  // ─── Excel Export ─────────────────────────────────────────────────────────
  Future<void> _exportToExcel() async {
    setState(() => _isExporting = true);
    try {
      final excel = Excel.createExcel();
      final periodLabel =
          '${DateFormat('dd.MM.yyyy').format(_startDate)} — ${DateFormat('dd.MM.yyyy').format(_endDate)}';

      // ── Лист 1: Сводная статистика ──────────────────────────────────────
      final summarySheet = excel['Сводка'];
      excel.setDefaultSheet('Сводка');

      _excelHeaderRow(summarySheet, 0, [
        'Показатель',
        'Значение',
      ], color: '#1E40AF');
      _excelRow(summarySheet, 1, ['Период', periodLabel]);
      final exportStats = _filteredStatistics;
      _excelRow(summarySheet, 2, ['Всего броней', exportStats['total']?.toString() ?? '0']);
      _excelRow(summarySheet, 3, ['Подтверждено', exportStats['confirmed']?.toString() ?? '0']);
      _excelRow(summarySheet, 4, ['Ожидают', exportStats['pending']?.toString() ?? '0']);
      _excelRow(summarySheet, 5, ['Завершено', exportStats['completed']?.toString() ?? '0']);
      _excelRow(summarySheet, 6, ['Отменено', exportStats['cancelled']?.toString() ?? '0']);
      _excelRow(summarySheet, 7, ['Выручка (₸)', exportStats['totalRevenue']?.toString() ?? '0']);

      summarySheet.setColumnWidth(0, 28);
      summarySheet.setColumnWidth(1, 24);

      // ── Лист 2: По услугам ──────────────────────────────────────────────
      final byServiceSheet = excel['По услугам'];
      _excelHeaderRow(byServiceSheet, 0, [
        'Услуга',
        'Тип',
        'Цена/час (₸)',
        'Всего броней',
        'Подтвержд.',
        'Ожидают',
        'Завершено',
        'Отменено',
        'Выручка (₸)',
        'Онлайн (₸)',
        'Оффлайн (₸)',
        'Часов всего',
      ], color: '#065F46');

      final exportByService = _selectedServiceId == null
          ? _byService
          : _byService.where((s) => s['serviceId'] == _selectedServiceId).toList();

      for (int i = 0; i < exportByService.length; i++) {
        final s = exportByService[i] as Map<String, dynamic>;
        final hours = (s['totalHours'] as num?)?.toStringAsFixed(1) ?? '0';
        _excelRow(byServiceSheet, i + 1, [
          s['serviceName'] ?? '—',
          _typeNameRu(s['serviceType'] ?? ''),
          s['pricePerHour']?.toString() ?? '0',
          s['total']?.toString() ?? '0',
          s['confirmed']?.toString() ?? '0',
          s['pending']?.toString() ?? '0',
          s['completed']?.toString() ?? '0',
          s['cancelled']?.toString() ?? '0',
          s['revenue']?.toString() ?? '0',
          s['onlineRevenue']?.toString() ?? '0',
          s['offlineRevenue']?.toString() ?? '0',
          hours,
        ]);
      }

      for (int c = 0; c < 12; c++) {
        byServiceSheet.setColumnWidth(c, c == 0 ? 26 : 14);
      }

      // ── Лист 3: Детали броней ────────────────────────────────────────────
      final bookingsSheet = excel['Бронирования'];
      _excelHeaderRow(bookingsSheet, 0, [
        '№',
        'Услуга',
        'Дата',
        'Начало',
        'Конец',
        'Клиент',
        'Телефон',
        'Статус',
        'Сумма (₸)',
        'Оплачено (₸)',
        'Долг (₸)',
        'Тип',
        'Способ оплаты',
      ], color: '#6D28D9');

      final exportBookings = _filteredBookings;

      for (int i = 0; i < exportBookings.length; i++) {
        final b = exportBookings[i] as Map<String, dynamic>;
        final svc = b['service'] as Map<String, dynamic>? ?? {};
        final user = b['user'] as Map<String, dynamic>? ?? {};
        final startRaw = b['startTime'];
        final endRaw = b['endTime'];
        final startDt = _parseDateSafe(startRaw);
        final endDt = _parseDateSafe(endRaw);
        final clientName = b['isOfflineBooking'] == true
            ? (b['clientName'] ?? 'Оффлайн')
            : (user['name'] ?? 'Онлайн');
        final clientPhone = b['isOfflineBooking'] == true
            ? (b['clientPhone'] ?? '—')
            : (user['phone'] ?? '—');

        _excelRow(bookingsSheet, i + 1, [
          (i + 1).toString(),
          svc['name'] ?? '—',
          startDt != null ? DateFormat('dd.MM.yyyy').format(startDt) : '—',
          startDt != null ? DateFormat('HH:mm').format(startDt) : '—',
          endDt != null ? DateFormat('HH:mm').format(endDt) : '—',
          clientName,
          clientPhone,
          _statusRu(b['status'] ?? ''),
          b['totalPrice']?.toString() ?? '0',
          b['prepaidAmount']?.toString() ?? '0',
          b['remainingAmount']?.toString() ?? '0',
          b['isOfflineBooking'] == true ? 'Оффлайн' : 'Онлайн',
          _paymentMethodRu(b),
        ]);
      }

      for (int c = 0; c < 13; c++) {
        bookingsSheet.setColumnWidth(c, c == 1 || c == 5 ? 24 : 14);
      }

      // ── Скачиваем ────────────────────────────────────────────────────────
      final fileBytes = excel.save();
      if (fileBytes == null) return;

      final blob = html.Blob([fileBytes],
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      final url = html.Url.createObjectUrlFromBlob(blob);
      (html.document.createElement('a') as html.AnchorElement)
        ..href = url
        ..setAttribute('download',
            'services_report_${DateFormat('yyyyMMdd').format(_startDate)}_${DateFormat('yyyyMMdd').format(_endDate)}.xlsx')
        ..click();
      html.Url.revokeObjectUrl(url);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Отчёт скачан'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      log('Export error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Ошибка экспорта: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  void _excelHeaderRow(Sheet sheet, int row, List<String> headers,
      {String color = '#1E3A5F'}) {
    for (int i = 0; i < headers.length; i++) {
      final cell = sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: row));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = CellStyle(
        bold: true,
        fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
        backgroundColorHex: ExcelColor.fromHexString(color),
        horizontalAlign: HorizontalAlign.Center,
      );
    }
  }

  void _excelRow(Sheet sheet, int row, List<String> values) {
    for (int i = 0; i < values.length; i++) {
      final cell = sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: row));
      cell.value = TextCellValue(values[i]);
      if (row % 2 == 0) {
        cell.cellStyle = CellStyle(
          backgroundColorHex: ExcelColor.fromHexString('#F8FAFC'),
        );
      }
    }
  }

  DateTime? _parseDateSafe(dynamic val) {
    if (val == null) return null;
    try {
      return DateTime.parse(val.toString().replaceAll(' ', 'T')).toLocal();
    } catch (_) {
      return null;
    }
  }

  String _typeNameRu(String type) {
    const m = {
      'sauna': 'Сауна',
      'billiard': 'Бильярд',
      'hookah': 'Кальян',
      'tennis_table': 'Настольный теннис',
      'gym': 'Тренажёрный зал',
      'pool': 'Бассейн',
      'karaoke': 'Караоке',
      'other': 'Другое',
    };
    return m[type] ?? type;
  }

  String _statusRu(String status) {
    const m = {
      'Reserved': 'В резерве',
      'Pending': 'Ожидает',
      'Confirmed': 'Подтверждено',
      'Completed': 'Завершено',
      'Cancelled': 'Отменено',
    };
    return m[status] ?? status;
  }

  String _paymentMethodRu(Map<String, dynamic> b) {
    final cash = (b['cashAmount'] ?? 0) as num;
    final kaspi = (b['kaspiAmount'] ?? 0) as num;
    final online = (b['onlineAmount'] ?? 0) as num;
    final parts = <String>[];
    if (cash > 0) parts.add('Нал');
    if (kaspi > 0) parts.add('Kaspi');
    if (online > 0) parts.add('Онлайн');
    return parts.isEmpty ? '—' : parts.join(', ');
  }

  void _showDeleteConfirm(BuildContext context, ServiceModel service) {
    final bloc = context.read<ServiceBloc>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить услугу?'),
        content: Text('Вы уверены, что хотите удалить "${service.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Отмена')),
          TextButton(
            onPressed: () {
              bloc.add(DeleteService(service.id));
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final horizontalPadding = isMobile ? 16.0 : 40.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: BlocListener<ServiceBloc, ServiceState>(
        listener: (context, state) {
          if (state is ServiceOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green),
            );
          } else if (state is ServiceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding, vertical: 40),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Page Header ──────────────────────────────────────
                    _buildPageHeader(context),
                    const SizedBox(height: 24),

                    // ── Service Selector ─────────────────────────────────
                    BlocBuilder<ServiceBloc, ServiceState>(
                      builder: (context, state) {
                        return _buildServiceSelector(context, state);
                      },
                    ),
                    const SizedBox(height: 24),

                    // ── Управление выбранной услугой / Добавление ────────
                    BlocBuilder<ServiceBloc, ServiceState>(
                      builder: (context, state) {
                        if (state is ServicesLoaded) {
                          if (state.services.isEmpty) {
                            return Column(
                              children: [
                                _buildEmptyServices(context),
                                const SizedBox(height: 24),
                              ],
                            );
                          }
                          if (_selectedServiceId != null) {
                            final idx = state.services.indexWhere((s) => s.id == _selectedServiceId);
                            if (idx != -1) {
                              final selectedSvc = state.services[idx];
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionTitle('Управление услугой', Icons.settings_outlined),
                                  const SizedBox(height: 16),
                                  _ServiceCard(
                                    service: selectedSvc,
                                    onEdit: () => _showServiceDialog(context, service: selectedSvc),
                                    onDelete: () => _showDeleteConfirm(context, selectedSvc),
                                  ),
                                  const SizedBox(height: 24),
                                ],
                              );
                            }
                          }
                        }
                        return const SizedBox();
                      },
                    ),

                    // ── Booking filter bar ───────────────────────────────
                    _buildFilterBar(),
                    const SizedBox(height: 24),

                    // ── Stats row ────────────────────────────────────────
                    _buildStatsRow(),
                    const SizedBox(height: 32),

                    // ── SECTION: Статистика по услугам ───────────────────
                    if (_byService.isNotEmpty) ...[
                      _buildSectionTitle(
                          'Статистика по услугам', Icons.bar_chart_rounded),
                      const SizedBox(height: 16),
                      _buildByServiceSection(),
                      const SizedBox(height: 40),
                    ],

                    // ── SECTION: Бронирования услуг ──────────────────────
                    _buildSectionTitle(
                        'Бронирования услуг', Icons.calendar_today),
                    const SizedBox(height: 16),
                    _isLoadingBookings
                        ? const Center(child: CircularProgressIndicator())
                        : _filteredBookings.isEmpty
                            ? _buildEmptyBookings()
                            : Column(
                                children: _filteredBookings
                                    .map((b) => _buildBookingCard(b))
                                    .toList(),
                              ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Page Header — like BookingPage._buildHeader
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildPageHeader(BuildContext context) {
    // Получаем текущий список услуг из состояния блока
    final bloc = context.read<ServiceBloc>();
    final state = bloc.state;
    final services = state is ServicesLoaded ? state.services : <ServiceModel>[];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Дополнительные услуги',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            Text(
              'Управление услугами и бронированиями',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        Row(
          children: [
            // Кнопка «Экспорт Excel»
            OutlinedButton.icon(
              onPressed: _isExporting ? null : _exportToExcel,
              icon: _isExporting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.download_rounded, size: 18),
              label: Text(_isExporting ? 'Экспорт...' : 'Excel'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF059669),
                side: const BorderSide(color: Color(0xFF059669)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(width: 12),
            // Кнопка «Добавить бронь»
            OutlinedButton.icon(
              onPressed: () => _showOfflineBookingDialog(context, services),
              icon: const Icon(Icons.event_available, size: 18),
              label: const Text('Добавить бронь'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue,
                side: const BorderSide(color: Colors.blue),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(width: 12),
            // Кнопка «Добавить услугу»
            ElevatedButton.icon(
              onPressed: () => _showServiceDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Добавить услугу'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Service Selector — Prominent block like in DashboardScreen
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildServiceSelector(BuildContext context, ServiceState state) {
    final services = state is ServicesLoaded ? state.services : <ServiceModel>[];
    final isMobile = MediaQuery.of(context).size.width < 600;

    if (state is ServiceLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Всегда показываем блок, даже если услуг пока нет
    // Это гарантирует, что пользователь видит возможность выбора

    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.spa, color: Color(0xFF6B7280), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Выберите услугу:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedServiceId,
                  hint: const Text('Все услуги (общая статистика)'),
                  isExpanded: true,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Row(
                        children: [
                          Icon(Icons.dashboard, size: 18),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Все услуги (общая статистика)',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const DropdownMenuItem<String>(
                      value: 'divider',
                      enabled: false,
                      child: Divider(),
                    ),
                    ...services.map((s) {
                      return DropdownMenuItem<String>(
                        value: s.id,
                        child: Text(
                          s.name,
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) {
                    if (value == 'divider') return;
                    setState(() {
                      _selectedServiceId = value;
                    });
                  },
                ),
              ],
            )
          : Row(
              children: [
                const Icon(Icons.spa, color: Color(0xFF6B7280), size: 20),
                const SizedBox(width: 12),
                const Text(
                  'Выберите услугу:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedServiceId,
                    hint: const Text('Все услуги (общая статистика)'),
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Row(
                          children: [
                            Icon(Icons.dashboard, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Все услуги (общая статистика)',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const DropdownMenuItem<String>(
                        value: 'divider',
                        enabled: false,
                        child: Divider(),
                      ),
                      ...services.map((s) {
                        return DropdownMenuItem<String>(
                          value: s.id,
                          child: Text(s.name),
                        );
                      }).toList(),
                    ],
                    onChanged: (value) {
                      if (value == 'divider') return;
                      setState(() {
                        _selectedServiceId = value;
                      });
                    },
                  ),
                ),
              ],
            ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Filter bar — same pattern as BookingPage._buildMainFilterBar
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildFilterBar() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05), blurRadius: 10),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _filterChip('Сегодня', 'today', _selectToday),
              const SizedBox(width: 8),
              Container(
                  width: 1, height: 24, color: Colors.grey.shade300),
              const SizedBox(width: 8),
              _filterChip('Месяц', 'month', _selectMonth),
              const SizedBox(width: 8),
              Container(
                  width: 1, height: 24, color: Colors.grey.shade300),
              const SizedBox(width: 8),
              _filterChip('Период', 'custom', _selectCustomRange),
            ],
          ),
        ),
        if (_activeFilter == 'custom') ...[
          const SizedBox(width: 12),
          Text(
            '${DateFormat('dd.MM.yy').format(_startDate)} — ${DateFormat('dd.MM.yy').format(_endDate)}',
            style:
                const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
          ),
        ],
        const Spacer(),
        IconButton(
          onPressed: _loadBookings,
          icon: const Icon(Icons.refresh, color: Color(0xFF6B7280)),
          tooltip: 'Обновить',
        ),
      ],
    );
  }

  Widget _filterChip(String label, String code, VoidCallback onTap) {
    final selected = _activeFilter == code;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: Colors.blue,
      labelStyle:
          TextStyle(color: selected ? Colors.white : Colors.black87),
      showCheckmark: false,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      side: BorderSide.none,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Stats — same card style as DashboardScreen
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildStatsRow() {
    final stats = _filteredStatistics;
    final cards = [
      {
        'label': 'Всего броней',
        'value': stats['total']?.toString() ?? '0',
        'icon': Icons.receipt_long,
        'color': const Color(0xFF2563EB),
      },
      {
        'label': 'Ожидают',
        'value': stats['pending']?.toString() ?? '0',
        'icon': Icons.hourglass_empty_rounded,
        'color': const Color(0xFFEAB308),
      },
      {
        'label': 'Подтверждены',
        'value': stats['confirmed']?.toString() ?? '0',
        'icon': Icons.check_circle_outline,
        'color': const Color(0xFF059669),
      },
      {
        'label': 'Отменены',
        'value': stats['cancelled']?.toString() ?? '0',
        'icon': Icons.cancel_outlined,
        'color': Colors.red,
      },
      {
        'label': 'Выручка',
        'value': '${stats['totalRevenue'] ?? 0} ₸',
        'icon': Icons.account_balance_wallet_rounded,
        'color': const Color(0xFF8B5CF6),
      },
    ];

    return Row(
      children: cards
          .map((c) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: _StatCard(
                    label: c['label'] as String,
                    value: c['value'] as String,
                    icon: c['icon'] as IconData,
                    color: c['color'] as Color,
                  ),
                ),
              ))
          .toList()
        ..last = Expanded(
          child: _StatCard(
            label: cards.last['label'] as String,
            value: cards.last['value'] as String,
            icon: cards.last['icon'] as IconData,
            color: cards.last['color'] as Color,
          ),
        ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // By Service Section
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildByServiceSection() {
    final filteredByService = _selectedServiceId == null
        ? _byService
        : _byService.where((s) => s['serviceId'] == _selectedServiceId).toList();

    if (filteredByService.isEmpty) return const SizedBox();

    return Container(
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
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(const Color(0xFFF9FAFB)),
          columns: const [
            DataColumn(label: Text('Услуга', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Всего', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Подтвержд.', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Отменено', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Часов', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Выручка', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: filteredByService.map((s) {
            final svc = s as Map<String, dynamic>;
            final hours = (svc['totalHours'] as num?)?.toStringAsFixed(1) ?? '0';
            return DataRow(
              cells: [
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _typeIcons[svc['serviceType']] ?? Icons.spa,
                        size: 16,
                        color: Colors.blueAccent,
                      ),
                      const SizedBox(width: 8),
                      Text(svc['serviceName'] ?? '—', style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                DataCell(Text(svc['total']?.toString() ?? '0')),
                DataCell(Text(svc['confirmed']?.toString() ?? '0', style: const TextStyle(color: Colors.green))),
                DataCell(Text(svc['cancelled']?.toString() ?? '0', style: const TextStyle(color: Colors.red))),
                DataCell(Text(hours)),
                DataCell(Text('${svc['revenue']?.toString() ?? '0'} ₸', style: const TextStyle(fontWeight: FontWeight.bold))),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Section title
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF6B7280), size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937)),
        ),
      ],
    );
  }

  Widget _buildEmptyServices(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.spa_outlined, size: 64, color: Color(0xFFD1D5DB)),
            const SizedBox(height: 12),
            const Text('Услуги ещё не добавлены',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937))),
            const SizedBox(height: 4),
            const Text(
                'Добавьте сауну, бильярд или другие услуги для клиентов',
                style: TextStyle(color: Color(0xFF6B7280))),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _showServiceDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Добавить первую услугу'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Booking card — same style as BookingPage
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final service = booking['service'] ?? {};
    final user = booking['user'] ?? {};
    final status = booking['status'] ?? '';
    final isPaid = (booking['remainingAmount'] ?? 1) == 0;
    final isOffline = booking['isOfflineBooking'] == true;
    final clientName = isOffline
        ? (booking['clientName'] ?? 'Оффлайн клиент')
        : (user['name'] ?? 'Пользователь');
    final clientPhone = isOffline
        ? (booking['clientPhone'] ?? '')
        : (user['phone'] ?? '');

    final displayName = clientPhone.isNotEmpty
        ? '$clientName • $clientPhone'
        : clientName;

    final startTime = DateTime.parse(booking['startTime']).toLocal();
    final endTime = DateTime.parse(booking['endTime']).toLocal();

    Color statusColor = const Color(0xFF6B7280);
    String statusLabel = status;
    if (status == 'Confirmed' || status == 'Completed') {
      statusColor = const Color(0xFF059669);
      statusLabel = status == 'Completed' ? 'Завершено' : 'Подтверждено';
    } else if (status == 'Pending') {
      statusColor = const Color(0xFFEAB308);
      statusLabel = 'Ожидает';
    } else if (status == 'Cancelled') {
      statusColor = Colors.red;
      statusLabel = 'Отменено';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          // Date/time block
          SizedBox(
            width: 120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('dd MMM', 'ru').format(startTime),
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 2),
                Text(
                  '${DateFormat('HH:mm').format(startTime)} — ${DateFormat('HH:mm').format(endTime)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF111827)),
                ),
              ],
            ),
          ),

          Container(
              width: 1,
              height: 40,
              color: const Color(0xFFE5E7EB),
              margin: const EdgeInsets.symmetric(horizontal: 20)),

          // Service + client
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _typeIcons[service['type']] ?? Icons.spa,
                      size: 16,
                      color: const Color(0xFF2563EB),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      service['name'] ?? 'Услуга',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Color(0xFF111827)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      isOffline ? Icons.person_pin : Icons.person,
                      size: 15,
                      color: const Color(0xFF9CA3AF),
                    ),
                    const SizedBox(width: 6),
                    Text(displayName,
                        style: const TextStyle(
                            color: Color(0xFF6B7280), fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),

          // Status
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
            ),
          ),

          const SizedBox(width: 20),

          // Price + payment
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${booking['totalPrice'] ?? 0} ₸',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF111827)),
              ),
              const SizedBox(height: 4),
              Text(
                isPaid
                    ? '✓ Оплачено'
                    : 'Остаток: ${booking['remainingAmount']} ₸',
                style: TextStyle(
                    fontSize: 12,
                    color: isPaid ? const Color(0xFF059669) : Colors.red),
              ),
            ],
          ),

          // Actions
          if (status != 'Cancelled' &&
              (booking['remainingAmount'] ?? 0) > 0) ...[
            const SizedBox(width: 16),
            OutlinedButton(
              onPressed: () => _cancelBooking(booking['_id']),
              style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              child: const Text('Отменить'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => _markPaid(booking['_id']),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              child: const Text('Оплачено'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyBookings() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: const Center(
        child: Column(
          children: [
            Icon(Icons.event_busy_outlined,
                size: 56, color: Color(0xFFD1D5DB)),
            SizedBox(height: 12),
            Text('Нет бронирований за этот период',
                style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B7280))),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stat Card — same card style as DashboardScreen stat cards
// ─────────────────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Service Card — horizontal row layout (photo left, info middle, actions right)
// ─────────────────────────────────────────────────────────────────────────────
class _ServiceCard extends StatefulWidget {
  final ServiceModel service;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ServiceCard({
    required this.service,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.service;
    final icon = _typeIcons[s.type] ?? Icons.star;
    final typeName = _typeNames[s.type] ?? 'Услуга';
    final formattedPrice = NumberFormat('#,###', 'ru_RU').format(s.pricePerHour).replaceAll(',', ' ');
    final isMobile = MediaQuery.of(context).size.width < 600;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hovered ? const Color(0xFFD1D5DB) : const Color(0xFFE5E7EB),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_hovered ? 0.08 : 0.03),
              blurRadius: _hovered ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Photo / Icon area (Left) ─────────────────────────────────
              Container(
                width: isMobile ? 100 : 140,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(15)),
                  color: const Color(0xFFF3F4F6),
                ),
                clipBehavior: Clip.antiAlias,
                child: s.photos.isNotEmpty
                    ? Image.network(
                        s.photos.first,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Center(child: Icon(icon, size: 40, color: const Color(0xFFD1D5DB))),
                      )
                    : Center(child: Icon(icon, size: 40, color: const Color(0xFFD1D5DB))),
              ),

              // ── Info area (Middle) ───────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        typeName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6B7280),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        s.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$formattedPrice ₸ / час',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Actions area (Right) ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: s.isActive
                            ? const Color(0xFF059669).withOpacity(0.1)
                            : const Color(0xFF6B7280).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            s.isActive ? Icons.check_circle : Icons.circle_outlined,
                            size: 14,
                            color: s.isActive ? const Color(0xFF059669) : const Color(0xFF6B7280),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            s.isActive ? 'Активно' : 'Неактивно',
                            style: TextStyle(
                              color: s.isActive ? const Color(0xFF059669) : const Color(0xFF6B7280),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Action Buttons
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        OutlinedButton.icon(
                          onPressed: widget.onEdit,
                          icon: const Icon(Icons.edit_outlined, size: 16),
                          label: const Text('Редактировать'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF2563EB),
                            side: const BorderSide(color: Color(0xFFE5E7EB)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: widget.onDelete,
                          tooltip: 'Удалить',
                          icon: const Icon(Icons.delete_outline, size: 20),
                          style: IconButton.styleFrom(
                            foregroundColor: Colors.red,
                            backgroundColor: Colors.red.withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

