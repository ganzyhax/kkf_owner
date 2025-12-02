// lib/screens/owner/owner_layout.dart
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:kff_owner_admin/app/screens/booking/booking_page.dart';
import 'package:kff_owner_admin/app/screens/finance/finance_screen.dart';
import 'package:kff_owner_admin/app/screens/my_arena/my_arena_screen.dart';
import 'package:kff_owner_admin/app/screens/review/review_screen.dart';
import 'package:kff_owner_admin/app/utils/local_utils.dart';
import 'dashboard/dashboard_screen.dart';

class OwnerLayout extends StatefulWidget {
  const OwnerLayout({Key? key}) : super(key: key);

  @override
  State<OwnerLayout> createState() => _OwnerLayoutState();
}

class _OwnerLayoutState extends State<OwnerLayout> {
  String _activeSection = 'dashboard';

  void _onSectionChanged(String section) {
    setState(() {
      _activeSection = section;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              title: const Text('Панель Владельца'),
              backgroundColor: Colors.white,
            )
          : null,
      body: Row(
        children: [
          // Sidebar
          if (!isMobile)
            _OwnerSidebar(
              activeSection: _activeSection,
              onSectionChanged: _onSectionChanged,
            ),

          // Main Content БЕЗ padding
          Expanded(
            child: _getActiveScreen(), // ✅ Убери любой padding отсюда
          ),
        ],
      ),
      drawer: isMobile
          ? Drawer(
              child: _OwnerSidebar(
                activeSection: _activeSection,
                onSectionChanged: _onSectionChanged,
              ),
            )
          : null,
    );
  }

  Widget _getActiveScreen() {
    switch (_activeSection) {
      case 'dashboard':
        return const DashboardScreen();
      case 'arenas':
        return const MyArenasScreen();
      case 'bookings':
        // return _buildPlaceholder('Бронирования', Icons.calendar_today);
        return BookingPage();
      case 'finance':
        return FinanceDashboard();
      case 'feedback':
        return ReviewScreen();
      default:
        return const DashboardScreen();
    }
  }

  Widget _buildPlaceholder(String title, IconData icon) {
    return Container(
      color: const Color(0xFFF9FAFB),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 100, color: Colors.grey[300]),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Скоро здесь появится контент',
              style: TextStyle(fontSize: 16, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== SIDEBAR ====================
class _OwnerSidebar extends StatelessWidget {
  final String activeSection;
  final Function(String) onSectionChanged;

  const _OwnerSidebar({
    required this.activeSection,
    required this.onSectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 256,
      color: const Color(0xFF1F2937),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: const [
                Icon(Icons.shield, color: Color(0xFFFBBF24), size: 32),
                SizedBox(width: 12),
                Text(
                  'Панель Владельца',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Navigation
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildNavItem(Icons.show_chart, 'Обзор', 'dashboard'),
                  _buildNavItem(Icons.sports_soccer, 'Мои Арены', 'arenas'),
                  _buildNavItem(
                    Icons.calendar_today,
                    'Бронирования',
                    'bookings',
                  ),
                  _buildNavItem(
                    Icons.account_balance_wallet,
                    'Финансы',
                    'finance',
                  ),
                  _buildNavItem(Icons.comment, 'Отзывы и Рейтинг', 'feedback'),
                ],
              ),
            ),
          ),

          // Logout
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFF374151))),
            ),
            child: InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Выход'),
                    content: const Text('Вы уверены, что хотите выйти?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Отмена'),
                      ),
                      TextButton(
                        onPressed: () async {
                          // Navigator.pop(context);
                          // // TODO: Logout logic
                          await LocalUtils.logout();
                          html.window.location.reload();
                        },
                        child: const Text('Выйти'),
                      ),
                    ],
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: const [
                    Icon(Icons.logout, color: Color(0xFF9CA3AF), size: 20),
                    SizedBox(width: 12),
                    Text('Выйти', style: TextStyle(color: Color(0xFF9CA3AF))),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, String section) {
    final isActive = activeSection == section;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isActive ? const Color(0xFF374151) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () => onSectionChanged(section),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isActive ? Colors.white : const Color(0xFF9CA3AF),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: isActive ? Colors.white : const Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
