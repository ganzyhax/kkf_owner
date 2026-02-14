part of 'dashboard_bloc.dart';

@immutable
sealed class DashboardState {}

final class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final List<Map<String, dynamic>> graphics;
  final List<Map<String, dynamic>> previousMonthGraphics;
  final Map<String, dynamic> stats; // Здесь уже есть все today-поля
  final List<Map<String, dynamic>> todayBookings;
  final String date;
  final String month;
  final bool isAllArenas;
  final List<Map<String, dynamic>> arenas;

  DashboardLoaded({
    required this.graphics,
    required this.previousMonthGraphics,
    required this.stats,
    required this.todayBookings,
    required this.date,
    required this.month,
    required this.isAllArenas,
    required this.arenas,
  });

  @override
  List<Object> get props => [
    graphics,
    previousMonthGraphics,
    stats,
    todayBookings,
    date,
    month,
    isAllArenas,
    arenas,
  ];
}

class DashboardError extends DashboardState {
  final String message;
  final List<Map<String, dynamic>> arenas; // ✅ Сохраняем арены даже при ошибке

  DashboardError({required this.message, this.arenas = const []});
}

class DashbooardSuccessMarkAsPaid extends DashboardState {}

class DashboardSuccessCancelBooking extends DashboardState {}
