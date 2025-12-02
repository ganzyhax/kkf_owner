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
  Widget _buildStatsGrid(
    Map<String, dynamic> stats,
    bool isMobile,
    bool isTablet,
  ) {
    final statCards = [
      {
        'label': 'Получено',
        'subtitle': 'Поступило на счет',
        'value': '${stats['paidAmount']} ₸',
        'color': const Color(0xFF059669),
      },
      {
        'label': 'Ожидается',
        'subtitle': 'Долги клиентов',
        'value': '${stats['pendingAmount']} ₸',
        'color': const Color(0xFFEAB308),
      },
      {
        'label': 'Оборот',
        'subtitle': 'Все бронирования',
        'value': '${stats['grossRevenue']} ₸',
        'color': const Color(0xFF2563EB),
      },
      {
        'label': 'Чистый доход',
        'subtitle': 'После комиссии',
        'value': '${stats['netRevenue']} ₸',
        'color': const Color(0xFF8B5CF6),
      },
    ];

    if (isMobile) {
      // ✅ Mobile: 2 columns grid with isMobile: true
      return Column(
        children: [
          for (var i = 0; i < statCards.length; i += 2)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: statCards[i]['label'] as String,
                      subtitle: statCards[i]['subtitle'] as String,
                      value: statCards[i]['value'] as String,
                      color: statCards[i]['color'] as Color,
                      isMobile: true, // ✅ Передаём isMobile: true
                    ),
                  ),
                  if (i + 1 < statCards.length) ...[
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        label: statCards[i + 1]['label'] as String,
                        subtitle: statCards[i + 1]['subtitle'] as String,
                        value: statCards[i + 1]['value'] as String,
                        color: statCards[i + 1]['color'] as Color,
                        isMobile: true, // ✅ Передаём isMobile: true
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      );
    } else if (isTablet) {
      // ✅ Tablet: 2x2 grid
      return Column(
        children: [
          Row(
            children: statCards.take(2).map((card) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 24, bottom: 24),
                  child: StatCard(
                    label: card['label'] as String,
                    subtitle: card['subtitle'] as String,
                    value: card['value'] as String,
                    color: card['color'] as Color,
                    // isMobile по умолчанию false для tablet
                  ),
                ),
              );
            }).toList(),
          ),
          Row(
            children: statCards.skip(2).map((card) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 24),
                  child: StatCard(
                    label: card['label'] as String,
                    subtitle: card['subtitle'] as String,
                    value: card['value'] as String,
                    color: card['color'] as Color,
                    // isMobile по умолчанию false для tablet
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      );
    } else {
      // ✅ Desktop: Single row with GridView
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 4,
        mainAxisSpacing: 24,
        crossAxisSpacing: 24,
        childAspectRatio: 2.5,
        children: statCards.map((card) {
          return StatCard(
            label: card['label'] as String,
            subtitle: card['subtitle'] as String,
            value: card['value'] as String,
            color: card['color'] as Color,
            // isMobile по умолчанию false для desktop
          );
        }).toList(),
      );
    }
  }
}
