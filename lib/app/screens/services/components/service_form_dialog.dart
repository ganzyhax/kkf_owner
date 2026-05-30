import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kff_owner_admin/app/api/api.dart';
import 'package:kff_owner_admin/app/models/service_model.dart';
import 'package:kff_owner_admin/app/screens/my_arena/components/arena_photo_uploader.dart';
import 'package:kff_owner_admin/app/screens/my_arena/components/arena_price_accordion.dart';
import 'package:kff_owner_admin/app/screens/services/bloc/service_bloc.dart';
import 'package:kff_owner_admin/app/screens/services/bloc/service_event.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Service Form Dialog — clean redesign matching booking_page / dashboard style
// ─────────────────────────────────────────────────────────────────────────────
class ServiceFormDialog extends StatefulWidget {
  final ServiceModel? service;
  const ServiceFormDialog({Key? key, this.service}) : super(key: key);

  @override
  State<ServiceFormDialog> createState() => _ServiceFormDialogState();
}

class _ServiceFormDialogState extends State<ServiceFormDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;

  String _selectedType = 'sauna';
  bool _isActive = true;
  String? _selectedArenaId;
  List<dynamic> _myArenas = [];
  bool _isLoadingArenas = true;

  List<String> _photos = [];
  Map<String, Map<String, double?>> _prices = {};

  final Map<String, Map<String, dynamic>> _schedule = {
    'Понедельник': {'isOpen': true, 'open': '09:00', 'close': '23:00'},
    'Вторник': {'isOpen': true, 'open': '09:00', 'close': '23:00'},
    'Среда': {'isOpen': true, 'open': '09:00', 'close': '23:00'},
    'Четверг': {'isOpen': true, 'open': '09:00', 'close': '23:00'},
    'Пятница': {'isOpen': true, 'open': '09:00', 'close': '23:00'},
    'Суббота': {'isOpen': true, 'open': '10:00', 'close': '23:00'},
    'Воскресенье': {'isOpen': true, 'open': '10:00', 'close': '23:00'},
  };

  final List<String> _types = [
    'sauna',
    'billiard',
    'hookah',
    'tennis_table',
    'gym',
    'pool',
    'karaoke',
    'other'
  ];

  final Map<String, String> _typeNames = {
    'sauna': 'Сауна',
    'billiard': 'Бильярд',
    'hookah': 'Кальян',
    'tennis_table': 'Настольный теннис',
    'gym': 'Тренажёрный зал',
    'pool': 'Бассейн',
    'karaoke': 'Караоке',
    'other': 'Другое',
  };

  final _days = [
    'Понедельник',
    'Вторник',
    'Среда',
    'Четверг',
    'Пятница',
    'Суббота',
    'Воскресенье',
  ];

  // Track currently expanded section
  int _expandedSection = 0; // 0=basic, 1=schedule, 2=photos, 3=prices

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.service?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.service?.description ?? '');
    _priceController = TextEditingController(
        text: widget.service?.pricePerHour.toString() ?? '');

    for (var day in _days) {
      _prices[day] = {};
    }

    if (widget.service != null) {
      _selectedType = widget.service!.type;
      _isActive = widget.service!.isActive;
      _selectedArenaId = widget.service!.arenaId;
      _photos = List.from(widget.service!.photos);

      if (widget.service!.schedule.isNotEmpty) {
        widget.service!.schedule.forEach((key, value) {
          if (_schedule.containsKey(key)) {
            _schedule[key] = Map<String, dynamic>.from(value);
          }
        });
      }
      if (widget.service!.prices.isNotEmpty) {
        widget.service!.prices.forEach((day, hoursMap) {
          if (_prices.containsKey(day) && hoursMap is Map) {
            hoursMap.forEach((hour, price) {
              _prices[day]![hour] = (price as num).toDouble();
            });
          }
        });
      }
    }

    _fetchArenas();
  }

  Future<void> _fetchArenas() async {
    try {
      final res = await ApiClient.get('api/arenas/owner/my');
      if (res['success'] == true) {
        setState(() {
          _myArenas = res['data']['arenas'] ?? [];
          if (_myArenas.isNotEmpty && _selectedArenaId == null) {
            _selectedArenaId = _myArenas.first['_id'];
          }
          _isLoadingArenas = false;
        });
      }
    } catch (e) {
      log('Error loading arenas: $e');
      setState(() => _isLoadingArenas = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedArenaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Выберите арену'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final data = {
      'arenaId': _selectedArenaId,
      'name': _nameController.text.trim(),
      'description': _descriptionController.text.trim(),
      'type': _selectedType,
      'photos': _photos,
      'pricePerHour': int.tryParse(_priceController.text) ?? 0,
      'prices': _prices,
      'isActive': _isActive,
      'schedule': _schedule,
    };

    if (widget.service == null) {
      context.read<ServiceBloc>().add(CreateService(data));
    } else {
      context
          .read<ServiceBloc>()
          .add(UpdateService(widget.service!.id, data));
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.service != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        width: 900,
        constraints: const BoxConstraints(maxHeight: 820),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            children: [
              // ── Header ──────────────────────────────────────────────────
              _buildHeader(isEditing),

              // ── Body ────────────────────────────────────────────────────
              Expanded(
                child: _isLoadingArenas
                    ? const Center(child: CircularProgressIndicator())
                    : Form(
                        key: _formKey,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Section 0: Основная информация
                              _SectionCard(
                                title: 'Основная информация',
                                icon: Icons.info_outline,
                                index: 0,
                                expanded: _expandedSection == 0,
                                onTap: () => setState(() =>
                                    _expandedSection =
                                        _expandedSection == 0 ? -1 : 0),
                                child: _buildBasicInfo(isEditing),
                              ),
                              const SizedBox(height: 12),

                              // Section 1: Расписание
                              _SectionCard(
                                title: 'Расписание работы',
                                icon: Icons.access_time,
                                index: 1,
                                expanded: _expandedSection == 1,
                                onTap: () => setState(() =>
                                    _expandedSection =
                                        _expandedSection == 1 ? -1 : 1),
                                child: _buildSchedule(),
                              ),
                              const SizedBox(height: 12),

                              // Section 2: Фотографии
                              _SectionCard(
                                title: 'Фотографии',
                                icon: Icons.photo_library_outlined,
                                index: 2,
                                expanded: _expandedSection == 2,
                                onTap: () => setState(() =>
                                    _expandedSection =
                                        _expandedSection == 2 ? -1 : 2),
                                child: PhotoUploader(
                                  initialUrls: _photos,
                                  onUploaded: (urls) =>
                                      setState(() => _photos = urls),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Section 3: Ценообразование
                              _SectionCard(
                                title: 'Динамические цены',
                                icon: Icons.price_change_outlined,
                                index: 3,
                                expanded: _expandedSection == 3,
                                onTap: () => setState(() =>
                                    _expandedSection =
                                        _expandedSection == 3 ? -1 : 3),
                                child: PriceAccordion(
                                  prices: _prices,
                                  onChanged: (newPrices) =>
                                      setState(() => _prices = newPrices),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),

              // ── Footer ──────────────────────────────────────────────────
              _buildFooter(isEditing),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────
  Widget _buildHeader(bool isEditing) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.spa, color: Color(0xFF2563EB), size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? 'Редактировать услугу' : 'Добавить услугу',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827)),
              ),
              Text(
                isEditing
                    ? 'Изменение параметров услуги'
                    : 'Заполните информацию о новой услуге',
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF6B7280)),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Color(0xFF6B7280)),
            tooltip: 'Закрыть',
          ),
        ],
      ),
    );
  }

  // ── Footer ──────────────────────────────────────────────────────────────
  Widget _buildFooter(bool isEditing) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      decoration: const BoxDecoration(
        color: Color(0xFFF9FAFB),
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF6B7280),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Отмена'),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: _submit,
            icon: Icon(isEditing ? Icons.save_outlined : Icons.add, size: 18),
            label: Text(isEditing ? 'Сохранить изменения' : 'Создать услугу'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  // ── Basic info section content ───────────────────────────────────────────
  Widget _buildBasicInfo(bool isEditing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Arena + Type in a row
        Row(
          children: [
            // Arena dropdown
            Expanded(
              child: _buildLabel(
                'Арена',
                DropdownButtonFormField<String>(
                  value: _selectedArenaId,
                  decoration: _inputDecoration('Выберите арену'),
                  items: _myArenas
                      .map((a) => DropdownMenuItem<String>(
                            value: a['_id'],
                            child: Text(a['name'] ?? ''),
                          ))
                      .toList(),
                  onChanged: isEditing
                      ? null
                      : (val) => setState(() => _selectedArenaId = val),
                  validator: (v) =>
                      v == null ? 'Обязательное поле' : null,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Type dropdown
            Expanded(
              child: _buildLabel(
                'Тип услуги',
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: _inputDecoration('Тип'),
                  items: _types
                      .map((t) => DropdownMenuItem<String>(
                            value: t,
                            child: Text(_typeNames[t]!),
                          ))
                      .toList(),
                  onChanged: (val) =>
                      setState(() => _selectedType = val!),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Name
        _buildLabel(
          'Название услуги',
          TextFormField(
            controller: _nameController,
            decoration: _inputDecoration('Например: Сауна "Премиум"'),
            validator: (v) =>
                v == null || v.isEmpty ? 'Обязательное поле' : null,
          ),
        ),
        const SizedBox(height: 16),

        // Price
        _buildLabel(
          'Базовая цена за час (₸)',
          TextFormField(
            controller: _priceController,
            decoration: _inputDecoration('Например: 5000'),
            keyboardType: TextInputType.number,
            validator: (v) =>
                v == null || v.isEmpty ? 'Обязательное поле' : null,
          ),
        ),
        const SizedBox(height: 16),

        // Description
        _buildLabel(
          'Описание (опционально)',
          TextFormField(
            controller: _descriptionController,
            decoration: _inputDecoration(
                'Краткое описание услуги для клиентов...'),
            maxLines: 3,
          ),
        ),
        const SizedBox(height: 16),

        // Active toggle
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              const Icon(Icons.power_settings_new,
                  color: Color(0xFF6B7280), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Статус услуги',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                          fontSize: 14),
                    ),
                    Text(
                      _isActive
                          ? 'Услуга видна клиентам и доступна для бронирования'
                          : 'Услуга скрыта от клиентов',
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _isActive,
                onChanged: (val) => setState(() => _isActive = val),
                activeColor: const Color(0xFF059669),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Schedule section content ─────────────────────────────────────────────
  Widget _buildSchedule() {
    return Column(
      children: _days.map((day) => _buildScheduleRow(day)).toList(),
    );
  }

  Widget _buildScheduleRow(String day) {
    final dayData = _schedule[day]!;
    final isOpen = dayData['isOpen'] as bool;
    // Short day name
    final shortDay = day.length > 2 ? day.substring(0, 2) : day;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isOpen ? Colors.white : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isOpen
              ? const Color(0xFFE5E7EB)
              : const Color(0xFFF3F4F6),
        ),
      ),
      child: Row(
        children: [
          // Day abbreviation circle
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isOpen
                  ? const Color(0xFF2563EB).withOpacity(0.1)
                  : const Color(0xFFF3F4F6),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                shortDay.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isOpen
                      ? const Color(0xFF2563EB)
                      : const Color(0xFF9CA3AF),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Full day name
          SizedBox(
            width: 110,
            child: Text(
              day,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: isOpen
                    ? const Color(0xFF111827)
                    : const Color(0xFF9CA3AF),
              ),
            ),
          ),

          // Time fields
          if (isOpen) ...[
            Expanded(
              child: TextFormField(
                initialValue: dayData['open'],
                decoration: InputDecoration(
                  labelText: 'Открытие',
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                ),
                onChanged: (v) => _schedule[day]!['open'] = v,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text('—',
                  style: TextStyle(color: Colors.grey.shade400)),
            ),
            Expanded(
              child: TextFormField(
                initialValue: dayData['close'],
                decoration: InputDecoration(
                  labelText: 'Закрытие',
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                ),
                onChanged: (v) => _schedule[day]!['close'] = v,
              ),
            ),
          ] else
            Expanded(
              child: Text(
                'Выходной',
                style: TextStyle(
                    color: Colors.grey.shade400, fontSize: 13),
              ),
            ),

          const SizedBox(width: 12),

          // Toggle open/closed
          Switch(
            value: isOpen,
            onChanged: (val) =>
                setState(() => _schedule[day]!['isOpen'] = val),
            activeColor: const Color(0xFF059669),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────
  Widget _buildLabel(String label, Widget field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 6),
        field,
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFD1D5DB)),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide:
            const BorderSide(color: Color(0xFF2563EB), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Collapsible Section Card
// ─────────────────────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final int index;
  final bool expanded;
  final VoidCallback onTap;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.index,
    required this.expanded,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: expanded
              ? const Color(0xFF2563EB).withOpacity(0.3)
              : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header row
          InkWell(
            onTap: onTap,
            borderRadius: expanded
                ? const BorderRadius.vertical(top: Radius.circular(12))
                : BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: expanded
                          ? const Color(0xFF2563EB).withOpacity(0.1)
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      size: 16,
                      color: expanded
                          ? const Color(0xFF2563EB)
                          : const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: expanded
                          ? const Color(0xFF111827)
                          : const Color(0xFF374151),
                    ),
                  ),
                  const Spacer(),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Collapsible content
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: expanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  const Divider(height: 1, color: Color(0xFFE5E7EB)),
                  const SizedBox(height: 16),
                  child,
                ],
              ),
            ),
            secondChild: const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}
