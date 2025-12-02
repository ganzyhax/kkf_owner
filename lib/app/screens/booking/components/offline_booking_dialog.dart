import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kff_owner_admin/app/screens/booking/bloc/booking_bloc.dart';
import 'package:kff_owner_admin/app/screens/my_arena/bloc/my_arena_bloc.dart';
import 'package:kff_owner_admin/app/screens/booking/components/arena_selector.dart';
import 'package:kff_owner_admin/app/screens/booking/components/date_picker.dart';
import 'package:kff_owner_admin/app/screens/booking/components/time_slots_grid.dart';

class OfflineBookingDialog extends StatefulWidget {
  const OfflineBookingDialog({super.key});

  @override
  State<OfflineBookingDialog> createState() => _OfflineBookingDialogState();
}

class _OfflineBookingDialogState extends State<OfflineBookingDialog> {
  final _formKey = GlobalKey<FormState>();
  final _clientNameController = TextEditingController();
  final _clientPhoneController = TextEditingController();
  final _prepaidAmountController = TextEditingController();

  List<int> selectedHours = [];
  DateTime selectedDate = DateTime.now();
  String? selectedArenaId;
  Map<String, dynamic>? selectedArena;
  bool isFullyPaid = false;
  double totalPrice = 0;
  Map<int, double> hourlyPrices = {};

  void onSlotSelected(List<int> newSelection) {
    setState(() {
      selectedHours = newSelection;
      _calculateTotalPrice();
    });
  }

  void onDateChanged(DateTime newDate) {
    setState(() {
      selectedDate = newDate;
      selectedHours = [];
      totalPrice = 0;
      hourlyPrices = {};
    });
  }

  void onArenaChanged(String? arenaId) {
    setState(() {
      selectedArenaId = arenaId;
      selectedHours = [];
      totalPrice = 0;
      hourlyPrices = {};

      if (arenaId != null) {
        final arenaState = context.read<MyArenaBloc>().state;
        if (arenaState is MyArenaLoaded) {
          try {
            selectedArena = arenaState.arenas.firstWhere(
              (arena) => arena['_id'] == arenaId,
            );
          } catch (e) {
            selectedArena = null;
          }
        }
      } else {
        selectedArena = null;
      }
    });
  }

  void _calculateTotalPrice() {
    hourlyPrices = {};

    if (selectedArena == null || selectedHours.isEmpty) {
      totalPrice = 0;
      return;
    }

    final prices = selectedArena!['prices'] as Map<String, dynamic>?;
    if (prices == null) {
      totalPrice = 0;
      return;
    }

    final dayNames = [
      'Воскресенье',
      'Понедельник',
      'Вторник',
      'Среда',
      'Четверг',
      'Пятница',
      'Суббота',
    ];
    final dayName = dayNames[selectedDate.weekday % 7];
    final dayPrices = prices[dayName] as Map<String, dynamic>?;

    if (dayPrices == null) {
      totalPrice = 0;
      return;
    }

    double sum = 0;
    for (final hour in selectedHours) {
      final hourKey = '${hour.toString().padLeft(2, '0')}:00';
      final price = dayPrices[hourKey];
      if (price != null) {
        final priceValue = (price is int)
            ? price.toDouble()
            : (price as double);
        hourlyPrices[hour] = priceValue;
        sum += priceValue;
      }
    }

    setState(() {
      totalPrice = sum;
      if (isFullyPaid) {
        _prepaidAmountController.text = totalPrice.toInt().toString();
      }
    });
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    _clientPhoneController.dispose();
    _prepaidAmountController.dispose();
    super.dispose();
  }

  void _createBooking() {
    if (_formKey.currentState!.validate()) {
      if (selectedArenaId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Выберите арену'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (selectedHours.length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Выберите минимум 2 часа'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (totalPrice <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ошибка расчета цены'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final startHour = selectedHours.first;
      final endHour = selectedHours.last + 1;

      final startTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        startHour,
      );

      final endTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        endHour,
      );

      final prepaidAmount = double.tryParse(_prepaidAmountController.text) ?? 0;

      context.read<BookingBloc>().add(
        BookingCreateOffline(
          arenaId: selectedArenaId!,
          startTime: startTime,
          endTime: endTime,
          clientName: _clientNameController.text,
          clientPhone: _clientPhoneController.text,
          totalPrice: totalPrice,
          prepaidAmount: prepaidAmount,
          isFullyPaid: isFullyPaid,
        ),
      );

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Бронирование создается...'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final canBook = selectedHours.length >= 2 && selectedArenaId != null;
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // Responsive breakpoints
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    final isDesktop = screenWidth >= 1024;

    // Responsive sizing
    final dialogWidth = isMobile
        ? screenWidth * 0.95
        : (isTablet ? screenWidth * 0.9 : 1200.0);
    final dialogHeight = isMobile ? screenHeight * 0.95 : screenHeight * 0.85;
    final padding = isMobile ? 16.0 : (isTablet ? 20.0 : 24.0);
    final iconSize = isMobile ? 24.0 : 28.0;
    final titleFontSize = isMobile ? 18.0 : 22.0;
    final subtitleFontSize = isMobile ? 12.0 : 14.0;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: dialogWidth,
        height: dialogHeight,
        margin: EdgeInsets.symmetric(vertical: isMobile ? 0 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.all(padding),
              child: isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.event_available,
                                color: Colors.blue,
                                size: iconSize,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.of(context).pop(),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Создать оффлайн бронь',
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Выберите арену, дату и время',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: subtitleFontSize,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.event_available,
                            color: Colors.blue,
                            size: iconSize,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Создать оффлайн бронь',
                                style: TextStyle(
                                  fontSize: titleFontSize,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Выберите арену, дату и время. Цена рассчитается автоматически.',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: subtitleFontSize,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: const Divider(),
            ),

            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(padding),
                child: isMobile
                    ? _buildMobileLayout(canBook, padding)
                    : _buildDesktopLayout(canBook, padding, isTablet),
              ),
            ),

            // Bottom buttons
            Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                children: [
                  const Divider(),
                  SizedBox(height: isMobile ? 12 : 16),
                  isMobile
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ElevatedButton.icon(
                              onPressed: canBook ? _createBooking : null,
                              icon: const Icon(Icons.check, size: 20),
                              label: const Text('Создать бронь'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: Colors.grey,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Отмена'),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Отмена'),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: canBook ? _createBooking : null,
                              icon: const Icon(Icons.check),
                              label: const Text('Создать бронь'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: Colors.grey,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
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
    );
  }

  Widget _buildMobileLayout(bool canBook, double padding) {
    return Column(
      children: [
        ArenaSelector(onArenaChanged: onArenaChanged),
        const SizedBox(height: 16),
        DatePickerWidget(
          selectedDate: selectedDate,
          onDateChanged: onDateChanged,
        ),
        const SizedBox(height: 16),

        // Time slots
        if (selectedArenaId != null)
          TimeSlotsGrid(
            selectedDate: selectedDate,
            arenaId: selectedArenaId!,
            onSelectionChanged: onSlotSelected,
          )
        else
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'Выберите арену',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ),

        if (selectedHours.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildPriceSummary(true),
        ],

        if (canBook) ...[const SizedBox(height: 16), _buildClientForm(true)],
      ],
    );
  }

  Widget _buildDesktopLayout(bool canBook, double padding, bool isTablet) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left side: Arena and Date
        Expanded(
          flex: isTablet ? 1 : 1,
          child: Column(
            children: [
              ArenaSelector(onArenaChanged: onArenaChanged),
              const SizedBox(height: 24),
              DatePickerWidget(
                selectedDate: selectedDate,
                onDateChanged: onDateChanged,
              ),
            ],
          ),
        ),

        const SizedBox(width: 24),

        // Right side: Time slots and form
        Expanded(
          flex: isTablet ? 1 : 2,
          child: Column(
            children: [
              // Time slots
              if (selectedArenaId != null)
                TimeSlotsGrid(
                  selectedDate: selectedDate,
                  arenaId: selectedArenaId!,
                  onSelectionChanged: onSlotSelected,
                )
              else
                Container(
                  padding: const EdgeInsets.all(48),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'Выберите арену',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ),
                ),

              if (selectedHours.isNotEmpty) ...[
                const SizedBox(height: 24),
                _buildPriceSummary(false),
              ],

              if (canBook) ...[
                const SizedBox(height: 24),
                _buildClientForm(false),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSummary(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: selectedHours.length >= 2
            ? Colors.green.shade50
            : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selectedHours.length >= 2
              ? Colors.green.shade200
              : Colors.orange.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                selectedHours.length >= 2 ? Icons.check_circle : Icons.warning,
                color: selectedHours.length >= 2 ? Colors.green : Colors.orange,
                size: isMobile ? 20 : 24,
              ),
              SizedBox(width: isMobile ? 8 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Выбрано: ${selectedHours.length} час${selectedHours.length > 1 ? 'ов' : ''}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 14 : 16,
                      ),
                    ),
                    if (selectedHours.length < 2)
                      Text(
                        'Минимум 2 часа',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: isMobile ? 11 : 12,
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                '${totalPrice.toInt()} ₸',
                style: TextStyle(
                  fontSize: isMobile ? 20 : 24,
                  fontWeight: FontWeight.bold,
                  color: selectedHours.length >= 2
                      ? Colors.green
                      : Colors.orange,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 10 : 12),
          const Divider(),
          SizedBox(height: isMobile ? 6 : 8),

          // Hourly price breakdown
          ...selectedHours.map((hour) {
            final price = hourlyPrices[hour] ?? 0;
            return Padding(
              padding: EdgeInsets.symmetric(vertical: isMobile ? 3 : 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$hour:00 - ${hour + 1}:00',
                    style: TextStyle(fontSize: isMobile ? 13 : 14),
                  ),
                  Text(
                    '${price.toInt()} ₸',
                    style: TextStyle(
                      fontSize: isMobile ? 13 : 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildClientForm(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Данные клиента',
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: isMobile ? 12 : 16),

            // Client name
            TextFormField(
              controller: _clientNameController,
              decoration: InputDecoration(
                labelText: 'Имя клиента',
                labelStyle: TextStyle(fontSize: isMobile ? 13 : 14),
                prefixIcon: Icon(Icons.person, size: isMobile ? 20 : 24),
                border: const OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: isMobile ? 12 : 16,
                ),
              ),
              style: TextStyle(fontSize: isMobile ? 14 : 16),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Введите имя клиента';
                }
                return null;
              },
            ),

            SizedBox(height: isMobile ? 12 : 16),

            // Phone
            TextFormField(
              controller: _clientPhoneController,
              decoration: InputDecoration(
                labelText: 'Телефон клиента',
                labelStyle: TextStyle(fontSize: isMobile ? 13 : 14),
                prefixIcon: Icon(Icons.phone, size: isMobile ? 20 : 24),
                border: const OutlineInputBorder(),
                hintText: '+7 (XXX) XXX-XX-XX',
                hintStyle: TextStyle(fontSize: isMobile ? 13 : 14),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: isMobile ? 12 : 16,
                ),
              ),
              style: TextStyle(fontSize: isMobile ? 14 : 16),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Введите телефон';
                }
                return null;
              },
            ),

            SizedBox(height: isMobile ? 12 : 16),

            // Prepaid amount
            TextFormField(
              controller: _prepaidAmountController,
              decoration: InputDecoration(
                labelText: 'Предоплата (₸)',
                labelStyle: TextStyle(fontSize: isMobile ? 13 : 14),
                prefixIcon: Icon(Icons.payment, size: isMobile ? 20 : 24),
                border: const OutlineInputBorder(),
                hintText: '0',
                hintStyle: TextStyle(fontSize: isMobile ? 13 : 14),
                helperText: 'Общая цена: ${totalPrice.toInt()} ₸',
                helperStyle: TextStyle(fontSize: isMobile ? 11 : 12),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: isMobile ? 12 : 16,
                ),
              ),
              style: TextStyle(fontSize: isMobile ? 14 : 16),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              enabled: !isFullyPaid,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final prepaid = double.tryParse(value);
                  if (prepaid != null && prepaid > totalPrice) {
                    return 'Предоплата не может быть больше ${totalPrice.toInt()} ₸';
                  }
                }
                return null;
              },
            ),

            SizedBox(height: isMobile ? 12 : 16),

            // Fully paid checkbox
            CheckboxListTile(
              value: isFullyPaid,
              onChanged: (value) {
                setState(() {
                  isFullyPaid = value ?? false;
                  if (isFullyPaid) {
                    _prepaidAmountController.text = totalPrice
                        .toInt()
                        .toString();
                  } else {
                    _prepaidAmountController.text = '0';
                  }
                });
              },
              title: Text(
                'Полностью оплачено',
                style: TextStyle(fontSize: isMobile ? 14 : 16),
              ),
              subtitle: Text(
                'Предоплата = ${totalPrice.toInt()} ₸',
                style: TextStyle(fontSize: isMobile ? 12 : 14),
              ),
              controlAffinity: ListTileControlAffinity.leading,
              tileColor: Colors.grey.shade50,
              contentPadding: EdgeInsets.symmetric(
                horizontal: isMobile ? 8 : 12,
                vertical: isMobile ? 4 : 8,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
