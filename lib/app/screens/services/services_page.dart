// services_page.dart — этот файл больше не используется как отдельная страница.
// Весь контент перенесён в ServiceDashboardScreen (service_dashboard_screen.dart).
// Файл оставлен для совместимости.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kff_owner_admin/app/screens/services/bloc/service_bloc.dart';
import 'package:kff_owner_admin/app/screens/services/bloc/service_event.dart';
import 'package:kff_owner_admin/app/screens/services/service_dashboard_screen.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ServiceBloc()..add(LoadServices()),
      child: const ServiceDashboardScreen(),
    );
  }
}
