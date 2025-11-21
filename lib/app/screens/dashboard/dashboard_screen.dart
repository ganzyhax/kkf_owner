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
    return Container(
      height: MediaQuery.of(context).size.height,
      color: const Color(0xFFF9FAFB),
      child: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(40, 40, 40, 0),
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
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.stadium, color: Color(0xFF6B7280)),
                          const SizedBox(width: 12),
                          const Text(
                            'Выберите арену:',
                            style: TextStyle(
                              fontSize: 16,
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
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Dashboard Content
              BlocBuilder<DashboardBloc, DashboardState>(
                builder: (context, state) {
                  if (state is DashboardLoading) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(64.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (state is DashboardError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(64.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Ошибка: ${state.message}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 16),
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
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Обзор за ${state.month}',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Stats Cards
                        LayoutBuilder(
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
                              mainAxisSpacing: 24,
                              crossAxisSpacing: 24,
                              childAspectRatio: 2.5,
                              children: [
                                StatCard(
                                  label: 'Общий доход',
                                  value: '${state.stats['grossRevenue']} ₸',
                                  color: const Color(0xFF059669),
                                ),
                                StatCard(
                                  label: 'Комиссия платформы',
                                  value:
                                      '${state.stats['platformCommission']} ₸',
                                  color: const Color(0xFF2563EB),
                                ),
                                StatCard(
                                  label: 'Чистый доход',
                                  value: '${state.stats['netRevenue']} ₸',
                                  color: const Color(0xFF8B5CF6),
                                ),

                                StatCard(
                                  label: 'Всего бронирований',
                                  value: '${state.stats['totalBookings']}',
                                  color: const Color(0xFFEAB308),
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 40),

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
                              SizedBox(),
                            const SizedBox(height: 24),
                            BookingsTable(bookings: state.todayBookings),
                          ],
                        ),

                        const SizedBox(height: 40),
                        RevenueChart(
                          graphic: state.graphics,
                          previousMonthGraphic: state.previousMonthGraphics,
                        ),
                        const SizedBox(height: 40),
                      ],
                    );
                  }

                  return Container(
                    padding: const EdgeInsets.all(64),
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
}
