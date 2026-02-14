import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kff_owner_admin/app/screens/booking/components/booking_list_widget.dart';
import 'package:kff_owner_admin/app/screens/booking/components/offline_booking_dialog.dart';
import 'package:kff_owner_admin/app/screens/my_arena/bloc/my_arena_bloc.dart';
import 'package:kff_owner_admin/app/screens/booking/bloc/booking_bloc.dart';

class BookingPage extends StatelessWidget {
  const BookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => MyArenaBloc()..add(MyArenaLoad())),
        BlocProvider(create: (_) => BookingBloc()),
      ],
      child: const _BookingPageContent(),
    );
  }
}

class _BookingPageContent extends StatefulWidget {
  const _BookingPageContent();

  @override
  State<_BookingPageContent> createState() => _BookingPageContentState();
}

class _BookingPageContentState extends State<_BookingPageContent> {
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  String _activeFilter = 'today'; // 'today', 'month', 'custom'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _selectToday(); // Загрузка данных за сегодня при старте
    });
  }

  void _loadBookings() {
    // Формат YYYY-MM-DD исключает ошибки интерпретации месяца/дня на бэкенде
    final startStr = DateFormat('yyyy-MM-dd').format(_startDate);
    final endStr = DateFormat('yyyy-MM-dd').format(_endDate);

    context.read<BookingBloc>().add(
      BookingGetByPeriod(startDate: startStr, endDate: endStr),
    );
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
      _endDate = DateTime(now.year, now.month + 1, 0); // Последний день месяца
      _activeFilter = 'month';
    });
    _loadBookings();
  }

  Future<void> _selectCustomRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
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

  void _showOfflineBookingDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<BookingBloc>()),
          BlocProvider.value(value: context.read<MyArenaBloc>()),
        ],
        child: const OfflineBookingDialog(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      body: SafeArea(
        child: BlocListener<BookingBloc, BookingState>(
          listener: (context, state) {
            if (state is BookingSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
              _loadBookings(); // Рефреш данных после успеха
            }
          },
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(isMobile),
                    const SizedBox(height: 24),
                    _buildMainFilterBar(),
                    const SizedBox(height: 24),
                    const BookingsOverviewWidget(), // Теперь внутри нет своих кнопок дат
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Бронирования',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            Text(
              'Управление и статистика',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: _showOfflineBookingDialog,
          icon: const Icon(Icons.add),
          label: const Text('Создать бронь'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainFilterBar() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _filterButton('Сегодня', 'today', _selectToday),
          const SizedBox(width: 8),

          Container(width: 1, height: 24, color: Colors.grey.shade300),
          const SizedBox(width: 8),

          _filterButton('Месяц', 'month', _selectMonth),
        ],
      ),
    );
  }

  Widget _filterButton(String label, String code, VoidCallback onTap) {
    bool selected = _activeFilter == code;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: Colors.blue,
      labelStyle: TextStyle(color: selected ? Colors.white : Colors.black87),
      showCheckmark: false,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      side: BorderSide.none,
    );
  }
}
