import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerWidget extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;

  const DatePickerWidget({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  State<DatePickerWidget> createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<DatePickerWidget> {
  late DateTime current;

  @override
  void initState() {
    super.initState();
    current = DateTime(widget.selectedDate.year, widget.selectedDate.month, 1);
  }

  void _changeMonth(int offset) {
    setState(() {
      current = DateTime(current.year, current.month + offset, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final days = DateUtils.getDaysInMonth(current.year, current.month);
    final monthLabel = DateFormat('LLLL yyyy', 'ru').format(current);
    final firstWeekday = DateTime(current.year, current.month, 1).weekday;
    final offsetDays = firstWeekday == 7 ? 6 : firstWeekday - 1;

    return Container(
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
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'Выбор Даты',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            monthLabel,
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          // Weekday headers
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 7,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.2,
            children: ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс']
                .map(
                  (day) => Center(
                    child: Text(
                      day,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 4),
          // Calendar grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: offsetDays + days,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemBuilder: (_, index) {
              if (index < offsetDays) {
                return const SizedBox.shrink();
              }

              final day = index - offsetDays + 1;
              final date = DateTime(current.year, current.month, day);

              final isSelected =
                  date.year == widget.selectedDate.year &&
                  date.month == widget.selectedDate.month &&
                  date.day == widget.selectedDate.day;

              // ✅ Проверка на сегодня
              final today = DateTime.now();
              final isToday =
                  date.year == today.year &&
                  date.month == today.month &&
                  date.day == today.day;

              return GestureDetector(
                onTap: () => widget.onDateChanged(date),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.blue
                        : isToday
                        ? Colors
                              .orange // ✅ Оранжевый для сегодня
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    border: isToday && !isSelected
                        ? Border.all(
                            color: Colors.orange,
                            width: 2,
                          ) // ✅ Обводка
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '$day',
                      style: TextStyle(
                        color: (isSelected || isToday)
                            ? Colors.white
                            : Colors.black87,
                        fontWeight: (isSelected || isToday)
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => _changeMonth(-1),
                icon: const Icon(Icons.chevron_left),
                style: IconButton.styleFrom(backgroundColor: Colors.grey[100]),
              ),
              IconButton(
                onPressed: () => _changeMonth(1),
                icon: const Icon(Icons.chevron_right),
                style: IconButton.styleFrom(backgroundColor: Colors.grey[100]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
