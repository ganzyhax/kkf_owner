// lib/screens/owner/dashboard/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kff_owner_admin/app/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:kff_owner_admin/app/screens/dashboard/components/comission_card.dart';
import 'package:kff_owner_admin/app/screens/dashboard/components/dashboard_booking_table.dart';
import 'package:kff_owner_admin/app/screens/dashboard/components/dashboard_date_picker.dart';
import 'package:kff_owner_admin/app/screens/dashboard/components/dashboard_stat_card.dart';
import 'package:kff_owner_admin/app/screens/dashboard/components/graphic_revenue.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DashboardBloc()..add(DashboardLoadAll()),
      child: const _DashboardScreenContent(),
    );
  }
}

class _DashboardScreenContent extends StatefulWidget {
  const _DashboardScreenContent();

  @override
  State<_DashboardScreenContent> createState() =>
      _DashboardScreenContentState();
}

class _DashboardScreenContentState extends State<_DashboardScreenContent> {
  String? selectedArenaId = 'all';
  String selectedArenaName = 'Все арены';
  DateTime _selectedDate = DateTime.now();

  void _handleDateChanged(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
    });

    if (selectedArenaId != null && selectedArenaId != 'all') {
      context.read<DashboardBloc>().add(
        DashboardLoadForDate(selectedDate: newDate, arenaId: selectedArenaId),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Определяем размер экрана один раз
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    final isDesktop = screenWidth >= 1024;

    // Responsive padding
    final horizontalPadding = isMobile ? 16.0 : (isTablet ? 24.0 : 40.0);
    final verticalPadding = isMobile ? 20.0 : 40.0;

    return Container(
      height: MediaQuery.of(context).size.height,
      color: const Color(0xFFF9FAFB),
      child: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            verticalPadding,
            horizontalPadding,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Arena Selector
              BlocListener<DashboardBloc, DashboardState>(
                listener: (context, state) {
                  if (state is DashbooardSuccessMarkAsPaid) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Бронирование отмечено как оплачено'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                  if (state is DashboardSuccessCancelBooking) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Бронирование отменено'),
                        backgroundColor: Colors.orange,
                        duration: Duration(seconds: 4),
                      ),
                    );
                  }
                },
                child: BlocBuilder<DashboardBloc, DashboardState>(
                  builder: (context, dashState) {
                    List<Map<String, dynamic>> arenas = [];

                    if (dashState is DashboardLoaded) {
                      arenas = dashState.arenas;
                    } else if (dashState is DashboardError) {
                      arenas = dashState.arenas;
                    }

                    if (arenas.isEmpty) {
                      return const SizedBox();
                    }

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
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.stadium,
                                      color: Color(0xFF6B7280),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Выберите арену:',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                DropdownButtonFormField<String>(
                                  value: selectedArenaId,
                                  hint: const Text('Все арены'),
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                  ),
                                  items: [
                                    const DropdownMenuItem<String>(
                                      value: 'all',
                                      child: Row(
                                        children: [
                                          Icon(Icons.dashboard, size: 18),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Все арены',
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
                                      value: null,
                                      child: Divider(),
                                    ),
                                    ...arenas.map((arena) {
                                      return DropdownMenuItem<String>(
                                        value: arena['_id'],
                                        child: Text(
                                          arena['name'] ?? 'Арена',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      if (value == 'all') {
                                        selectedArenaId = 'all';
                                        selectedArenaName = 'Все арены';
                                        _selectedDate = DateTime.now();
                                        context.read<DashboardBloc>().add(
                                          DashboardLoadAll(),
                                        );
                                      } else if (value != null) {
                                        final arena = arenas.firstWhere(
                                          (a) => a['_id'] == value,
                                        );
                                        selectedArenaId = value;
                                        selectedArenaName = arena['name'] ?? '';
                                        context.read<DashboardBloc>().add(
                                          DashboardLoadForDate(
                                            selectedDate: _selectedDate,
                                            arenaId: value,
                                          ),
                                        );
                                      }
                                    });
                                  },
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Icon(
                                  Icons.stadium,
                                  color: const Color(0xFF6B7280),
                                  size: isTablet ? 20 : 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Выберите арену:',
                                  style: TextStyle(
                                    fontSize: isTablet ? 15 : 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: DropdownButton<String>(
                                    value: selectedArenaId,
                                    hint: const Text('Все арены'),
                                    isExpanded: true,
                                    underline: const SizedBox(),
                                    items: [
                                      const DropdownMenuItem<String>(
                                        value: 'all',
                                        child: Row(
                                          children: [
                                            Icon(Icons.dashboard, size: 20),
                                            SizedBox(width: 8),
                                            Text(
                                              'Все арены (общая статистика)',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const DropdownMenuItem<String>(
                                        value: null,
                                        child: Divider(),
                                      ),
                                      ...arenas.map((arena) {
                                        return DropdownMenuItem<String>(
                                          value: arena['_id'],
                                          child: Text(arena['name'] ?? 'Арена'),
                                        );
                                      }).toList(),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        if (value == 'all') {
                                          selectedArenaId = 'all';
                                          selectedArenaName = 'Все арены';
                                          _selectedDate = DateTime.now();
                                          context.read<DashboardBloc>().add(
                                            DashboardLoadAll(),
                                          );
                                        } else if (value != null) {
                                          final arena = arenas.firstWhere(
                                            (a) => a['_id'] == value,
                                          );
                                          selectedArenaId = value;
                                          selectedArenaName =
                                              arena['name'] ?? '';
                                          context.read<DashboardBloc>().add(
                                            DashboardLoadForDate(
                                              selectedDate: _selectedDate,
                                              arenaId: value,
                                            ),
                                          );
                                        }
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                    );
                  },
                ),
              ),

              SizedBox(height: isMobile ? 20 : 24),

              // Dashboard Content
              BlocBuilder<DashboardBloc, DashboardState>(
                builder: (context, state) {
                  if (state is DashboardLoading) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(isMobile ? 48.0 : 64.0),
                        child: const CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (state is DashboardError) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(isMobile ? 32.0 : 64.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: isMobile ? 48 : 64,
                              color: Colors.red,
                            ),
                            SizedBox(height: isMobile ? 12 : 16),
                            Text(
                              'Ошибка: ${state.message}',
                              style: TextStyle(fontSize: isMobile ? 14 : 16),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: isMobile ? 12 : 16),
                            ElevatedButton(
                              onPressed: () {
                                if (selectedArenaId == 'all') {
                                  context.read<DashboardBloc>().add(
                                    DashboardLoadAll(),
                                  );
                                } else if (selectedArenaId != null) {
                                  context.read<DashboardBloc>().add(
                                    DashboardLoadForDate(
                                      selectedDate: _selectedDate,
                                      arenaId: selectedArenaId,
                                    ),
                                  );
                                }
                              },
                              child: const Text('Повторить'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (state is DashboardLoaded) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.date,
                          style: TextStyle(
                            color: const Color(0xFF6B7280),
                            fontSize: isMobile ? 13 : 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Обзор за ${state.month}',
                          style: TextStyle(
                            fontSize: isMobile ? 24 : (isTablet ? 30 : 36),
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        SizedBox(height: isMobile ? 20 : 32),

                        // ✅ Stats Cards - Responsive Grid с isMobile
                        _buildStatsGrid(state.stats, isMobile, isTablet),

                        SizedBox(height: isMobile ? 24 : 40),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (selectedArenaId != null &&
                                selectedArenaId != 'all')
                              DashboardHeaderWithDatePicker(
                                selectedDate: _selectedDate,
                                onDateChanged: _handleDateChanged,
                              )
                            else
                              const SizedBox(),
                            SizedBox(height: isMobile ? 16 : 24),
                            BookingsTable(bookings: state.todayBookings),
                          ],
                        ),

                        SizedBox(height: isMobile ? 24 : 40),
                        RevenueChart(
                          graphic: state.graphics,
                          previousMonthGraphic: state.previousMonthGraphics,
                        ),
                        SizedBox(height: isMobile ? 24 : 40),
                      ],
                    );
                  }

                  return Container(
                    padding: EdgeInsets.all(isMobile ? 48 : 64),
                    child: const Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text(
                            'Загрузка данных...',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Метод для создания адаптивной сетки статистики
  // lib/screens/owner/dashboard/dashboard_screen.dart

  Widget _buildStatsGrid(
    Map<String, dynamic> stats,
    bool isMobile,
    bool isTablet,
  ) {
    // Подготавливаем данные: берем общемесячные и сегодняшние показатели
    // Сегодняшние показатели нужно будет пробросить из бэкенда в stats.today
    final statCards = [
      {
        'label': 'Получено',
        'monthValue': '${stats['paidAmount']} ₸',
        'todayValue': '${stats['todayPaidAmount'] ?? 0} ₸',
        'icon': Icons.account_balance_wallet_rounded,
        'color': const Color(0xFF059669),
      },
      {
        'label': 'Ожидается',
        'monthValue': '${stats['pendingAmount']} ₸',
        'todayValue': '${stats['todayPendingAmount'] ?? 0} ₸',
        'icon': Icons.hourglass_empty_rounded,
        'color': const Color(0xFFEAB308),
      },
      {
        'label': 'Оборот',
        'monthValue': '${stats['grossRevenue']} ₸',
        'todayValue': '${stats['todayGrossRevenue'] ?? 0} ₸',
        'icon': Icons.analytics_rounded,
        'color': const Color(0xFF2563EB),
      },
      {
        'label': 'Чистый доход',
        'monthValue': '${stats['netRevenue']} ₸',
        'todayValue': '${stats['todayNetRevenue'] ?? 0} ₸',
        'icon': Icons.savings_rounded,
        'color': const Color(0xFF8B5CF6),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 2 : (isTablet ? 2 : 4),
        crossAxisSpacing: isMobile ? 12 : 20,
        mainAxisSpacing: isMobile ? 12 : 20,
        childAspectRatio: isMobile
            ? 1.1
            : 1.4, // Делаем карточки чуть выше для двух строк
      ),
      itemCount: statCards.length,
      itemBuilder: (context, index) {
        final card = statCards[index];
        return Container(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: const Color(0xFFF3F4F6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    card['icon'] as IconData,
                    color: card['color'] as Color,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    card['label'] as String,
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 14,
                      color: const Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card['monthValue'] as String,
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 20,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  Text(
                    'за месяц',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (card['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Сегодня: ',
                      style: TextStyle(
                        fontSize: 10,
                        color: card['color'] as Color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      card['todayValue'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        color: card['color'] as Color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
