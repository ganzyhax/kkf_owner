import 'dart:convert';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kff_owner_admin/app/api/api.dart';
import 'package:meta/meta.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  List<Map<String, dynamic>> _cachedArenas = [];

  DashboardBloc() : super(DashboardInitial()) {
    on<DashboardLoad>(_onDashboardLoad);
    on<DashboardLoadAll>(_onDashboardLoadAll);
    on<DashboardRefresh>(_onDashboardRefresh);
    on<DashboardMarkBookingAsPaid>(_onMarkBookingAsPaid);
    on<DashboardCancelBooking>(_onCancelBooking);
    on<DashboardLoadForDate>(_onDashboardLoadForDate);
  }

  // ==================== ЗАГРУЗИТЬ ОДНУ АРЕНУ ====================
  Future<void> _onDashboardLoad(
    DashboardLoad event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());

    try {
      var res = await ApiClient.get(
        'api/dashboard/owner/arena?arenaId=${event.arenaId}',
      );

      log('Dashboard response: $res');
      log('Response type: ${res.runtimeType}');

      if (res == null) {
        emit(
          DashboardError(
            message: 'Ответ сервера пустой',
            arenas: _cachedArenas,
          ),
        );
        return;
      }

      if (res['success'] == true) {
        final data = res['data'];

        emit(
          DashboardLoaded(
            graphics:
                (data['graphic'] as List<dynamic>?)
                    ?.map((e) => e as Map<String, dynamic>)
                    .toList() ??
                [],
            previousMonthGraphics:
                (res['data']['previousMonthGraphic'] as List<dynamic>?)
                    ?.map((e) => e as Map<String, dynamic>)
                    .toList() ??
                [],
            stats: (data['stats'] ?? {}) as Map<String, dynamic>,
            todayBookings: ((data['todayBookings'] ?? []) as List<dynamic>)
                .map((e) => e as Map<String, dynamic>)
                .toList(),
            date: data['date']?.toString() ?? '',
            month: data['month']?.toString() ?? '',
            isAllArenas: false,
            arenas: _cachedArenas,
          ),
        );
      } else {
        emit(
          DashboardError(
            message: res['message']?.toString() ?? 'Ошибка загрузки данных',
            arenas: _cachedArenas,
          ),
        );
      }
    } catch (e, stackTrace) {
      log('Dashboard error: $e');
      log('Stack trace: $stackTrace');
      emit(DashboardError(message: e.toString(), arenas: _cachedArenas));
    }
  }

  // ==================== ЗАГРУЗИТЬ ВСЕ АРЕНЫ ====================
  Future<void> _onDashboardLoadAll(
    DashboardLoadAll event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());

    try {
      var res = await ApiClient.get('api/dashboard/owner/all-arenas');

      log('Dashboard all arenas response: $res');
      log('Response type: ${res.runtimeType}');

      if (res == null) {
        emit(
          DashboardError(
            message: 'Ответ сервера пустой',
            arenas: _cachedArenas,
          ),
        );
        return;
      }

      // ✅ Обновляем кэш арен если они есть в ответе
      if (res['data']['arenas'] != null) {
        _cachedArenas = (res['data']['arenas'] as List<dynamic>)
            .map((e) => e as Map<String, dynamic>)
            .toList();
        log('Updated cached arenas count: ${_cachedArenas.length}');
      }

      if (res['success'] && res['data'] != null) {
        final data = res['data'] as Map<String, dynamic>;

        emit(
          DashboardLoaded(
            stats: (data['stats'] ?? {}) as Map<String, dynamic>,
            todayBookings: ((data['todayBookings'] ?? []) as List<dynamic>)
                .map((e) => e as Map<String, dynamic>)
                .toList(),
            date: data['date']?.toString() ?? '',
            month: data['month']?.toString() ?? '',
            isAllArenas: true,
            arenas: _cachedArenas,
            graphics:
                (data['graphic'] as List<dynamic>?)
                    ?.map((e) => e as Map<String, dynamic>)
                    .toList() ??
                [],
            previousMonthGraphics:
                (res['data']['previousMonthGraphic'] as List<dynamic>?)
                    ?.map((e) => e as Map<String, dynamic>)
                    .toList() ??
                [],
          ),
        );
      } else {
        emit(
          DashboardError(
            message: res['message']?.toString() ?? 'Ошибка загрузки данных',
            arenas: _cachedArenas,
          ),
        );
      }
    } catch (e, stackTrace) {
      log('Dashboard all error: $e');
      log('Stack trace: $stackTrace');
      emit(DashboardError(message: e.toString(), arenas: _cachedArenas));
    }
  }

  // ==================== ОБНОВИТЬ ДАШБОРД ====================
  Future<void> _onDashboardRefresh(
    DashboardRefresh event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      String endpoint;
      bool isAll = false;

      if (event.arenaId == null || event.arenaId == 'all') {
        endpoint = 'api/dashboard/owner/all-arenas';
        isAll = true;
      } else {
        endpoint = 'api/dashboard/owner/arena?arenaId=${event.arenaId}';
        isAll = false;
      }

      var res = await ApiClient.get(endpoint);

      log('Dashboard refresh response: $res');

      if (res['success'] == true) {
        final data = isAll ? res['data'] : res;

        emit(
          DashboardLoaded(
            graphics:
                (data['graphic'] as List<dynamic>?)
                    ?.map((e) => e as Map<String, dynamic>)
                    .toList() ??
                [],
            stats: data['stats'] as Map<String, dynamic>,
            todayBookings: (data['todayBookings'] as List<dynamic>)
                .map((e) => e as Map<String, dynamic>)
                .toList(),
            date: data['date'] ?? '',
            month: data['month'] ?? '',
            isAllArenas: isAll,
            arenas: _cachedArenas,
            previousMonthGraphics:
                (res['data']['previousMonthGraphic'] as List<dynamic>?)
                    ?.map((e) => e as Map<String, dynamic>)
                    .toList() ??
                [],
          ),
        );
      } else {
        emit(
          DashboardError(
            message: res['message'] ?? 'Ошибка обновления данных',
            arenas: _cachedArenas,
          ),
        );
      }
    } catch (e) {
      log('Dashboard refresh error: $e');
      emit(DashboardError(message: e.toString(), arenas: _cachedArenas));
    }
  }

  // ==================== ОТМЕТИТЬ КАК ОПЛАЧЕНО ====================
  Future<void> _onMarkBookingAsPaid(
    DashboardMarkBookingAsPaid event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      log('Marking booking as paid: ${event.bookingId}');

      var res = await ApiClient.patch(
        'api/bookings/${event.bookingId}/mark-paid',
        {},
      );

      log('Mark as paid response: $res');

      if (res['success'] == true) {
        // ✅ Обновляем дашборд после успешной операции
        if (event.arenaId == null || event.arenaId == 'all') {
          emit(DashbooardSuccessMarkAsPaid());
          add(DashboardLoadAll());
        } else {
          add(DashboardLoad(arenaId: event.arenaId!));
        }
      } else {
        throw Exception(res['message'] ?? 'Ошибка при обновлении');
      }
    } catch (e, stackTrace) {
      log('Mark as paid error: $e');
      log('Stack trace: $stackTrace');
      // Можно добавить состояние ошибки или показать snackbar
      emit(
        DashboardError(
          message: 'Ошибка при пометке оплаты: $e',
          arenas: _cachedArenas,
        ),
      );
    }
  }

  // ==================== ОТМЕНИТЬ БРОНИРОВАНИЕ ====================
  Future<void> _onCancelBooking(
    DashboardCancelBooking event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      log('Cancelling booking: ${event.bookingId}');

      final body = <String, dynamic>{
        'cancellationReason': event.cancellationReason,
      };

      if (event.refundAmount != null) {
        body['refundAmount'] = event.refundAmount;
      }

      final response = await ApiClient.put(
        'api/bookings/${event.bookingId}/cancel',
        body,
      );

      log('Cancel booking response: $response');

      if (response['success'] == true) {
        // ✅ Обновляем дашборд после успешной операции
        if (event.arenaId == null || event.arenaId == 'all') {
          emit(DashboardSuccessCancelBooking());
          add(DashboardLoadAll());
        } else {
          add(DashboardLoad(arenaId: event.arenaId!));
        }
      } else {
        throw Exception(response['message'] ?? 'Ошибка при отмене');
      }
    } catch (e, stackTrace) {
      log('Cancel booking error: $e');
      log('Stack trace: $stackTrace');
      emit(
        DashboardError(
          message: 'Ошибка при отмене бронирования: $e',
          arenas: _cachedArenas,
        ),
      );
    }
  }

  Future<void> _onDashboardLoadForDate(
    DashboardLoadForDate event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(event.selectedDate);
      log(
        '📍 Loading bookings for date: $formattedDate, arena: ${event.arenaId}',
      );

      final isAllArenasMode = event.arenaId == null || event.arenaId == 'all';

      if (isAllArenasMode) {
        add(DashboardLoadAll());
        return;
      }

      final url =
          'api/dashboard/owner/arena/day?arenaId=${event.arenaId}&date=$formattedDate';

      log('📡 Request URL: $url');

      final res = await ApiClient.get(url);

      log('📦 Raw response: ${json.encode(res)}');

      if (res != null && res['success'] == true) {
        // ✅ Проверяем структуру ответа
        log('📊 Response keys: ${res.keys.toList()}');

        final statsData = res['data']['stats'];

        final newStats = statsData as Map<String, dynamic>? ?? {};

        final newBookings =
            (res['data']['todayBookings'] as List<dynamic>?)
                ?.map((e) => e as Map<String, dynamic>)
                .toList() ??
            [];

        log('✅ Parsed stats count: ${newStats.length} keys');
        log('✅ Parsed bookings count: ${newBookings.length}');

        final dateData = res['data']['date'];
        String displayDate;

        if (dateData is Map<String, dynamic>) {
          displayDate =
              dateData['label']?.toString() ??
              dateData['formatted']?.toString() ??
              formattedDate;
        } else {
          displayDate = dateData?.toString() ?? formattedDate;
        }

        final displayMonth =
            res['data']['month']?.toString() ??
            DateFormat('MMMM yyyy').format(event.selectedDate);

        log('📅 Display date: $displayDate, month: $displayMonth');

        final currentState = state;
        if (currentState is DashboardLoaded) {
          emit(
            DashboardLoaded(
              graphics:
                  (res['data']['graphic'] as List<dynamic>?)
                      ?.map((e) => e as Map<String, dynamic>)
                      .toList() ??
                  [],
              previousMonthGraphics:
                  (res['data']['previousMonthGraphic'] as List<dynamic>?)
                      ?.map((e) => e as Map<String, dynamic>)
                      .toList() ??
                  [],
              stats: newStats,
              todayBookings: newBookings,
              date: displayDate,
              month: displayMonth,
              isAllArenas: false,
              arenas: currentState.arenas,
            ),
          );
          log('✅ State emitted successfully');
        } else {
          emit(
            DashboardLoaded(
              graphics:
                  (res['data']['graphic'] as List<dynamic>?)
                      ?.map((e) => e as Map<String, dynamic>)
                      .toList() ??
                  [],
              stats: newStats,
              todayBookings: newBookings,
              date: displayDate,
              month: displayMonth,
              isAllArenas: false,
              arenas: _cachedArenas,
              previousMonthGraphics:
                  (res['data']['previousMonthGraphic'] as List<dynamic>?)
                      ?.map((e) => e as Map<String, dynamic>)
                      .toList() ??
                  [],
            ),
          );
          log('✅ Initial state emitted');
        }
      } else {
        log('❌ Response success is false or null');
        throw Exception(res?['message'] ?? 'Неизвестная ошибка загрузки');
      }
    } catch (e, stackTrace) {
      log('❌ Dashboard load for date error: $e');
      log('❌ Stack trace: $stackTrace');
      emit(
        DashboardError(
          message: 'Ошибка загрузки данных: $e',
          arenas: _cachedArenas,
        ),
      );
    }
  }
}
