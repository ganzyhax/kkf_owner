// lib/screens/booking/components/time_slots_grid.dart (СОВРЕМЕННАЯ ВЕРСИЯ)

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/booking_bloc.dart';

class TimeSlotsGrid extends StatefulWidget {
  final DateTime selectedDate;
  final String arenaId;
  final Function(List<int>) onSelectionChanged;

  const TimeSlotsGrid({
    super.key,
    required this.selectedDate,
    required this.arenaId,
    required this.onSelectionChanged,
  });

  @override
  State<TimeSlotsGrid> createState() => _TimeSlotsGridState();
}

class _TimeSlotsGridState extends State<TimeSlotsGrid> {
  List<int> selected = [];
  Map<int, Map<String, dynamic>> bookedDetails = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAvailability();
    });
  }

  @override
  void didUpdateWidget(TimeSlotsGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate ||
        oldWidget.arenaId != widget.arenaId) {
      selected = [];
      bookedDetails = {};
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onSelectionChanged([]);
        _loadAvailability();
      });
    }
  }

  void _loadAvailability() {
    final dateStr = DateFormat('yyyy-MM-dd').format(widget.selectedDate);
    context.read<BookingBloc>().add(
      BookingLoadAvailability(arenaId: widget.arenaId, date: dateStr),
    );
  }

  bool _isPastTime(int hour) {
    final now = DateTime.now();
    final selectedDateTime = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
      hour,
    );
    return selectedDateTime.isBefore(now);
  }

  bool _isSlotSelectable(int hour) {
    final isPast = _isPastTime(hour);
    final isBooked = bookedDetails.containsKey(hour);
    final isCancelled =
        isBooked && bookedDetails[hour]!['status'] == 'Cancelled';

    return !isPast && (!isBooked || isCancelled);
  }

  void toggle(int hour) {
    if (!_isSlotSelectable(hour)) return;

    setState(() {
      if (selected.isEmpty) {
        selected = [hour];
      } else {
        final min = selected.first;
        final max = selected.last;
        final inRange = hour == min - 1 || hour == max + 1;

        if (inRange) {
          selected.add(hour);
          selected.sort();
        } else if (selected.contains(hour)) {
          selected.remove(hour);
        } else {
          selected = [hour];
        }
      }
    });
    widget.onSelectionChanged(selected);
  }

  Widget _buildTimeSlot(int hour, double width) {
    final isPast = _isPastTime(hour);
    final isBooked = bookedDetails.containsKey(hour);
    final isSelected = selected.contains(hour);
    final isCancelled =
        isBooked && bookedDetails[hour]!['status'] == 'Cancelled';
    final isSelectable = _isSlotSelectable(hour);

    // 🎨 СОВРЕМЕННАЯ ЦВЕТОВАЯ СХЕМА
    Color containerColor;
    Color textColor;
    Color borderColor;
    IconData? icon;
    String? statusText;

    if (isPast) {
      if (isBooked && !isCancelled) {
        containerColor = Theme.of(context).colorScheme.errorContainer;
        textColor = Theme.of(context).colorScheme.onErrorContainer;
        borderColor = Colors.transparent;
        icon = Icons.person;
      } else {
        containerColor = Theme.of(context).colorScheme.surfaceVariant;
        textColor = Theme.of(context).colorScheme.onSurfaceVariant;
        borderColor = Colors.transparent;
        icon = Icons.lock_clock;
      }
    } else {
      if (isBooked) {
        if (isCancelled) {
          containerColor = Colors.orange.withOpacity(0.1);
          textColor = Colors.orange.shade800;
          borderColor = Colors.orange.withOpacity(0.3);
          icon = Icons.cancel_outlined;
          statusText = 'ОТМЕНЕНО';
        } else {
          containerColor = Theme.of(context).colorScheme.errorContainer;
          textColor = Theme.of(context).colorScheme.onErrorContainer;
          borderColor = Colors.transparent;
          icon = Icons.person;
        }
      } else if (isSelected) {
        containerColor = Theme.of(context).colorScheme.primaryContainer;
        textColor = Theme.of(context).colorScheme.onPrimaryContainer;
        borderColor = Theme.of(context).colorScheme.primary;
        icon = Icons.check_circle;
      } else {
        containerColor = Theme.of(context).colorScheme.surface;
        textColor = Theme.of(context).colorScheme.onSurface;
        borderColor = Theme.of(context).colorScheme.outline.withOpacity(0.3);
        icon = Icons.check_circle_outline;
      }
    }

    final isCompact = width < 600;
    final isVeryCompact = width < 400;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isSelectable ? () => toggle(hour) : null,
          onLongPress: isBooked
              ? () => _showBookingDetails(bookedDetails[hour]!)
              : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isVeryCompact ? 4 : (isCompact ? 8 : 12),
              vertical: isVeryCompact ? 6 : (isCompact ? 8 : 12),
            ),
            decoration: BoxDecoration(
              color: containerColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? borderColor : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 🕒 ВРЕМЯ
                Text(
                  '${hour.toString().padLeft(2, '0')}:00',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: textColor,
                    fontSize: isVeryCompact ? 10 : (isCompact ? 12 : 14),
                  ),
                ),

                if (!isVeryCompact) SizedBox(height: isCompact ? 4 : 6),

                // 📊 СТАТУС И ИНФОРМАЦИЯ
                if (isBooked) ...[
                  // 👤 ИМЯ КЛИЕНТА
                  Text(
                    bookedDetails[hour]!['clientName'] ?? 'Гость',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w500,
                      fontSize: isVeryCompact ? 8 : (isCompact ? 10 : 12),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),

                  if (!isVeryCompact) SizedBox(height: isCompact ? 2 : 4),

                  // 📞 ТЕЛЕФОН ИЛИ СТАТУС
                  if (!isCancelled)
                    Text(
                      _formatPhone(bookedDetails[hour]!['phone'], width),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: textColor.withOpacity(0.7),
                        fontSize: isVeryCompact ? 7 : (isCompact ? 9 : 11),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  else
                    Text(
                      statusText ?? 'ОТМЕНЕНО',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: isVeryCompact ? 7 : (isCompact ? 9 : 11),
                      ),
                    ),

                  if (!isVeryCompact) SizedBox(height: isCompact ? 3 : 6),

                  // 💰 СТАТУС ОПЛАТЫ
                  if (!isCancelled)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getPaymentStatusColor(
                          bookedDetails[hour]!['paymentStatus'],
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _getPaymentText(bookedDetails[hour]!['paymentStatus']),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: _getPaymentStatusColor(
                            bookedDetails[hour]!['paymentStatus'],
                          ),
                          fontWeight: FontWeight.w500,
                          fontSize: isVeryCompact ? 6 : (isCompact ? 8 : 10),
                        ),
                      ),
                    ),
                ] else
                  Icon(
                    icon ?? Icons.check_circle_outline,
                    size: isVeryCompact ? 12 : (isCompact ? 16 : 20),
                    color: textColor,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showBookingDetails(Map<String, dynamic> details) {
    final totalPrice = details['totalPrice'] ?? 0;
    final prepaid = details['prepaidAmount'] ?? 0;
    final remaining = details['remainingAmount'] ?? 0;
    final isCancelled = details['status'] == 'Cancelled';
    final refundAmount = details['refundAmount'] ?? 0;
    final retainedAmount = details['retainedAmount'] ?? 0;

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width < 600
                ? MediaQuery.of(context).size.width *
                      0.9 // телефон
                : 600, // веб/планшет
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🎯 ЗАГОЛОВОК
                Row(
                  children: [
                    Icon(
                      isCancelled ? Icons.cancel : Icons.event_available,
                      color: isCancelled
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isCancelled
                            ? 'Отмененное бронирование'
                            : 'Детали бронирования',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isCancelled
                                  ? Theme.of(context).colorScheme.error
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      icon: const Icon(Icons.close),
                      style: IconButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // 📋 ИНФОРМАЦИЯ
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _modernDetailRow(
                          Icons.person_outline,
                          'Клиент',
                          details['clientName'] ?? 'Не указан',
                        ),
                        const SizedBox(height: 16),
                        _modernDetailRow(
                          Icons.phone_iphone,
                          'Телефон',
                          details['phone'] ?? 'Не указан',
                        ),
                        const SizedBox(height: 16),
                        _modernDetailRow(
                          Icons.email_outlined,
                          'Email',
                          details['email'] ?? 'Не указан',
                        ),
                        const SizedBox(height: 16),
                        _modernDetailRow(
                          Icons.info_outline,
                          'Статус',
                          _translateStatus(details['status']),
                          valueColor: isCancelled
                              ? Theme.of(context).colorScheme.error
                              : null,
                        ),

                        if (!isCancelled) ...[
                          const SizedBox(height: 16),
                          _modernDetailRow(
                            Icons.payment,
                            'Статус оплаты',
                            _translatePaymentStatus(details['paymentStatus']),
                            valueColor: _getPaymentStatusColor(
                              details['paymentStatus'],
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // 💰 ФИНАНСОВАЯ ИНФОРМАЦИЯ
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Финансовая информация',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 12),
                              _financeRow('Общая сумма', '$totalPrice ₸'),
                              _financeRow(
                                'Предоплата',
                                '$prepaid ₸',
                                color: Theme.of(context).colorScheme.primary,
                              ),

                              if (isCancelled) ...[
                                const SizedBox(height: 8),
                                const Divider(),
                                const SizedBox(height: 8),
                                Text(
                                  'Информация о возврате',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 8),
                                _financeRow(
                                  'Возвращено клиенту',
                                  '$refundAmount ₸',
                                  color: Colors.blue,
                                ),
                                _financeRow(
                                  'Удержано',
                                  '$retainedAmount ₸',
                                  color: Colors.orange,
                                ),
                              ] else
                                _financeRow(
                                  'Остаток к оплате',
                                  '$remaining ₸',
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                ),
                            ],
                          ),
                        ),

                        if (isCancelled && details['cancelledAt'] != null) ...[
                          const SizedBox(height: 16),
                          _modernDetailRow(
                            Icons.access_time,
                            'Дата отмены',
                            _formatDate(details['cancelledAt']),
                          ),
                        ],

                        if (isCancelled &&
                            details['cancellationReason'] != null &&
                            details['cancellationReason']
                                .toString()
                                .isNotEmpty) ...[
                          const SizedBox(height: 16),
                          _modernDetailRow(
                            Icons.comment_outlined,
                            'Причина отмены',
                            details['cancellationReason'],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 🎯 КНОПКИ ДЕЙСТВИЙ
                if (details['status'] != 'Cancelled')
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.tonalIcon(
                          onPressed: () =>
                              _showCancellationDialog(details, dialogContext),
                          icon: const Icon(Icons.cancel_outlined),
                          label: const Text('Отменить бронь'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.errorContainer,
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (details['paymentStatus'] != 'FullyPaid')
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () {
                              Navigator.pop(dialogContext);
                              context.read<BookingBloc>().add(
                                BookingMarkPaid(
                                  bookingId: details['bookingId'],
                                ),
                              );
                              Future.delayed(
                                const Duration(seconds: 1),
                                _loadAvailability,
                              );
                            },
                            icon: const Icon(Icons.check_circle),
                            label: const Text('Оплачено'),
                          ),
                        ),
                    ],
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'Бронирование отменено',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCancellationDialog(
    Map<String, dynamic> details,
    BuildContext dialogContext,
  ) {
    final prepaid = details['prepaidAmount'] ?? 0;
    final reasonController = TextEditingController();
    final refundController = TextEditingController(text: prepaid.toString());

    showDialog(
      context: dialogContext,
      builder: (confirmContext) => Dialog(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width < 600
                ? MediaQuery.of(context).size.width *
                      0.9 // телефон
                : 400, // веб/планшет
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Отмена бронирования',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),

                // 💰 ИНФОРМАЦИЯ О ПРЕДОПЛАТЕ
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Предоплата:',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '$prepaid ₸',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 🔢 СУММА ВОЗВРАТА
                Text(
                  'Сумма возврата клиенту',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: refundController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Введите сумму в ₸',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.money_outlined),
                    helperText: 'Максимум: $prepaid ₸',
                  ),
                ),

                const SizedBox(height: 12),

                // 🎯 БЫСТРЫЕ КНОПКИ
                Wrap(
                  spacing: 8,
                  children: [
                    InputChip(
                      label: const Text('0%'),
                      onSelected: (_) => refundController.text = '0',
                    ),
                    InputChip(
                      label: const Text('50%'),
                      onSelected: (_) => refundController.text = (prepaid * 0.5)
                          .toStringAsFixed(0),
                    ),
                    InputChip(
                      label: const Text('100%'),
                      onSelected: (_) =>
                          refundController.text = prepaid.toString(),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 📝 ПРИЧИНА ОТМЕНЫ
                Text(
                  'Причина отмены',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    labelText: 'Необязательно',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.comment_outlined),
                  ),
                  maxLines: 2,
                ),

                const SizedBox(height: 24),

                // 🎯 КНОПКИ ПОДТВЕРЖДЕНИЯ
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(confirmContext),
                        child: const Text('Назад'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          final refundText = refundController.text.trim();
                          final refund = double.tryParse(refundText) ?? 0;

                          if (refund < 0 || refund > prepaid) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Сумма возврата должна быть от 0 до $prepaid ₸',
                                ),
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.error,
                              ),
                            );
                            return;
                          }

                          Navigator.pop(confirmContext);
                          Navigator.pop(dialogContext);

                          final reason = reasonController.text.trim();
                          context.read<BookingBloc>().add(
                            BookingCancel(
                              bookingId: details['bookingId'],
                              refundAmount: refund,
                              cancellationReason: reason.isEmpty
                                  ? null
                                  : reason,
                            ),
                          );

                          Future.delayed(
                            const Duration(seconds: 1),
                            _loadAvailability,
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.error,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onError,
                        ),
                        child: const Text('Подтвердить отмену'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _modernDetailRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: valueColor ?? Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _financeRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: color ?? Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Color _getPaymentStatusColor(String? status) {
    switch (status) {
      case 'FullyPaid':
        return Colors.green.shade600;
      case 'PartiallyPaid':
        return Colors.orange.shade600;
      case 'Unpaid':
        return Theme.of(context).colorScheme.error;
      default:
        return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }

  int _getCrossAxisCount(double width) {
    if (width > 800) return 6;
    if (width > 600) return 5;
    if (width > 400) return 4;
    return 3;
  }

  String _formatPhone(String? phone, double width) {
    if (phone == null || phone.isEmpty || phone == 'Не указан') return '---';
    if (width > 800) return phone;

    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 4) return '••${digits.substring(digits.length - 4)}';
    return phone;
  }

  String _translateStatus(String? status) {
    switch (status) {
      case 'Pending':
        return 'Ожидание';
      case 'Confirmed':
        return 'Подтверждено';
      case 'PartiallyPaid':
        return 'Частично оплачено';
      case 'FullyPaid':
        return 'Полностью оплачено';
      case 'Cancelled':
        return 'Отменено';
      case 'Completed':
        return 'Завершено';
      default:
        return status ?? 'Неизвестно';
    }
  }

  String _translatePaymentStatus(String? status) {
    switch (status) {
      case 'FullyPaid':
        return 'Оплачено полностью';
      case 'PartiallyPaid':
        return 'Частично оплачено';
      case 'Unpaid':
        return 'Не оплачено';
      default:
        return 'Неизвестно';
    }
  }

  String _formatDate(String? isoString) {
    if (isoString == null) return '-';
    try {
      final date = DateTime.parse(isoString).toLocal();
      return DateFormat('dd MMM yyyy, HH:mm', 'ru').format(date);
    } catch (_) {
      return isoString;
    }
  }

  String _getPaymentText(String? status) {
    switch (status) {
      case 'FullyPaid':
        return 'Оплачено';
      case 'PartiallyPaid':
        return 'Частично';
      case 'Unpaid':
        return 'Не оплачено';
      default:
        return 'Неизвестно';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatted = DateFormat(
      'EEEE, d MMMM yyyy',
      'ru',
    ).format(widget.selectedDate);

    return BlocConsumer<BookingBloc, BookingState>(
      listener: (context, state) {
        if (state is BookingAvailabilityLoaded) {
          setState(() {
            bookedDetails.clear();
            for (var slot in state.bookedSlots) {
              final hourStr = slot['hour'] as String;
              final hour = int.parse(hourStr.split(':')[0]);
              bookedDetails[hour] = slot;
            }
          });
        }

        if (state is BookingSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
          _loadAvailability();
        }

        if (state is BookingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is BookingLoading;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🎯 ЗАГОЛОВОК
              Row(
                children: [
                  Text(
                    'Слоты для бронирования',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  if (isLoading)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Слоты на $dateFormatted',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),

              // 🎯 СЕТКА СЛОТОВ
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final crossAxisCount = _getCrossAxisCount(width);

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 24,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: width > 600 ? 12 : 8,
                      crossAxisSpacing: width > 600 ? 12 : 8,
                      childAspectRatio: width > 600 ? 0.9 : 0.85,
                    ),
                    itemBuilder: (_, hour) => _buildTimeSlot(hour, width),
                  );
                },
              ),

              const SizedBox(height: 24),

              // 🎯 ЛЕГЕНДА
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;

                  return Wrap(
                    spacing: isMobile ? 12 : 20,
                    runSpacing: 8,
                    children: [
                      _modernLegend(
                        Theme.of(context).colorScheme.surface,
                        Icons.check_circle_outline,
                        'Свободно',
                        isMobile,
                      ),
                      _modernLegend(
                        Theme.of(context).colorScheme.errorContainer,
                        Icons.person,
                        isMobile ? 'Занято' : 'Занято',
                        isMobile,
                      ),
                      _modernLegend(
                        Colors.orange.withOpacity(0.1),
                        Icons.cancel_outlined,
                        'Отменено',
                        isMobile,
                      ),
                      _modernLegend(
                        Theme.of(context).colorScheme.primaryContainer,
                        Icons.touch_app,
                        'Выбрано',
                        isMobile,
                      ),
                      _modernLegend(
                        Theme.of(context).colorScheme.surfaceVariant,
                        Icons.lock_clock,
                        'Прошло',
                        isMobile,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _modernLegend(Color color, IconData icon, String text, bool isMobile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: isMobile ? 14 : 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
