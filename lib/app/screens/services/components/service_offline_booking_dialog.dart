import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kff_owner_admin/app/api/api.dart';
import 'package:kff_owner_admin/app/models/service_model.dart';

const _paymentMethods = [
  {'key': 'Cash', 'label': 'Наличные'},
  {'key': 'Kaspi', 'label': 'Kaspi'},
  {'key': 'Halyk', 'label': 'Halyk Pay'},
  {'key': 'Card', 'label': 'Банковская карта'},
  {'key': 'Transfer', 'label': 'Перевод'},
];

/// Диалог создания оффлайн-бронирования услуги.
///
/// Вызов:
/// ```dart
/// showDialog(
///   context: context,
///   builder: (_) => ServiceOfflineBookingDialog(services: myServices),
/// );
/// ```
class ServiceOfflineBookingDialog extends StatefulWidget {
  final List<ServiceModel> services;
  final VoidCallback? onCreated;

  const ServiceOfflineBookingDialog({
    Key? key,
    required this.services,
    this.onCreated,
  }) : super(key: key);

  @override
  State<ServiceOfflineBookingDialog> createState() =>
      _ServiceOfflineBookingDialogState();
}

class _ServiceOfflineBookingDialogState
    extends State<ServiceOfflineBookingDialog> {
  // ─── Step state ───────────────────────────────────────────────────────────
  int _step = 0; // 0=Услуга  1=Дата+Время+Длит.  2=Клиент+Оплата

  // ─── Step 1: Service ──────────────────────────────────────────────────────
  ServiceModel? _selectedService;

  // ─── Step 2: Date / Time / Duration ──────────────────────────────────────
  DateTime _selectedDate = DateTime.now();
  String? _selectedStartTime; // "HH:mm"
  int? _selectedDuration; // minutes
  List<String> _availableHours = [];
  bool _isLoadingAvailability = false;
  String? _lastResponse; // for debug

  // ─── Step 3: Client / Payment ─────────────────────────────────────────────
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String _paymentMethod = 'Cash';
  bool _isPaid = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────────
  int get _totalPrice {
    if (_selectedService == null || _selectedDuration == null) return 0;
    final hours = _selectedDuration! / 60;
    return (_selectedService!.pricePerHour * hours).round();
  }

  bool _isTimeAvailable(String hour, int durationMinutes) {
    if (_availableHours.isEmpty) return false;
    final parts = hour.split(':');
    final startTotal = int.parse(parts[0]) * 60 + int.parse(parts[1]);
    for (int i = 0; i < durationMinutes; i += 30) {
      final slot = startTotal + i;
      final h = (slot ~/ 60).toString().padLeft(2, '0');
      final m = (slot % 60).toString().padLeft(2, '0');
      if (!_availableHours.contains('$h:$m')) return false;
    }
    return true;
  }

  String _calcEndTime(String startTime, int minutes) {
    final parts = startTime.split(':');
    final totalMins =
        int.parse(parts[0]) * 60 + int.parse(parts[1]) + minutes;
    final h = (totalMins ~/ 60).toString().padLeft(2, '0');
    final m = (totalMins % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _formatDuration(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return '${m} мин';
    if (m == 0) return '${h} ч';
    return '${h} ч ${m} мин';
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Load availability
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _loadAvailability() async {
    if (_selectedService == null) return;
    setState(() {
      _isLoadingAvailability = true;
      _availableHours = [];
      _selectedStartTime = null;
    });
    try {
      final dateStr =
          DateFormat('yyyy-MM-dd').format(_selectedDate);
      final res = await ApiClient.get(
          'api/services/${_selectedService!.id}/availability/$dateStr');
      if (res['success'] == true) {
        setState(() {
          _lastResponse = res['data'].toString();
          _availableHours = List<String>.from(
              res['data']['availableSlots'] ?? []);
          _isLoadingAvailability = false;
        });
      } else {
        setState(() {
          _lastResponse = 'Error: $res';
          _isLoadingAvailability = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error response: $res')),
          );
        }
      }
    } catch (e) {
      log('Error loading availability: $e');
      setState(() => _isLoadingAvailability = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Exception: $e')),
        );
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Submit
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    if (_selectedService == null ||
        _selectedStartTime == null ||
        _selectedDuration == null) return;

    setState(() => _isSubmitting = true);

    try {
      final parts = _selectedStartTime!.split(':');
      final startTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
      final endTime =
          startTime.add(Duration(minutes: _selectedDuration!));

      final body = {
        'serviceId': _selectedService!.id,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'clientName':
            _nameCtrl.text.trim().isEmpty ? 'Клиент' : _nameCtrl.text.trim(),
        'clientPhone': _phoneCtrl.text.trim(),
        'paymentMethod': _paymentMethod,
        'isPaid': _isPaid,
        'totalPrice': _totalPrice,
      };

      final res =
          await ApiClient.post('api/service-bookings/offline', body);

      if (res['success'] == true) {
        Navigator.pop(context);
        widget.onCreated?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Бронирование создано'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['data']?['message'] ?? 'Ошибка создания'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      log('Error creating offline booking: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Ошибка: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 680),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ──────────────────────────────────────────────────
            _buildDialogHeader(),
            // ── Steps ───────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: _buildCurrentStep(),
              ),
            ),
            // ── Footer ──────────────────────────────────────────────────
            _buildDialogFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          const Icon(Icons.add_box_rounded, color: Colors.blue, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Новое оффлайн-бронирование',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              Text(
                ['Выбор услуги', 'Дата и время', 'Клиент и оплата'][_step],
                style: TextStyle(
                    color: Colors.blue.shade700, fontSize: 13),
              ),
            ],
          ),
          const Spacer(),
          // Steps indicators
          Row(
            children: List.generate(3, (i) {
              final active = i == _step;
              final done = i < _step;
              return Container(
                margin: const EdgeInsets.only(left: 6),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: done
                      ? Colors.green
                      : active
                          ? Colors.blue
                          : Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: done
                      ? const Icon(Icons.check,
                          size: 14, color: Colors.white)
                      : Text('${i + 1}',
                          style: TextStyle(
                              color: active ? Colors.white : Colors.grey,
                              fontSize: 13,
                              fontWeight: FontWeight.bold)),
                ),
              );
            }),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_step) {
      case 0:
        return _buildStep0();
      case 1:
        return _buildStep1();
      case 2:
        return _buildStep2();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDialogFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            const BorderRadius.vertical(bottom: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_step > 0)
            OutlinedButton.icon(
              onPressed: () => setState(() => _step--),
              icon: const Icon(Icons.arrow_back_ios_new, size: 14),
              label: const Text('Назад'),
              style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12)),
            ),
          const Spacer(),
          if (_step < 2)
            ElevatedButton.icon(
              onPressed: _canProceed() ? _next : null,
              icon: const Icon(Icons.arrow_forward_ios, size: 14),
              label: const Text('Далее'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
              ),
            )
          else
            ElevatedButton.icon(
              onPressed:
                  _isSubmitting || !_canProceed() ? null : _submit,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.check, size: 18),
              label:
                  Text(_isSubmitting ? 'Создание...' : 'Создать бронь'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
              ),
            ),
        ],
      ),
    );
  }

  bool _canProceed() {
    switch (_step) {
      case 0:
        return _selectedService != null;
      case 1:
        return _selectedStartTime != null && _selectedDuration != null;
      case 2:
        return true;
      default:
        return false;
    }
  }

  void _next() {
    if (_step == 0) {
      setState(() => _step = 1);
      _loadAvailability();
    } else {
      setState(() => _step++);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Step 0: Choose service
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildStep0() {
    if (widget.services.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'У вас нет созданных услуг. Сначала добавьте услугу.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 15),
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Выберите услугу',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 16),
        ...widget.services.map((s) {
          final selected = _selectedService?.id == s.id;
          return GestureDetector(
            onTap: () => setState(() => _selectedService = s),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.blue.withOpacity(0.07)
                    : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected
                      ? Colors.blue
                      : Colors.grey.shade200,
                  width: selected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.spa_outlined,
                      color:
                          selected ? Colors.blue : Colors.grey, size: 24),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.name,
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? Colors.blue
                                    : Colors.black)),
                        Text(
                          '${s.pricePerHour} ₸/час  •  мин: ${_formatDuration(s.minDuration)}',
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  if (selected)
                    const Icon(Icons.check_circle, color: Colors.blue),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Step 1: Date + Duration + Time
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildStep1() {
    // Duration options
    List<int> durations = [];
    if (_selectedService != null) {
      int cur = _selectedService!.minDuration;
      while (cur <= _selectedService!.maxDuration) {
        durations.add(cur);
        cur += _selectedService!.durationStep > 0
            ? _selectedService!.durationStep
            : 30;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date picker
        const Text('Дата',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 10),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (picked != null) {
              setState(() {
                _selectedDate = picked;
                _selectedStartTime = null;
              });
              _loadAvailability();
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border:
                  Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today,
                    color: Colors.blue, size: 18),
                const SizedBox(width: 12),
                Text(
                  DateFormat('d MMMM yyyy', 'ru')
                      .format(_selectedDate),
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Duration
        const Text('Длительность',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: durations.map((d) {
            final sel = _selectedDuration == d;
            return ChoiceChip(
              label: Text(_formatDuration(d)),
              selected: sel,
              onSelected: (_) {
                setState(() {
                  _selectedDuration = d;
                  _selectedStartTime = null;
                });
              },
              selectedColor: Colors.blue,
              labelStyle: TextStyle(
                  color: sel ? Colors.white : Colors.black87),
              showCheckmark: false,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              side: BorderSide.none,
              backgroundColor: const Color(0xFFF3F4F6),
            );
          }).toList(),
        ),

        const SizedBox(height: 20),

        // Time
        const Text('Время начала',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 10),
        if (_isLoadingAvailability)
          const Center(child: CircularProgressIndicator())
        else if (_selectedDuration == null)
          const Text('Сначала выберите длительность',
              style: TextStyle(color: Colors.grey))
        else if (_availableHours.isEmpty)
          Text('Пусто. API вернул: ${_lastResponse ?? "null"}',
              style: const TextStyle(color: Colors.red))
        else
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _availableHours.map((h) {
              final avail = _isTimeAvailable(
                  h, _selectedDuration ?? 60);
              final selected = _selectedStartTime == h;
              if (!avail) return const SizedBox.shrink();
              final end =
                  _calcEndTime(h, _selectedDuration ?? 60);
              return ChoiceChip(
                label: Text('$h–$end'),
                selected: selected,
                onSelected: avail
                    ? (_) => setState(() => _selectedStartTime = h)
                    : null,
                selectedColor: Colors.blue,
                labelStyle: TextStyle(
                    color: selected ? Colors.white : Colors.black87,
                    fontSize: 12),
                showCheckmark: false,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                side: BorderSide.none,
                backgroundColor: const Color(0xFFF3F4F6),
              );
            }).toList(),
          ),

        // Summary
        if (_selectedStartTime != null &&
            _selectedDuration != null) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle,
                    color: Colors.green, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${DateFormat('d MMMM', 'ru').format(_selectedDate)}  •  $_selectedStartTime — ${_calcEndTime(_selectedStartTime!, _selectedDuration!)}  •  $_totalPrice ₸',
                    style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Step 2: Client + Payment
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Данные клиента',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        TextField(
          controller: _nameCtrl,
          decoration: InputDecoration(
            labelText: 'Имя клиента',
            prefixIcon: const Icon(Icons.person_outline),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _phoneCtrl,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'Телефон',
            prefixIcon: const Icon(Icons.phone_outlined),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
          ),
        ),

        const SizedBox(height: 24),
        const Text('Способ оплаты',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _paymentMethods.map((m) {
            final selected = _paymentMethod == m['key'];
            return ChoiceChip(
              label: Text(m['label']!),
              selected: selected,
              onSelected: (_) =>
                  setState(() => _paymentMethod = m['key']!),
              selectedColor: Colors.blue,
              labelStyle: TextStyle(
                  color: selected ? Colors.white : Colors.black87),
              showCheckmark: false,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              side: BorderSide.none,
              backgroundColor: const Color(0xFFF3F4F6),
            );
          }).toList(),
        ),

        const SizedBox(height: 20),
        SwitchListTile(
          value: _isPaid,
          onChanged: (v) => setState(() => _isPaid = v),
          title: const Text('Уже оплачено'),
          subtitle:
              Text(_isPaid ? 'Бронь будет подтверждена' : 'Ожидает оплаты'),
          activeColor: Colors.green,
          contentPadding: EdgeInsets.zero,
        ),

        const SizedBox(height: 20),
        // Summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              _summaryRow('Услуга',
                  _selectedService?.name ?? '—'),
              _summaryRow('Дата',
                  DateFormat('d MMMM yyyy', 'ru').format(_selectedDate)),
              _summaryRow('Время',
                  '$_selectedStartTime — ${_calcEndTime(_selectedStartTime ?? '00:00', _selectedDuration ?? 0)}'),
              _summaryRow('Длительность',
                  _formatDuration(_selectedDuration ?? 0)),
              const Divider(height: 20),
              _summaryRow('Итого', '$_totalPrice ₸',
                  valueStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.blue)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String value,
      {TextStyle? valueStyle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.grey, fontSize: 14)),
          Text(value,
              style: valueStyle ??
                  const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }
}
