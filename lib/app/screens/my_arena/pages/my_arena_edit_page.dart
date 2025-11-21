import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kff_owner_admin/app/screens/my_arena/bloc/my_arena_bloc.dart';
import 'package:kff_owner_admin/app/screens/my_arena/components/arena_photo_uploader.dart';
import 'package:kff_owner_admin/app/screens/my_arena/components/arena_price_accordion.dart';

class ArenaEditPage extends StatefulWidget {
  final String? arenaId;
  final Map<String, dynamic>? existingArena;

  const ArenaEditPage({Key? key, this.arenaId, this.existingArena})
    : super(key: key);

  @override
  State<ArenaEditPage> createState() => _ArenaEditPageState();
}

class _ArenaEditPageState extends State<ArenaEditPage> {
  final _formKey = GlobalKey<FormState>();

  // Контроллеры
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _descriptionController;
  late TextEditingController _gisLinkController;
  late TextEditingController _lengthController;
  late TextEditingController _widthController;
  late TextEditingController _heightController;
  late TextEditingController _playersCountController;

  // Покрытие и крытая
  String _selectedGrassType = 'поли';
  bool _isCovered = false;

  // РАСШИРЕННЫЕ УДОБСТВА
  bool _hasShower = false;
  bool _hasLockerRoom = false;
  bool _hasStands = false;
  bool _hasLighting = false;
  bool _hasFreeParking = false;

  // Фото (до 10 штук!)
  List<String> _photoUrls = [];

  // Цены
  Map<String, Map<String, double?>> _prices = {};

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializePrices();
    _loadExistingData();
  }

  void _initializeControllers() {
    _nameController = TextEditingController();
    _addressController = TextEditingController();
    _descriptionController = TextEditingController();
    _gisLinkController = TextEditingController();
    _lengthController = TextEditingController();
    _widthController = TextEditingController();
    _heightController = TextEditingController();
    _playersCountController = TextEditingController();
  }

  void _initializePrices() {
    final days = [
      'Понедельник',
      'Вторник',
      'Среда',
      'Четверг',
      'Пятница',
      'Суббота',
      'Воскресенье',
    ];
    final hours = List.generate(
      24,
      (i) => '${i.toString().padLeft(2, '0')}:00',
    );

    for (var day in days) {
      _prices[day] = {};
      for (var hour in hours) {
        _prices[day]![hour] = null;
      }
    }
  }

  void _loadExistingData() {
    if (widget.existingArena != null) {
      final arena = widget.existingArena!;
      _selectedCity = arena['city'] ?? 'Астана';
      _nameController.text = arena['name'] ?? '';
      _addressController.text = arena['address'] ?? '';
      _descriptionController.text = arena['description'] ?? '';
      _gisLinkController.text = arena['gisLink'] ?? '';

      _lengthController.text = arena['length']?.toString() ?? '';
      _widthController.text = arena['width']?.toString() ?? '';
      _heightController.text = arena['height']?.toString() ?? '';
      _playersCountController.text = arena['playersCount']?.toString() ?? '';
      _selectedGrassType = arena['typeGrass'] ?? 'поли';
      _isCovered = arena['isCovered'] ?? false;

      final amenities = arena['amenities'] as Map<String, dynamic>?;
      if (amenities != null) {
        _hasShower = amenities['hasShower'] ?? false;
        _hasLockerRoom = amenities['hasLockerRoom'] ?? false;
        _hasStands = amenities['hasStands'] ?? false;
        _hasLighting = amenities['hasLighting'] ?? false;
        _hasFreeParking = amenities['hasFreeParking'] ?? false;
      }

      _photoUrls = List<String>.from(arena['photos'] ?? []);

      if (arena['prices'] != null) {
        final pricesData = arena['prices'] as Map<String, dynamic>;
        pricesData.forEach((day, hours) {
          if (hours is Map) {
            _prices[day] = {};
            (hours as Map<String, dynamic>).forEach((hour, price) {
              _prices[day]![hour] = price?.toDouble();
            });
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _gisLinkController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _playersCountController.dispose();
    super.dispose();
  }

  void _saveArena() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Собираем ВСЕ удобства
    final List<String> amenityIds = [];
    if (_hasShower) amenityIds.add('shower');
    if (_hasLockerRoom) amenityIds.add('lockerRoom');
    if (_hasStands) amenityIds.add('stands');
    if (_hasLighting) amenityIds.add('lighting');
    if (_hasFreeParking) amenityIds.add('freeParking');

    if (widget.arenaId == null) {
      context.read<MyArenaBloc>().add(
        MyArenaCreate(
          name: _nameController.text.trim(),
          city: _selectedCity,
          address: _addressController.text.trim(),
          description: _descriptionController.text.trim(),
          gisLink: _gisLinkController.text.trim().isEmpty
              ? null
              : _gisLinkController.text.trim(),
          length: double.tryParse(_lengthController.text),
          width: double.tryParse(_widthController.text),
          height: double.tryParse(_heightController.text),
          playersCount: int.tryParse(_playersCountController.text),
          typeGrass: _selectedGrassType,
          isCovered: _isCovered,
          amenityIds: amenityIds,
          photoUrls: _photoUrls,
          prices: _prices,
        ),
      );
    } else {
      context.read<MyArenaBloc>().add(
        MyArenaUpdate(
          arenaId: widget.arenaId!,
          name: _nameController.text.trim(),
          city: _selectedCity,
          address: _addressController.text.trim(),
          description: _descriptionController.text.trim(),
          gisLink: _gisLinkController.text.trim().isEmpty
              ? null
              : _gisLinkController.text.trim(),
          length: double.tryParse(_lengthController.text),
          width: double.tryParse(_widthController.text),
          height: double.tryParse(_heightController.text),
          playersCount: int.tryParse(_playersCountController.text),
          typeGrass: _selectedGrassType,
          isCovered: _isCovered,
          amenityIds: amenityIds,
          photoUrls: _photoUrls,
          prices: _prices,
        ),
      );
    }
  }

  var cities = [
    'Алматы',
    'Астана',
    'Шымкент',
    'Караганда',
    'Актобе',
    'Тараз',
    'Павлодар',
    'Усть-Каменогорск',
    'Семей',
    'Атырау',
    'Костанай',
    'Кызылорда',
    'Уральск',
    'Петропавловsk',
    'Актау',
    'Кокшетау',
    'Туркестан',
    'Талдыкорган',
    'Экибастуз',
    'Рудный',
  ];
  var _selectedCity = 'Астана';
  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          widget.arenaId == null ? '⚽ Новая арена' : '✏️ Редактировать',
          style: const TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<MyArenaBloc, MyArenaState>(
        listener: (context, state) {
          if (state is MyArenaSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          } else if (state is MyArenaError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 20 : 10,
              vertical: 24,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 900 : double.infinity,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ========================================
                  // ОСНОВНАЯ ИНФОРМАЦИЯ
                  // ========================================
                  _buildSection(
                    title: '📝 Основная информация',
                    children: [
                      // 1. НАЗВАНИЕ
                      _buildTextField(
                        controller: _nameController,
                        label: 'Название арены *',
                        hint: 'Например: Арена Чемпион',
                        icon: Icons.stadium,
                        validator: (val) =>
                            val?.isEmpty ?? true ? 'Введите название' : null,
                      ),
                      const SizedBox(height: 32),

                      // 2. ФОТОГРАФИИ (СРАЗУ ПОСЛЕ НАЗВАНИЯ!)
                      PhotoUploader(
                        initialUrls: _photoUrls,
                        onUploaded: (urls) {
                          setState(() => _photoUrls = urls);
                        },
                      ),
                      const SizedBox(height: 32),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: _selectedCity,
                          decoration: InputDecoration(
                            labelText: 'Город *',
                            hintText: 'Выберите город',
                            prefixIcon: Icon(
                              Icons.location_city,
                              color: Colors.green[700],
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                          ),
                          isExpanded: true,
                          items: cities.map((String city) {
                            return DropdownMenuItem<String>(
                              value: city,
                              child: Text(city),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedCity = newValue!;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Выберите город';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 32),

                      // 3. АДРЕС
                      _buildTextField(
                        controller: _addressController,
                        label: 'Адрес *',
                        hint: 'г. Алматы, ул. Абая 1',
                        icon: Icons.location_on,
                        validator: (val) =>
                            val?.isEmpty ?? true ? 'Введите адрес' : null,
                      ),
                      const SizedBox(height: 20),

                      // 4. ОПИСАНИЕ
                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Описание',
                        hint: 'Опишите вашу арену...',
                        icon: Icons.description,
                        maxLines: 4,
                      ),
                      const SizedBox(height: 20),

                      // 5. 2GIS ССЫЛКА
                      _buildTextField(
                        controller: _gisLinkController,
                        label: 'Ссылка на 2GIS',
                        hint: 'https://2gis.kz/...',
                        icon: Icons.map,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // ========================================
                  // ПАРАМЕТРЫ ПОЛЯ
                  // ========================================
                  _buildSection(
                    title: '📐 Параметры поля',
                    children: [
                      // 1. КРЫТАЯ/ОТКРЫТАЯ (ПЕРВОЕ!)
                      _buildCoveredSwitch(),
                      const SizedBox(height: 24),

                      // 2. ПОКРЫТИЕ (ВТОРОЕ!)
                      _buildGrassTypeSelector(),
                      const SizedBox(height: 24),

                      // 3. РАЗМЕРЫ
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _lengthController,
                              label: 'Длина (м)',
                              hint: '105',
                              icon: Icons.straighten,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _widthController,
                              label: 'Ширина (м)',
                              hint: '68',
                              icon: Icons.straighten,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _heightController,
                              label: 'Высота (м)',
                              hint: '10',
                              icon: Icons.height,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _playersCountController,
                              label: 'Макс. игроков',
                              hint: '22',
                              icon: Icons.people,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // ========================================
                  // УДОБСТВА
                  // ========================================
                  _buildSection(
                    title: '✨ Удобства',
                    children: [
                      _buildAmenityTile(
                        icon: Icons.shower,
                        title: 'Душ',
                        value: _hasShower,
                        onChanged: (val) => setState(() => _hasShower = val!),
                      ),
                      const Divider(height: 1),
                      _buildAmenityTile(
                        icon: Icons.door_front_door,
                        title: 'Раздевалки',
                        value: _hasLockerRoom,
                        onChanged: (val) =>
                            setState(() => _hasLockerRoom = val!),
                      ),
                      const Divider(height: 1),
                      _buildAmenityTile(
                        icon: Icons.event_seat,
                        title: 'Трибуны',
                        subtitle: '20 мест',
                        value: _hasStands,
                        onChanged: (val) => setState(() => _hasStands = val!),
                      ),
                      const Divider(height: 1),
                      _buildAmenityTile(
                        icon: Icons.lightbulb,
                        title: 'Освещение',
                        value: _hasLighting,
                        onChanged: (val) => setState(() => _hasLighting = val!),
                      ),
                      const Divider(height: 1),
                      _buildAmenityTile(
                        icon: Icons.local_parking,
                        title: 'Парковка',
                        subtitle: 'Бесплатная',
                        value: _hasFreeParking,
                        onChanged: (val) =>
                            setState(() => _hasFreeParking = val!),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // ========================================
                  // ЦЕНЫ
                  // ========================================
                  PriceAccordion(
                    prices: _prices,
                    onChanged: (prices) {
                      setState(() => _prices = prices);
                    },
                  ),
                  const SizedBox(height: 40),

                  // ========================================
                  // КНОПКА СОХРАНИТЬ
                  // ========================================
                  _buildSaveButton(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ВСПОМОГАТЕЛЬНЫЕ ВИДЖЕТЫ
  // ============================================================

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFF6B7280), size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
            ),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGrassTypeSelector() {
    final grassTypes = [
      {'value': 'поли', 'label': '🟢 Поли', 'emoji': '🟢'},
      {'value': 'натуральный', 'label': '🌿 Натуральный', 'emoji': '🌿'},
      {'value': 'бетон', 'label': '⬜ Бетон', 'emoji': '⬜'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Покрытие',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: grassTypes.map((type) {
            final isSelected = _selectedGrassType == type['value'];
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(
                  () => _selectedGrassType = type['value'] as String,
                ),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF2563EB)
                        : const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF2563EB)
                          : const Color(0xFFE5E7EB),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        type['emoji'] as String,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        (type['label'] as String).split(' ')[1],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF374151),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCoveredSwitch() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _isCovered
                  ? const Color(0xFF2563EB).withOpacity(0.1)
                  : const Color(0xFFE5E7EB).withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _isCovered ? Icons.roofing : Icons.wb_sunny,
              color: _isCovered
                  ? const Color(0xFF2563EB)
                  : const Color(0xFF6B7280),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Крытая арена',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isCovered ? 'Крытая' : 'Открытая',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isCovered,
            onChanged: (val) => setState(() => _isCovered = val),
            activeColor: const Color(0xFF2563EB),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenityTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required void Function(bool?) onChanged,
  }) {
    return CheckboxListTile(
      value: value,
      onChanged: onChanged,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1F2937),
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            )
          : null,
      secondary: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: value
              ? const Color(0xFF2563EB).withOpacity(0.1)
              : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: value ? const Color(0xFF2563EB) : const Color(0xFF9CA3AF),
          size: 22,
        ),
      ),
      activeColor: const Color(0xFF2563EB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _saveArena,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Text(
          widget.arenaId == null ? '✅ Создать арену' : '💾 Сохранить изменения',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
