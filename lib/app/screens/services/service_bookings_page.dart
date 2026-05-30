// service_bookings_page.dart — этот файл больше не используется как отдельная страница.
// Весь контент перенесён в ServiceDashboardScreen (service_dashboard_screen.dart).
import 'package:flutter/material.dart';
import 'package:kff_owner_admin/app/screens/services/service_dashboard_screen.dart';

class ServiceBookingsPage extends StatelessWidget {
  const ServiceBookingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ServiceDashboardScreen();
  }
}
