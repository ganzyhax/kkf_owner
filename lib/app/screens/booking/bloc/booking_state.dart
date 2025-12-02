part of 'booking_bloc.dart';

@immutable
sealed class BookingState {}

final class BookingInitial extends BookingState {}

final class BookingLoading extends BookingState {}

final class BookingAvailabilityLoaded extends BookingState {
  final List<Map<String, dynamic>> bookedSlots;
  final List<String> availableHours;

  BookingAvailabilityLoaded({
    required this.bookedSlots,
    required this.availableHours,
  });
}

final class BookingListLoaded extends BookingState {
  final List<Map<String, dynamic>> bookings;
  BookingListLoaded({required this.bookings});
}

final class BookingSuccess extends BookingState {
  final String message;
  BookingSuccess({required this.message});
}

final class BookingError extends BookingState {
  final String message;
  BookingError({required this.message});
}

final class BookingsByPeriodLoaded extends BookingState {
  final Map<String, dynamic> period;
  final Map<String, dynamic> statistics;
  final List<Map<String, dynamic>> bookings;
  final bool cashbackEnabled;

  BookingsByPeriodLoaded({
    required this.period,
    required this.statistics,
    required this.bookings,
    required this.cashbackEnabled,
  });
}
