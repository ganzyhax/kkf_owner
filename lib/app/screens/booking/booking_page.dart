import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'dart:html' as html;
import 'package:kff_owner_admin/app/screens/booking/components/booking_list_widget.dart';
import 'package:kff_owner_admin/app/screens/booking/components/offline_booking_dialog.dart';
import 'package:kff_owner_admin/app/screens/my_arena/bloc/my_arena_bloc.dart';
import 'package:kff_owner_admin/app/screens/booking/bloc/booking_bloc.dart';

class BookingPage extends StatelessWidget {
  const BookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => MyArenaBloc()..add(MyArenaLoad())),
        BlocProvider(create: (_) => BookingBloc()),
      ],
      child: const _BookingPageContent(),
    );
  }
}

class _BookingPageContent extends StatefulWidget {
  const _BookingPageContent();

  @override
  State<_BookingPageContent> createState() => _BookingPageContentState();
}

class _BookingPageContentState extends State<_BookingPageContent> {
  void _showOfflineBookingDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<BookingBloc>()),
          BlocProvider.value(value: context.read<MyArenaBloc>()),
        ],
        child: const OfflineBookingDialog(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive design
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    final isDesktop = screenWidth >= 1024;

    // Responsive padding
    final horizontalPadding = isMobile ? 16.0 : (isTablet ? 20.0 : 24.0);
    final verticalPadding = isMobile ? 16.0 : 24.0;

    // Responsive font sizes
    final titleFontSize = isMobile ? 22.0 : (isTablet ? 26.0 : 28.0);
    final subtitleFontSize = isMobile ? 13.0 : (isTablet ? 14.0 : 15.0);
    final buttonFontSize = isMobile ? 14.0 : 16.0;

    // Responsive button padding
    final buttonHorizontalPadding = isMobile ? 16.0 : 24.0;
    final buttonVerticalPadding = isMobile ? 12.0 : 16.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      body: SafeArea(
        child: BlocListener<BookingBloc, BookingState>(
          listener: (context, state) {
            if (state is BookingSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.all(isMobile ? 8 : 16),
                ),
              );
              final now = DateTime.now();

              final startDate = DateTime(now.year, now.month, 1);
              final endDate = DateTime(now.year, now.month + 1, 0);

              final startStr = DateFormat('yyyy-MM-dd').format(startDate);
              final endStr = DateFormat('yyyy-MM-dd').format(endDate);

              context.read<BookingBloc>().add(
                BookingGetByPeriod(startDate: startStr, endDate: endStr),
              );
            } else if (state is BookingError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.all(isMobile ? 8 : 16),
                ),
              );
            }
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1400),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Adaptive header with button
                      if (isMobile)
                        // Mobile layout: Stack vertically
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Управление Бронированиями',
                                  style: TextStyle(
                                    fontSize: titleFontSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Просмотр и создание бронирований',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: subtitleFontSize,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Full-width button on mobile
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _showOfflineBookingDialog,
                                icon: const Icon(
                                  Icons.add_circle_outline,
                                  size: 20,
                                ),
                                label: const Text('Создать бронь'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: buttonHorizontalPadding,
                                    vertical: buttonVerticalPadding,
                                  ),
                                  textStyle: TextStyle(
                                    fontSize: buttonFontSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      else
                        // Tablet & Desktop layout: Side by side
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Управление Бронированиями',
                                    style: TextStyle(
                                      fontSize: titleFontSize,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Просмотр и создание бронирований',
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: subtitleFontSize,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton.icon(
                              onPressed: _showOfflineBookingDialog,
                              icon: const Icon(Icons.add_circle_outline),
                              label: const Text('Создать бронь'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: buttonHorizontalPadding,
                                  vertical: buttonVerticalPadding,
                                ),
                                textStyle: TextStyle(
                                  fontSize: buttonFontSize,
                                  fontWeight: FontWeight.bold,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),

                      SizedBox(height: isMobile ? 20 : 24),

                      // Bookings overview widget
                      const BookingsOverviewWidget(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
