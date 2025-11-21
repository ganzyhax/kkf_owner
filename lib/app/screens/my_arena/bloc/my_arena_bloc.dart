// lib/app/screens/my_arena/bloc/my_arena_bloc.dart

import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:kff_owner_admin/app/api/api.dart';
import 'package:meta/meta.dart';

part 'my_arena_event.dart';
part 'my_arena_state.dart';

class MyArenaBloc extends Bloc<MyArenaEvent, MyArenaState> {
  MyArenaBloc() : super(MyArenaInitial()) {
    // ==================== ЗАГРУЗИТЬ АРЕНЫ ====================
    on<MyArenaLoad>((event, emit) async {
      try {
        emit(MyArenaLoading());

        var res = await ApiClient.get('api/arenas/owner/my');
        log('Owner arenas response: $res');

        if (res['success']) {
          final responseData = res['data'] as Map<String, dynamic>;
          final arenaList = responseData['arenas'] as List<dynamic>;

          // Преобразуем в List<Map<String, dynamic>>
          final List<Map<String, dynamic>> arenas = arenaList
              .map((e) => e as Map<String, dynamic>)
              .toList();

          emit(MyArenaLoaded(arenas: arenas));
        } else {
          emit(MyArenaError(message: 'Failed to load arenas'));
        }
      } catch (e, stackTrace) {
        log('Error loading arenas: $e');
        log('Stack: $stackTrace');
        emit(MyArenaError(message: e.toString()));
      }
    });

    // ==================== СОЗДАТЬ АРЕНУ ====================
    on<MyArenaCreate>((event, emit) async {
      try {
        emit(MyArenaLoading());

        final body = {
          'name': event.name,
          'city': event.city,
          'address': event.address,
          'description': event.description,
          'gisLink': event.gisLink,
          'length': event.length,
          'width': event.width,
          'height': event.height,
          'isCovered': event.isCovered,
          'typeGrass': event.typeGrass,
          'playersCount': event.playersCount,
          'amenities': {
            'hasShower': event.amenityIds.contains('shower'),
            'hasLockerRoom': event.amenityIds.contains('lockerRoom'),
            'hasStands': event.amenityIds.contains('stands'),
            'hasLighting': event.amenityIds.contains('lighting'),
            'hasFreeParking': event.amenityIds.contains('freeParking'),
          },
          'photos': event.photoUrls,
          'prices': event.prices,
        };

        log('Creating arena: $body');

        var res = await ApiClient.post('api/arenas/owner', body);
        log('Create response: $res');

        if (res['success']) {
          emit(MyArenaSuccess(message: 'Арена создана!'));
          add(MyArenaLoad());
        } else {
          emit(MyArenaError(message: res['message'] ?? 'Ошибка создания'));
        }
      } catch (e) {
        log('Error creating arena: $e');
        emit(MyArenaError(message: e.toString()));
      }
    });

    // ==================== ОБНОВИТЬ АРЕНУ ====================
    on<MyArenaUpdate>((event, emit) async {
      try {
        emit(MyArenaLoading());

        final body = {
          'name': event.name,
          'city': event.city,
          'address': event.address,
          'description': event.description,
          'gisLink': event.gisLink,
          'length': event.length,
          'width': event.width,
          'height': event.height,
          'isCovered': event.isCovered,
          'typeGrass': event.typeGrass,
          'playersCount': event.playersCount,
          'amenities': {
            'hasShower': event.amenityIds.contains('shower'),
            'hasLockerRoom': event.amenityIds.contains('lockerRoom'),
            'hasStands': event.amenityIds.contains('stands'),
            'hasLighting': event.amenityIds.contains('lighting'),
            'hasFreeParking': event.amenityIds.contains('freeParking'),
          },
          'photos': event.photoUrls,
          'prices': event.prices,
        };

        log('Updating arena: $body');

        var res = await ApiClient.put(
          'api/arenas/owner/${event.arenaId}',
          body,
        );
        log('Update response: $res');

        if (res['success']) {
          emit(MyArenaSuccess(message: 'Арена обновлена!'));
          add(MyArenaLoad());
        } else {
          emit(MyArenaError(message: res['message'] ?? 'Ошибка обновления'));
        }
      } catch (e) {
        log('Error updating arena: $e');
        emit(MyArenaError(message: e.toString()));
      }
    });

    // ==================== УДАЛИТЬ АРЕНУ ====================
    on<MyArenaDelete>((event, emit) async {
      try {
        emit(MyArenaLoading());

        var res = await ApiClient.delete('api/arenas/owner/${event.arenaId}');
        log('Delete response: $res');

        if (res['success']) {
          emit(MyArenaSuccess(message: 'Арена удалена!'));
          add(MyArenaLoad());
        } else {
          emit(MyArenaError(message: res['message'] ?? 'Ошибка удаления'));
        }
      } catch (e) {
        log('Error deleting arena: $e');
        emit(MyArenaError(message: e.toString()));
      }
    });
  }
}
