// lib/app/api/booking_api_service.dart
import 'package:kff_owner_admin/app/api/api.dart';

class BookingApiService {
  /// Отметить бронирование как полностью оплаченное
  static Future<Map<String, dynamic>> markAsFullyPaid(String bookingId) async {
    try {
      final response = await ApiClient.put(
        'api/bookings/$bookingId/mark-as-paid',
        {},
      );

      if (response != null && response['success'] == true) {
        return {
          'success': true,
          'message': 'Бронирование отмечено как оплаченное',
          'data': response['data'],
        };
      } else {
        return {
          'success': false,
          'message': response?['message'] ?? 'Ошибка при отметке оплаты',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Ошибка соединения: $e'};
    }
  }

  /// Отменить бронирование
  static Future<Map<String, dynamic>> cancelBooking(
    String bookingId, {
    required String cancellationReason,
    required double refundAmount,
  }) async {
    try {
      final response = await ApiClient.post('api/bookings/$bookingId/cancel', {
        'cancellationReason': cancellationReason,
        'refundAmount': refundAmount,
      });

      if (response != null && response['success'] == true) {
        return {
          'success': true,
          'message': 'Бронирование отменено',
          'data': response['data'],
        };
      } else {
        return {
          'success': false,
          'message': response?['message'] ?? 'Ошибка при отмене бронирования',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Ошибка соединения: $e'};
    }
  }

  /// Получить детали бронирования
  static Future<Map<String, dynamic>> getBookingDetails(
    String bookingId,
  ) async {
    try {
      final response = await ApiClient.get('api/bookings/$bookingId');

      if (response != null && response['success'] == true) {
        return {'success': true, 'data': response['data']};
      } else {
        return {
          'success': false,
          'message': response?['message'] ?? 'Ошибка при загрузке данных',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Ошибка соединения: $e'};
    }
  }
}
