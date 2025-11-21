import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/booking_bloc.dart';

class OfflineBookingForm extends StatefulWidget {
  final bool canBook;
  final String arenaId;
  final DateTime selectedDate;
  final List<int> selectedHours;
  final Map<String, dynamic>? arena;

  const OfflineBookingForm({
    super.key,
    required this.canBook,
    required this.arenaId,
    required this.selectedDate,
    required this.selectedHours,
    this.arena,
  });

  @override
  State<OfflineBookingForm> createState() => _OfflineBookingFormState();
}

class _OfflineBookingFormState extends State<OfflineBookingForm> {
  final _clientNameC = TextEditingController();
  final _clientPhoneC = TextEditingController();
  final _prepaidC = TextEditingController();
  String _paymentType = 'partial';

  void _createBooking() async {
    if (widget.selectedHours.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Выберите минимум 2 часа подряд'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final name = _clientNameC.text.trim();
    final phone = _clientPhoneC.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Заполните все обязательные поля'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final priceInfo = _calculatePriceData();
    final totalPrice = priceInfo['total']!;

    double prepaidAmount = 0;
    if (_paymentType == 'partial') {
      prepaidAmount = double.tryParse(_prepaidC.text) ?? 0;
      if (prepaidAmount <= 0 || prepaidAmount > totalPrice) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Некорректная сумма предоплаты'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    } else {
      prepaidAmount = totalPrice;
    }

    final startHour = widget.selectedHours.first;
    final endHour = widget.selectedHours.last + 1;

    final startTime = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
      startHour,
    );

    final endTime = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
      endHour,
    );

    print('📤 Создаем бронирование:');
    print('  Arena ID: ${widget.arenaId}');
    print('  Start: $startTime');
    print('  End: $endTime');
    print('  Client: $name');
    print('  Phone: $phone');
    print('  Total: $totalPrice');
    print('  Prepaid: $prepaidAmount');
    print('  Fully paid: ${_paymentType == 'full'}');

    context.read<BookingBloc>().add(
      BookingCreateOffline(
        arenaId: widget.arenaId,
        startTime: startTime,
        endTime: endTime,
        clientName: name,
        clientPhone: phone,
        totalPrice: totalPrice,
        prepaidAmount: prepaidAmount,
        isFullyPaid: _paymentType == 'full',
      ),
    );
  }

  // ✅ Получить детальную информацию о ценах для каждого часа
  Map<int, double> _getHourPrices() {
    if (widget.selectedHours.isEmpty || widget.arena == null) {
      return {};
    }

    try {
      final arena = widget.arena!;
      dynamic prices = arena['prices'];

      if (prices is String) {
        try {
          prices = jsonDecode(prices);
        } catch (e) {
          return {};
        }
      }

      if (prices == null || prices is! Map) return {};

      final daysOfWeek = [
        'Понедельник',
        'Вторник',
        'Среда',
        'Четверг',
        'Пятница',
        'Суббота',
        'Воскресенье',
      ];

      final weekday = widget.selectedDate.weekday;
      final dayName = daysOfWeek[weekday - 1];
      dynamic dayPrices = prices[dayName];

      if (dayPrices == null || dayPrices is! Map) return {};

      Map<int, double> hourPriceMap = {};

      for (int hour in widget.selectedHours) {
        final formats = [
          '$hour:00',
          '${hour.toString().padLeft(2, '0')}:00',
          hour.toString(),
          hour.toString().padLeft(2, '0'),
        ];

        dynamic foundPrice;

        for (String format in formats) {
          if (dayPrices.containsKey(format)) {
            foundPrice = dayPrices[format];
            break;
          }
        }

        if (foundPrice == null) continue;

        double price = 0;
        if (foundPrice is int) {
          price = foundPrice.toDouble();
        } else if (foundPrice is double) {
          price = foundPrice;
        } else if (foundPrice is String) {
          price = double.tryParse(foundPrice) ?? 0;
        }

        if (price > 0) {
          hourPriceMap[hour] = price;
        }
      }

      return hourPriceMap;
    } catch (e) {
      return {};
    }
  }

  // ✅ Вычисление общей информации о ценах
  Map<String, double> _calculatePriceData() {
    final hourPriceMap = _getHourPrices();

    if (hourPriceMap.isEmpty) {
      return {'total': 0, 'perHour': 0, 'minPrice': 0};
    }

    final hourPrices = hourPriceMap.values.toList();
    final total = hourPrices.reduce((a, b) => a + b);
    final avgPrice = total / hourPrices.length;
    final minPrice = hourPrices.reduce((a, b) => a < b ? a : b);

    print('\n💰 ===============================');
    print('💰 ФИНАЛЬНЫЙ РАСЧЕТ:');
    print('💰 Выбрано часов: ${widget.selectedHours.length}');
    print('💰 Часы и цены: $hourPriceMap');
    print('💰 ИТОГО: $total₸');
    print('💰 Минимальная цена: $minPrice₸');
    print('💰 ===============================\n');

    return {'total': total, 'perHour': avgPrice, 'minPrice': minPrice};
  }

  @override
  Widget build(BuildContext context) {
    final priceData = _calculatePriceData();
    final hourPriceMap = _getHourPrices();

    final totalPrice = priceData['total']!;
    final perHourPrice = priceData['perHour']!;
    final minPrice = priceData['minPrice']!;

    // ✅ Проверяем все ли цены одинаковые
    final uniquePrices = hourPriceMap.values.toSet();
    final allSamePrice = uniquePrices.length == 1;

    // ✅ Если выбрано минимум 2 часа и предоплата пустая - ставим минимальную цену
    if (_paymentType == 'partial' &&
        widget.selectedHours.length >= 2 &&
        minPrice > 0 &&
        _prepaidC.text.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _prepaidC.text = minPrice.toStringAsFixed(0);
        }
      });
    }

    // ✅ Если выбран только 1 час - очищаем поле предоплаты
    if (widget.selectedHours.length == 1 && _prepaidC.text.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _prepaidC.clear();
        }
      });
    }

    final prepaidAmount = double.tryParse(_prepaidC.text) ?? 0;
    final remainingAmount = totalPrice - prepaidAmount;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: BlocListener<BookingBloc, BookingState>(
        listener: (context, state) {
          if (state is BookingSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            _clientNameC.clear();
            _clientPhoneC.clear();
            _prepaidC.clear();
            setState(() => _paymentType = 'partial');
          } else if (state is BookingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Оффлайн Бронирование',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),

            // ✅ ПОКАЗЫВАЕМ ЦЕНЫ
            if (widget.selectedHours.isNotEmpty && totalPrice > 0)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.withOpacity(0.05),
                      Colors.indigo.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    // ✅ Показываем количество часов
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Выбрано часов:',
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                        Text(
                          '${widget.selectedHours.length}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),

                    // ✅ Если все цены одинаковые - показываем "Цена за час"
                    if (allSamePrice) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Цена за час:',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            '${perHourPrice.toStringAsFixed(0)} ₸',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),
                        ],
                      ),
                    ]
                    // ✅ Если цены разные - показываем детали по каждому часу
                    else ...[
                      const Text(
                        'Цены по часам:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...hourPriceMap.entries.map((entry) {
                        final hour = entry.key;
                        final price = entry.value;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${hour.toString().padLeft(2, '0')}:00 - ${(hour + 1).toString().padLeft(2, '0')}:00',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                              ),
                              Text(
                                '${price.toStringAsFixed(0)} ₸',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.indigo,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],

                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),

                    // ✅ ИТОГО
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'ИТОГО:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '${totalPrice.toStringAsFixed(0)} ₸',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            if (widget.selectedHours.isNotEmpty && totalPrice == 0)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Не удалось рассчитать стоимость. Проверьте цены для выбранного дня.',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),

            if (widget.selectedHours.isNotEmpty) const SizedBox(height: 16),

            TextField(
              controller: _clientNameC,
              decoration: InputDecoration(
                labelText: 'Имя Клиента *',
                hintText: 'Иван Иванов',
                prefixIcon: const Icon(Icons.person),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _clientPhoneC,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Телефон *',
                hintText: '+7 777 123 45 67',
                prefixIcon: const Icon(Icons.phone),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'Тип оплаты:',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Предоплата'),
                    value: 'partial',
                    groupValue: _paymentType,
                    onChanged: (v) {
                      setState(() {
                        _paymentType = v!;
                        if (minPrice > 0 && widget.selectedHours.length >= 2) {
                          _prepaidC.text = minPrice.toStringAsFixed(0);
                        }
                      });
                    },
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Полная оплата'),
                    value: 'full',
                    groupValue: _paymentType,
                    onChanged: (v) => setState(() => _paymentType = v!),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ✅ Поле предоплаты только если partial И выбрано >= 2 часов
            if (_paymentType == 'partial' && widget.selectedHours.length >= 2)
              TextField(
                controller: _prepaidC,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Сумма предоплаты (₸)',
                  hintText: '${minPrice.toStringAsFixed(0)}',
                  prefixIcon: const Icon(Icons.attach_money),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

            if (totalPrice > 0 &&
                _paymentType == 'partial' &&
                widget.selectedHours.length >= 2)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: remainingAmount > 0
                        ? Colors.orange.withOpacity(0.1)
                        : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: remainingAmount > 0
                          ? Colors.orange.withOpacity(0.3)
                          : Colors.green.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Остаток к оплате:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${remainingAmount > 0 ? remainingAmount.toStringAsFixed(0) : 0} ₸',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: remainingAmount > 0
                              ? Colors.orange[700]
                              : Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: widget.canBook && totalPrice > 0
                    ? _createBooking
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.canBook && totalPrice > 0
                      ? Colors.indigo
                      : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: const Text(
                  'Забронировать Оффлайн',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
