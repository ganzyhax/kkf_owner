part of 'dashboard_bloc.dart';

@immutable
sealed class DashboardEvent {}

class DashboardLoad extends DashboardEvent {
  final String arenaId;

  DashboardLoad({required this.arenaId});
}

class DashboardLoadAll extends DashboardEvent {
  DashboardLoadAll();
}

class DashboardRefresh extends DashboardEvent {
  final String? arenaId; // ✅ Может быть null для "Все арены"

  DashboardRefresh({this.arenaId});
}

// ✅ НОВЫЕ СОБЫТИЯ ДЛЯ ДЕЙСТВИЙ С БРОНИРОВАНИЯМИ
class DashboardMarkBookingAsPaid extends DashboardEvent {
  final String bookingId;
  final String? arenaId;

  DashboardMarkBookingAsPaid({required this.bookingId, this.arenaId});
}

class DashboardCancelBooking extends DashboardEvent {
  final String bookingId;
  final double? refundAmount;
  final String cancellationReason;
  final String? arenaId;

  DashboardCancelBooking({
    required this.bookingId,
    this.refundAmount,
    required this.cancellationReason,
    this.arenaId,
  });
}

class DashboardLoadForDate extends DashboardEvent {
  final DateTime selectedDate;
  final String? arenaId; // null или 'all' для режима "Все арены"

  DashboardLoadForDate({required this.selectedDate, this.arenaId});
}
