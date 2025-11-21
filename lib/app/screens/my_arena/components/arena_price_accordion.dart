import 'package:flutter/material.dart';

class PriceAccordion extends StatefulWidget {
  final Map<String, Map<String, double?>> prices;
  final Function(Map<String, Map<String, double?>>) onChanged;

  const PriceAccordion({
    Key? key,
    required this.prices,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<PriceAccordion> createState() => _PriceAccordionState();
}

class _PriceAccordionState extends State<PriceAccordion> {
  String? _expandedDay;
  final _days = [
    'Понедельник',
    'Вторник',
    'Среда',
    'Четверг',
    'Пятница',
    'Суббота',
    'Воскресенье',
  ];
  final _hours = List.generate(24, (i) => '${i.toString().padLeft(2, '0')}:00');
  final _allPriceController = TextEditingController();
  final Map<String, Map<String, TextEditingController>> _controllers = {};

  @override
  void initState() {
    super.initState();
    // Создаем контроллеры для каждого часа каждого дня
    for (var day in _days) {
      _controllers[day] = {};
      for (var hour in _hours) {
        final controller = TextEditingController(
          text: widget.prices[day]?[hour]?.toString() ?? '',
        );
        _controllers[day]![hour] = controller;
      }
    }
  }

  @override
  void dispose() {
    _allPriceController.dispose();
    for (var dayControllers in _controllers.values) {
      for (var controller in dayControllers.values) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  void _applyToAll() {
    final price = double.tryParse(_allPriceController.text);
    if (price == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Введите корректную цену')));
      return;
    }

    setState(() {
      for (var day in _days) {
        for (var hour in _hours) {
          widget.prices[day]![hour] = price;
          _controllers[day]![hour]!.text = price.toString();
        }
      }
    });
    widget.onChanged(widget.prices);
    _allPriceController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Почасовые цены',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              SizedBox(
                width: 120,
                child: TextField(
                  controller: _allPriceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Цена ₸',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _applyToAll,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  'Применить ко всем',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Вы можете задать одну цену для всех часов или изменить цену для конкретного дня/времени',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ..._days.map((day) => _buildDay(day)),
        ],
      ),
    );
  }

  Widget _buildDay(String day) {
    final isExpanded = _expandedDay == day;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expandedDay = isExpanded ? null : day),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    day,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) _buildHours(day),
        ],
      ),
    );
  }

  Widget _buildHours(String day) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFFF9FAFB),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 2,
        ),
        itemCount: _hours.length,
        itemBuilder: (context, i) {
          final hour = _hours[i];
          final controller = _controllers[day]![hour]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hour,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '₸',
                    contentPadding: const EdgeInsets.all(8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    isDense: true,
                  ),
                  style: const TextStyle(fontSize: 12),
                  onChanged: (v) {
                    widget.prices[day]![hour] = double.tryParse(v);
                    widget.onChanged(widget.prices);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
