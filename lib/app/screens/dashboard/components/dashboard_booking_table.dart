// lib/screens/owner/dashboard/components/dashboard_booking_table.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kff_owner_admin/app/screens/dashboard/bloc/dashboard_bloc.dart';

class BookingsTable extends StatelessWidget {
  final List<Map<String, dynamic>> bookings;

  const BookingsTable({Key? key, required this.bookings}) : super(key: key);

  // 💎 ПРЕМИУМ ЦВЕТОВАЯ ПАЛИТРА
  static const Color primaryColor = Color(0xFF3B4A6B);
  static const Color accentColor = Color(0xFF3ECFBB);
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color headerBgColor = Color(0xFFF0F4F7);

  // ✅ ОТМЕТИТЬ КАК ОПЛАЧЕНО
  Future<void> _markAsPaid(
    BuildContext context,
    String bookingId,
    String? arenaId,
  ) async {
    String selectedPaymentMethod = 'Cash'; // По умолчанию наличные

    // ✅ СПИСОК МЕТОДОВ ОПЛАТЫ
    final paymentMethods = [
      {'value': 'Cash', 'label': '💵 Наличные', 'icon': Icons.money},
      {'value': 'Kaspi', 'label': '🏦 Kaspi Bank', 'icon': Icons.credit_card},
      {
        'value': 'Halyk',
        'label': '🏦 Halyk Bank',
        'icon': Icons.account_balance,
      },
      {
        'value': 'BCC',
        'label': '🏦 Банк ЦентрКредит',
        'icon': Icons.account_balance,
      },
      {
        'value': 'Forte',
        'label': '🏦 Forte Bank',
        'icon': Icons.account_balance,
      },
      {'value': 'RBK', 'label': '🏦 RBK Bank', 'icon': Icons.account_balance},
      {
        'value': 'Jusan',
        'label': '🏦 Jusan Bank',
        'icon': Icons.account_balance,
      },
      {
        'value': 'Bereke',
        'label': '🏦 Bereke Bank',
        'icon': Icons.account_balance,
      },
    ];

    final confirmed = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.payment, color: successColor),
              SizedBox(width: 12),
              Text(
                'Подтверждение оплаты',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Отметить это бронирование как полностью оплаченное?',
                  style: TextStyle(fontSize: 16, color: primaryColor),
                ),
                const SizedBox(height: 24),

                // ✅ ВЫБОР СПОСОБА ОПЛАТЫ
                const Text(
                  'Способ оплаты',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButton<String>(
                    value: selectedPaymentMethod,
                    isExpanded: true,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.arrow_drop_down),
                    items: paymentMethods.map((method) {
                      return DropdownMenuItem<String>(
                        value: method['value'] as String,
                        child: Row(
                          children: [
                            Icon(
                              method['icon'] as IconData,
                              size: 20,
                              color: Colors.grey.shade700,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              method['label'] as String,
                              style: const TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedPaymentMethod = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, {
                'confirmed': true,
                'paymentMethod': selectedPaymentMethod,
              }),
              style: ElevatedButton.styleFrom(
                backgroundColor: successColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Подтвердить',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (confirmed == null || confirmed['confirmed'] != true) return;

    final paymentMethod = confirmed['paymentMethod'] as String;

    try {
      // ✅ ПЕРЕДАЕМ МЕТОД ОПЛАТЫ В BLOC
      BlocProvider.of<DashboardBloc>(context).add(
        DashboardMarkBookingAsPaid(
          bookingId: bookingId,
          paymentMethod: paymentMethod, // ✅ ДОБАВИЛИ
        ),
      );

      if (context.mounted) {
        // ✅ ПОКАЗЫВАЕМ НАЗВАНИЕ МЕТОДА В SNACKBAR
        final methodName =
            paymentMethods.firstWhere(
                  (m) => m['value'] == paymentMethod,
                  orElse: () => {'label': paymentMethod},
                )['label']
                as String;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Оплачено через $methodName')),
              ],
            ),
            backgroundColor: successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Text('Ошибка: $e'),
              ],
            ),
            backgroundColor: errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  // ✅ ОТМЕНИТЬ БРОНИРОВАНИЕ
  Future<void> _cancelBooking(
    BuildContext context,
    String bookingId,
    double prepaidAmount,
    String? arenaId,
  ) async {
    final TextEditingController refundController = TextEditingController();
    final TextEditingController reasonController = TextEditingController();

    refundController.text = prepaidAmount.toStringAsFixed(0);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.cancel, color: errorColor),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Отмена бронирования',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: warningColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: warningColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.payment, color: warningColor, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Предоплата: ${prepaidAmount.toStringAsFixed(0)} ₸',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: warningColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: refundController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Сумма возврата клиенту (₸)',
                  hintText: 'Введите сумму',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(
                    Icons.currency_ruble,
                    color: primaryColor,
                  ),
                  helperText: 'Остальное будет удержано',
                  helperStyle: TextStyle(color: Colors.grey[600]),
                ),
                onChanged: (value) {},
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Причина отмены',
                  hintText: 'Укажите причину (необязательно)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(
                    Icons.description,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: errorColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Отменить бронирование',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final refundAmount = double.tryParse(refundController.text);
      final reason = reasonController.text.trim();

      context.read<DashboardBloc>().add(
        DashboardCancelBooking(
          bookingId: bookingId,
          cancellationReason: reason.isEmpty
              ? 'Отменено администратором'
              : reason,
          refundAmount: refundAmount,
        ),
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                const Text('Бронирование отменено'),
              ],
            ),
            backgroundColor: warningColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Text('Ошибка: $e'),
              ],
            ),
            backgroundColor: errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  // ✅ ПОКАЗАТЬ ДЕТАЛИ БРОНИРОВАНИЯ (адаптивно)
  void _showBookingDetails(BuildContext context, Map<String, dynamic> booking) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isMobile ? screenWidth * 0.95 : 500,
            maxHeight: isMobile
                ? MediaQuery.of(context).size.height * 0.9
                : 800,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header с градиентом
                Container(
                  padding: EdgeInsets.all(isMobile ? 16 : 20),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [primaryColor, primaryColor.withOpacity(0.8)],
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: Colors.white,
                        size: isMobile ? 20 : 24,
                      ),
                      SizedBox(width: isMobile ? 8 : 12),
                      Expanded(
                        child: Text(
                          'Бронирование #${booking['id']?.toString().substring(0, 8) ?? 'N/A'}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isMobile ? 18 : 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Контент с прокруткой
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isMobile ? 16 : 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailCard(
                          'Основная информация',
                          [
                            _buildDetailRow('Время', booking['time'] ?? ''),
                            _buildDetailRow('Арена', booking['arena'] ?? ''),
                            _buildDetailRow(
                              'Клиент',
                              booking['clientName'] ?? '',
                            ),
                          ],
                          Icons.info,
                          primaryColor,
                          isMobile,
                        ),
                        SizedBox(height: isMobile ? 12 : 16),
                        _buildDetailCard(
                          'Контактные данные',
                          [
                            _buildDetailRow(
                              'Телефон',
                              booking['clientPhone'] ?? 'Не указан',
                              isContact: true,
                            ),
                            _buildDetailRow(
                              'Email',
                              booking['clientEmail'] ?? 'Не указан',
                              isContact: true,
                            ),
                          ],
                          Icons.contact_phone,
                          accentColor,
                          isMobile,
                        ),
                        SizedBox(height: isMobile ? 12 : 16),
                        _buildDetailCard(
                          'Финансовая информация',
                          [
                            _buildDetailRow(
                              'Общая сумма',
                              '${booking['totalPrice']} ₸',
                              bold: true,
                              color: primaryColor,
                            ),
                            _buildDetailRow(
                              'Предоплата',
                              '${booking['prepaidAmount']} ₸',
                            ),
                            _buildDetailRow(
                              'Остаток',
                              '${booking['remainingAmount']} ₸',
                            ),
                          ],
                          Icons.account_balance_wallet,
                          warningColor,
                          isMobile,
                        ),
                        SizedBox(height: isMobile ? 12 : 16),
                        _buildDetailCard(
                          'Статусы',
                          [
                            _buildDetailRow(
                              'Статус оплаты',
                              booking['paymentDisplay'] ?? '',
                              color: _getPaymentColor(booking['paymentStatus']),
                              bold: true,
                            ),
                            _buildDetailRow(
                              'Статус брони',
                              booking['status'] ?? '',
                              color: (booking['status'] == 'CONFIRMED'
                                  ? successColor
                                  : primaryColor),
                            ),
                          ],
                          Icons.safety_check,
                          Colors.purple,
                          isMobile,
                        ),
                      ],
                    ),
                  ),
                ),

                // Footer
                Padding(
                  padding: EdgeInsets.all(isMobile ? 16 : 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 24 : 40,
                          vertical: isMobile ? 12 : 15,
                        ),
                      ),
                      child: const Text(
                        'Закрыть',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
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

  Widget _buildDetailCard(
    String title,
    List<Widget> children,
    IconData icon,
    Color color,
    bool isMobile,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isMobile ? 6 : 8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: isMobile ? 18 : 22),
                ),
                SizedBox(width: isMobile ? 10 : 15),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                      fontSize: isMobile ? 16 : 18,
                    ),
                  ),
                ),
              ],
            ),
            Divider(
              height: isMobile ? 20 : 25,
              thickness: 1,
              color: const Color(0xFFE5E7EB),
            ),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool bold = false,
    Color? color,
    bool isContact = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: primaryColor.withOpacity(0.7),
              fontSize: 15,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
                color: color ?? primaryColor,
                fontSize: 15,
                decoration: isContact && value != 'Не указан'
                    ? TextDecoration.underline
                    : TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPaymentColor(String? status) {
    switch (status) {
      case 'paid':
        return successColor;
      case 'prepaid':
        return warningColor;
      case 'unpaid':
        return errorColor;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Определяем размер экрана
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header - адаптивный
            _buildHeader(isMobile, isTablet),
            SizedBox(height: isMobile ? 20 : 30),

            if (bookings.isEmpty)
              _buildEmptyState(isMobile)
            else if (isMobile)
              _buildMobileBookingsList(context)
            else
              _buildBookingsTable(context),
          ],
        ),
      ),
    );
  }

  // ✅ Адаптивный Header
  Widget _buildHeader(bool isMobile, bool isTablet) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calendar_today,
                  color: accentColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Актуальные Бронирования',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            bookings.isEmpty
                ? 'На сегодня нет активных бронирований'
                : 'Управление бронированиями',
            style: TextStyle(
              color: primaryColor.withOpacity(0.7),
              fontSize: 13,
            ),
          ),
          if (bookings.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: primaryColor.withOpacity(0.3)),
              ),
              child: Text(
                '${bookings.length} ${_getBookingCountText(bookings.length)}',
                style: const TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ],
      );
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.calendar_today, color: accentColor, size: 22),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Актуальные Бронирования',
                style: TextStyle(
                  fontSize: isTablet ? 22 : 26,
                  fontWeight: FontWeight.w800,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                bookings.isEmpty
                    ? 'На сегодня нет активных бронирований'
                    : 'Управление бронированиями и статусами оплат',
                style: TextStyle(
                  color: primaryColor.withOpacity(0.7),
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        if (bookings.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: primaryColor.withOpacity(0.3)),
            ),
            child: Text(
              '${bookings.length} ${_getBookingCountText(bookings.length)}',
              style: const TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 40 : 60),
      decoration: BoxDecoration(
        color: headerBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              size: isMobile ? 60 : 80,
              color: primaryColor.withOpacity(0.3),
            ),
            SizedBox(height: isMobile ? 16 : 25),
            Text(
              'Нет бронирований на сегодня',
              style: TextStyle(
                fontSize: isMobile ? 18 : 20,
                color: primaryColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: isMobile ? 4 : 8),
            Text(
              'Все новые бронирования будут отображаться здесь автоматически.',
              style: TextStyle(
                color: primaryColor.withOpacity(0.6),
                fontSize: isMobile ? 13 : 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Mobile: Card List вместо таблицы
  Widget _buildMobileBookingsList(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        final dateTime = DateTime.parse(booking['startTime']);
        final formatter = DateFormat('MMMM d', 'ru');
        String formatted = formatter.format(dateTime);
        String createdDay = formatted[0].toUpperCase() + formatted.substring(1);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () => _showBookingDetails(context, booking),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          booking['clientName'] ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      _buildPaymentBadgeMobile(
                        booking['paymentDisplay'] ?? '',
                        booking['paymentStatus'] ?? 'unpaid',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$createdDay ${booking['time'] ?? ''}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.place, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          booking['arena'] ?? '',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMobileActionButton(
                          context,
                          Icons.remove_red_eye_outlined,
                          'Детали',
                          primaryColor,
                          () => _showBookingDetails(context, booking),
                        ),
                      ),
                      if (booking['canMarkPaid'] ?? false) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildMobileActionButton(
                            context,
                            Icons.check_circle_outline,
                            'Оплачено',
                            successColor,
                            () => _markAsPaid(
                              context,
                              booking['id']?.toString() ?? '',
                              booking['arenaId']?.toString(),
                            ),
                          ),
                        ),
                      ],
                      if (booking['canCancel'] ?? false) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildMobileActionButton(
                            context,
                            Icons.close_rounded,
                            'Отменить',
                            errorColor,
                            () => _cancelBooking(
                              context,
                              booking['id']?.toString() ?? '',
                              (booking['prepaidAmount'] ?? 0).toDouble(),
                              booking['arenaId']?.toString(),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentBadgeMobile(String text, String status) {
    Color bgColor, textColor, iconColor;
    IconData icon;

    switch (status) {
      case 'paid':
        bgColor = successColor.withOpacity(0.1);
        textColor = successColor;
        iconColor = successColor;
        icon = Icons.check_circle;
        break;
      case 'prepaid':
        bgColor = warningColor.withOpacity(0.1);
        textColor = warningColor;
        iconColor = warningColor;
        icon = Icons.payment;
        break;
      case 'unpaid':
        bgColor = errorColor.withOpacity(0.1);
        textColor = errorColor;
        iconColor = errorColor;
        icon = Icons.pending;
        break;
      default:
        bgColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey;
        iconColor = Colors.grey;
        icon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor.withOpacity(0.5), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: iconColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileActionButton(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onPressed,
  ) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withOpacity(0.3)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // Desktop Table (existing code)
  Widget _buildBookingsTable(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        color: Colors.white,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: headerBgColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                _TableSpace(
                  width: 120,
                  child: _TableHeaderContent('Время', Icons.access_time),
                ),
                _TableSpace(
                  width: 140,
                  child: _TableHeaderContent('Объект', Icons.place),
                ),
                _TableSpace(
                  width: 150,
                  child: _TableHeaderContent('Клиент', Icons.person),
                ),
                _TableSpace(
                  width: 150,
                  child: _TableHeaderContent('Тип платежа', Icons.payment),
                ),
                _TableSpace(
                  width: 180,
                  child: _TableHeaderContent('Оплата', Icons.payment),
                ),
                _TableSpace(
                  width: 140,
                  child: _TableHeaderContent('Контакт', Icons.phone),
                ),
                _TableSpace(
                  width: 200,
                  child: _TableHeaderContent('Действия', Icons.settings),
                ),
              ],
            ),
          ),
          ...bookings.asMap().entries.map((entry) {
            final index = entry.key;
            final booking = entry.value;

            Color rowColor = index % 2 == 0
                ? Colors.white
                : const Color(0xFFFAFAFA);

            if (booking['paymentStatus'] == 'prepaid') {
              rowColor = warningColor.withOpacity(0.08);
            } else if (booking['paymentStatus'] == 'unpaid') {
              rowColor = errorColor.withOpacity(0.08);
            }

            final dateTime = DateTime.parse(booking['startTime']);
            final formatter = DateFormat('MMMM d', 'ru');
            String formatted = formatter.format(dateTime);
            String createdDay =
                formatted[0].toUpperCase() + formatted.substring(1);

            return Container(
              decoration: BoxDecoration(
                color: rowColor,
                border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
              ),
              child: Row(
                children: [
                  _TableSpace(
                    width: 120,
                    child: _TableCell(
                      createdDay + ' ' + (booking['time'] ?? ''),
                      true,
                    ),
                  ),
                  _TableSpace(
                    width: 140,
                    child: _TableCell(booking['arena'] ?? '', false),
                  ),
                  _TableSpace(
                    width: 150,
                    child: _TableCell(booking['clientName'] ?? '', true),
                  ),
                  _TableSpace(
                    width: 150,
                    child: _TableCell(
                      (booking['isOfflineBooking']) ? 'Оффлайн' : 'Онлайн',
                      true,
                      isOnline: (booking['isOfflineBooking']) ? false : true,
                    ),
                  ),
                  _buildPaymentBadge(
                    booking['paymentDisplay'] ?? '',
                    booking['paymentStatus'] ?? 'unpaid',
                    180,
                  ),
                  _TableSpace(
                    width: 140,
                    child: _TableCell(
                      booking['clientPhone'] ?? '',
                      false,
                      alignment: TextAlign.right,
                    ),
                  ),
                  _buildActionsCell(context, booking, 200),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  static Widget _TableHeaderContent(String text, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: primaryColor.withOpacity(0.7)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: primaryColor,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ],
    );
  }

  static Widget _TableCell(
    String text,

    bool bold, {
    bool? isOnline,
    TextAlign alignment = TextAlign.left,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        text,
        textAlign: alignment,
        style: TextStyle(
          fontSize: 14,
          fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
          color: (isOnline != null)
              ? (isOnline == true)
                    ? Colors.green
                    : Colors.amberAccent
              : primaryColor,
        ),
      ),
    );
  }

  static Widget _TableSpace({required double width, required Widget child}) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: child,
    );
  }

  Widget _buildPaymentBadge(String text, String status, double width) {
    Color bgColor, textColor, iconColor;
    IconData icon;

    switch (status) {
      case 'paid':
        bgColor = successColor.withOpacity(0.1);
        textColor = successColor;
        iconColor = successColor;
        icon = Icons.check_circle;
        break;
      case 'prepaid':
        bgColor = warningColor.withOpacity(0.1);
        textColor = warningColor;
        iconColor = warningColor;
        icon = Icons.payment;
        break;
      case 'unpaid':
        bgColor = errorColor.withOpacity(0.1);
        textColor = errorColor;
        iconColor = errorColor;
        icon = Icons.pending;
        break;
      default:
        bgColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey;
        iconColor = Colors.grey;
        icon = Icons.help_outline;
    }

    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: iconColor.withOpacity(0.5), width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: iconColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsCell(
    BuildContext context,
    Map<String, dynamic> booking,
    double width,
  ) {
    final canMarkPaid = booking['canMarkPaid'] ?? false;
    final canCancel = booking['canCancel'] ?? false;
    final bookingId = booking['id']?.toString() ?? '';
    final prepaidAmount = (booking['prepaidAmount'] ?? 0).toDouble();
    final arenaId = booking['arenaId']?.toString();

    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildActionButton(
            context,
            Icons.remove_red_eye_outlined,
            'Детали',
            primaryColor,
            () => _showBookingDetails(context, booking),
          ),
          if (canMarkPaid) const SizedBox(width: 8),
          if (canMarkPaid)
            _buildActionButton(
              context,
              Icons.check_circle_outline,
              'Отметить как оплачено',
              successColor,
              () => _markAsPaid(context, bookingId, arenaId),
            ),
          if (canCancel) const SizedBox(width: 8),
          if (canCancel)
            _buildActionButton(
              context,
              Icons.close_rounded,
              'Отменить',
              errorColor,
              () => _cancelBooking(context, bookingId, prepaidAmount, arenaId),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String tooltip,
    Color color,
    VoidCallback onPressed,
  ) {
    return Tooltip(
      message: tooltip,
      textStyle: const TextStyle(color: Colors.white, fontSize: 12),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.1), width: 1.0),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }

  String _getBookingCountText(int count) {
    if (count % 10 == 1 && count % 100 != 11) return 'бронирование';
    if (count % 10 >= 2 &&
        count % 10 <= 4 &&
        (count % 100 < 10 || count % 100 >= 20))
      return 'бронирования';
    return 'бронирований';
  }
}
