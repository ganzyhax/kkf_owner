import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:kff_owner_admin/app/api/api.dart';
import 'package:meta/meta.dart';

part 'booking_event.dart';
part 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  BookingBloc() : super(BookingInitial()) {
    // ==================== ЗАГРУЗИТЬ ДОСТУПНОСТЬ ====================
    on<BookingLoadAvailability>((event, emit) async {
      try {
        emit(BookingLoading());

        var res = await ApiClient.get(
          'api/bookings/availability/${event.arenaId}/${event.date}',
        );
        log('Availability response: $res');

        if (res['success'] == true) {
          // ✅ ИСПРАВЛЕНО: данные внутри res['data']
          final data = res['data'] as Map<String, dynamic>;

          log('Booked slots: ${data['bookedSlots']}');

          emit(
            BookingAvailabilityLoaded(
              bookedSlots: List<Map<String, dynamic>>.from(
                data['bookedSlots'] ?? [],
              ),
              availableHours: List<String>.from(data['availableHours'] ?? []),
            ),
          );
        } else {
          emit(BookingError(message: 'Failed to load availability'));
        }
      } catch (e) {
        log('Error loading availability: $e');
        emit(BookingError(message: e.toString()));
      }
    });
    // ==================== СОЗДАТЬ ОФФЛАЙН БРОНЬ ====================
    on<BookingCreateOffline>((event, emit) async {
      try {
        emit(BookingLoading());

        final body = {
          'arenaId': event.arenaId,
          'startTime': event.startTime.toIso8601String(),
          'endTime': event.endTime.toIso8601String(),
          'clientName': event.clientName,
          'clientPhone': event.clientPhone, // ✅
          'prepaidAmount': event.prepaidAmount,
          'totalPrice': event.totalPrice,
          'isFullyPaid': event.isFullyPaid, // ✅
        };

        log('Creating offline booking: $body');

        var res = await ApiClient.post('api/bookings/offline', body);
        log('Create booking response: $res');

        if (res['success'] == true) {
          emit(BookingSuccess(message: 'Бронь создана!'));
        } else {
          emit(BookingError(message: res['message'] ?? 'Ошибка бронирования'));
        }
      } catch (e) {
        log('Error creating booking: $e');
        emit(BookingError(message: e.toString()));
      }
    });

    // ==================== ОТМЕТИТЬ КАК ПОЛНОСТЬЮ ОПЛАЧЕНО ====================
    on<BookingMarkPaid>((event, emit) async {
      try {
        emit(BookingLoading());

        var res = await ApiClient.patch(
          'api/bookings/${event.bookingId}/mark-paid',
          {},
        );
        log('Mark paid response: $res');

        if (res['success'] == true) {
          emit(BookingSuccess(message: 'Отмечено как оплачено!'));
        } else {
          emit(BookingError(message: res['message'] ?? 'Ошибка'));
        }
      } catch (e) {
        log('Error marking paid: $e');
        emit(BookingError(message: e.toString()));
      }
    });

    // ==================== ПОЛУЧИТЬ БРОНИ ДЛЯ АРЕНЫ ====================

    on<BookingCancel>((event, emit) async {
      try {
        emit(BookingLoading());

        final body = {
          'refundAmount': event.refundAmount,
          if (event.cancellationReason != null)
            'cancellationReason': event.cancellationReason,
        };

        var res = await ApiClient.put(
          'api/bookings/${event.bookingId}/cancel',
          body,
        );

        log('Cancel booking response: $res');

        if (res['success'] == true) {
          final refundInfo = res['data']?['refundInfo'];

          String message = 'Бронирование успешно отменено';

          if (refundInfo != null) {
            final refund = refundInfo['refundAmount'] ?? 0;
            final retained = refundInfo['retainedAmount'] ?? 0;
            final prepaid = refundInfo['prepaidAmount'] ?? 0;

            message += '\n\nПредоплата: $prepaid ₸';
            message += '\nВозврат: $refund ₸';
            message += '\nУдержано: $retained ₸';
          }

          emit(BookingSuccess(message: message));
        } else {
          emit(BookingError(message: res['message'] ?? 'Ошибка при отмене'));
        }
      } catch (e) {
        log('Error: $e');
        emit(BookingError(message: e.toString()));
      }
    });
    on<BookingGetByPeriod>((event, emit) async {
      try {
        emit(BookingLoading());

        var res = await ApiClient.get(
          'api/bookings/owner/by-period?startDate=${event.startDate}&endDate=${event.endDate}',
        );
        log('Bookings by period response: $res');

        if (res['success'] == true) {
          final data = res['data'];

          emit(
            BookingsByPeriodLoaded(
              period: data['period'],
              statistics: data['statistics'],
              bookings: List<Map<String, dynamic>>.from(data['bookings'] ?? []),
              cashbackEnabled: data['cashbackEnabled'] ?? false,
            ),
          );
        } else {
          emit(BookingError(message: res['message'] ?? 'Ошибка загрузки'));
        }
      } catch (e) {
        log('Error loading bookings by period: $e');
        emit(BookingError(message: e.toString()));
      }
    });
  }
}
