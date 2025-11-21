// lib/screens/owner/components/arena_table.dart
import 'package:flutter/material.dart';
import 'arena_status_badge.dart';

class ArenaTable extends StatelessWidget {
  final List<Map<String, dynamic>> arenas; // ← БЕЗ МОДЕЛЕЙ!
  final Function(Map<String, dynamic>) onEdit;
  final Function(Map<String, dynamic>) onDelete;

  const ArenaTable({
    Key? key,
    required this.arenas,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    final isTablet = MediaQuery.of(context).size.width >= 640;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Список ваших объектов',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 24),
          if (arenas.isEmpty)
            _buildEmptyState()
          else if (isTablet)
            _buildDesktopTable(isDesktop, isTablet)
          else
            _buildMobileCards(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          children: [
            Icon(
              Icons.sports_soccer_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'У вас пока нет арен',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Добавьте свою первую арену',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopTable(bool isDesktop, bool isTablet) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
        headingTextStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF6B7280),
          letterSpacing: 0.5,
        ),
        dataRowHeight: 72,
        columns: [
          const DataColumn(label: Text('НАЗВАНИЕ')),
          if (isTablet) const DataColumn(label: Text('АДРЕС')),
          if (isDesktop)
            const DataColumn(label: Text('СЛЕДУЮЩЕЕ БРОНИРОВАНИЕ')),
          if (isTablet) const DataColumn(label: Text('СТАТУС')),
          const DataColumn(label: Text('ДЕЙСТВИЯ')),
        ],
        rows: arenas
            .map((arena) => _buildDataRow(arena, isDesktop, isTablet))
            .toList(),
      ),
    );
  }

  DataRow _buildDataRow(
    Map<String, dynamic> arena,
    bool isDesktop,
    bool isTablet,
  ) {
    return DataRow(
      cells: [
        DataCell(
          Text(
            arena['name'] ?? '',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
        ),
        if (isTablet)
          DataCell(
            Text(
              arena['address'] ?? '',
              style: const TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
        if (isDesktop)
          DataCell(
            Text(
              arena['nextBooking'] ?? 'Нет бронирований',
              style: const TextStyle(
                color: Color(0xFF3B82F6),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        if (isTablet)
          DataCell(ArenaStatusBadge(status: arena['status'] ?? 'inactive')),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () => onEdit(arena),
                icon: const Icon(Icons.edit, size: 16),
                label: const Text(
                  'Редактировать',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  elevation: 2,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => onDelete(arena),
                icon: const Icon(Icons.delete),
                color: Colors.red,
                tooltip: 'Удалить',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileCards() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: arenas.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final arena = arenas[index];
        return _ArenaCard(
          arena: arena,
          onEdit: () => onEdit(arena),
          onDelete: () => onDelete(arena),
        );
      },
    );
  }
}

class _ArenaCard extends StatelessWidget {
  final Map<String, dynamic> arena; // ← БЕЗ МОДЕЛЕЙ!
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ArenaCard({
    required this.arena,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  arena['name'] ?? '',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
              ArenaStatusBadge(status: arena['status'] ?? 'inactive'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Color(0xFF6B7280)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  arena['address'] ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 16,
                color: Color(0xFF3B82F6),
              ),
              const SizedBox(width: 4),
              Text(
                arena['nextBooking'] ?? 'Нет бронирований',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF3B82F6),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text(
                    'Редактировать',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete),
                color: Colors.red,
                style: IconButton.styleFrom(backgroundColor: Colors.red[50]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
