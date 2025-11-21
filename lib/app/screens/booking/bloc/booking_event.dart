part of 'booking_bloc.dart';

@immutable
sealed class BookingEvent {}

final class BookingLoadAvailability extends BookingEvent {
  final String arenaId;
  final String date; // 'YYYY-MM-DD'
  BookingLoadAvailability({required this.arenaId, required this.date});
}

class BookingCreateOffline extends BookingEvent {
  final String arenaId;
  final DateTime startTime;
  final DateTime endTime;
  final String clientName;
  final String clientPhone;
  final double totalPrice;
  final double prepaidAmount;
  final bool isFullyPaid; // ✅ Добавлено

  BookingCreateOffline({
    required this.arenaId,
    required this.startTime,
    required this.endTime,
    required this.clientName,
    required this.clientPhone,
    required this.totalPrice,
    required this.prepaidAmount,
    required this.isFullyPaid, // ✅ Добавлено
  });
}

final class BookingMarkPaid extends BookingEvent {
  final String bookingId;
  BookingMarkPaid({required this.bookingId});
}

final class BookingLoadForArena extends BookingEvent {
  final String arenaId;
  BookingLoadForArena({required this.arenaId});
}

class BookingCancel extends BookingEvent {
  final String bookingId;
  final double refundAmount; // ✅ Сумма возврата (админ указывает)
  final String? cancellationReason; // ✅ Опциональная причина отмены

  BookingCancel({
    required this.bookingId,
    required this.refundAmount,
    this.cancellationReason,
  });
}
