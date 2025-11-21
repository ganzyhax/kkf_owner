import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kff_owner_admin/app/screens/my_arena/bloc/my_arena_bloc.dart';
import 'package:kff_owner_admin/app/screens/booking/bloc/booking_bloc.dart';
import 'package:kff_owner_admin/app/screens/booking/components/arena_selector.dart';
import 'package:kff_owner_admin/app/screens/booking/components/date_picker.dart';
import 'package:kff_owner_admin/app/screens/booking/components/offline_booking_form.dart';
import 'package:kff_owner_admin/app/screens/booking/components/time_slots_grid.dart';

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
  List<int> selectedHours = [];
  DateTime selectedDate = DateTime.now();
  String? selectedArenaId;

  void onSlotSelected(List<int> newSelection) {
    setState(() => selectedHours = newSelection);
  }

  void onDateChanged(DateTime newDate) {
    setState(() {
      selectedDate = newDate;
      selectedHours = [];
    });
  }

  void onArenaChanged(String? arenaId) {
    setState(() {
      selectedArenaId = arenaId;
      selectedHours = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final canBook = selectedHours.length >= 2 && selectedArenaId != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Управление Бронированиями (Календарь)',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Выберите арену, дату и минимум 2 часа подряд для оффлайн бронирования.',
                      style: TextStyle(color: Colors.black54, fontSize: 15),
                    ),
                    const SizedBox(height: 24),

                    BlocBuilder<MyArenaBloc, MyArenaState>(
                      builder: (context, arenaState) {
                        Map<String, dynamic>? selectedArena;
                        if (arenaState is MyArenaLoaded &&
                            selectedArenaId != null) {
                          try {
                            selectedArena = arenaState.arenas.firstWhere(
                              (arena) => arena['_id'] == selectedArenaId,
                            );
                          } catch (e) {
                            print('Arena not found: $e');
                          }
                        }

                        return LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.maxWidth > 900;
                            return isWide
                                ? Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Column(
                                          children: [
                                            ArenaSelector(
                                              onArenaChanged: onArenaChanged,
                                            ),
                                            const SizedBox(height: 24),
                                            DatePickerWidget(
                                              selectedDate: selectedDate,
                                              onDateChanged: onDateChanged,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 24),
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          children: [
                                            if (selectedArenaId != null)
                                              TimeSlotsGrid(
                                                selectedDate: selectedDate,
                                                arenaId: selectedArenaId!,
                                                onSelectionChanged:
                                                    onSlotSelected,
                                              )
                                            else
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  48,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: const Center(
                                                  child: Text(
                                                    'Выберите арену',
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            const SizedBox(height: 24),
                                            if (selectedArenaId != null)
                                              OfflineBookingForm(
                                                canBook: canBook,
                                                arenaId: selectedArenaId!,
                                                selectedDate: selectedDate,
                                                selectedHours: selectedHours,
                                                arena: selectedArena,
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      ArenaSelector(
                                        onArenaChanged: onArenaChanged,
                                      ),
                                      const SizedBox(height: 24),
                                      DatePickerWidget(
                                        selectedDate: selectedDate,
                                        onDateChanged: onDateChanged,
                                      ),
                                      const SizedBox(height: 24),
                                      if (selectedArenaId != null) ...[
                                        TimeSlotsGrid(
                                          selectedDate: selectedDate,
                                          arenaId: selectedArenaId!,
                                          onSelectionChanged: onSlotSelected,
                                        ),
                                        const SizedBox(height: 24),
                                        OfflineBookingForm(
                                          canBook: canBook,
                                          arenaId: selectedArenaId!,
                                          selectedDate: selectedDate,
                                          selectedHours: selectedHours,
                                          arena: selectedArena,
                                        ),
                                      ] else
                                        Container(
                                          padding: const EdgeInsets.all(48),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: const Center(
                                            child: Text('Выберите арену'),
                                          ),
                                        ),
                                    ],
                                  );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
