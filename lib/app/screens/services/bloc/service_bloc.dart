import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:kff_owner_admin/app/api/api.dart';
import 'package:kff_owner_admin/app/models/service_model.dart';

import 'service_event.dart';
import 'service_state.dart';

class ServiceBloc extends Bloc<ServiceEvent, ServiceState> {
  ServiceBloc() : super(ServiceInitial()) {
    on<LoadServices>((event, emit) async {
      try {
        emit(ServiceLoading());
        
        var res = await ApiClient.get('api/services/owner/all');
        log('Load services response: $res');
        
        if (res['success'] == true) {
          final List<dynamic> data = res['data']['services'] ?? [];
          final services = data.map((json) => ServiceModel.fromJson(json)).toList();
          emit(ServicesLoaded(services));
        } else {
          emit(ServiceError(res['message'] ?? 'Ошибка загрузки услуг'));
        }
      } catch (e) {
        log('Error loading services: $e');
        emit(ServiceError(e.toString()));
      }
    });

    on<CreateService>((event, emit) async {
      try {
        emit(ServiceLoading());
        
        var res = await ApiClient.post('api/services', event.serviceData);
        log('Create service response: $res');
        
        if (res['success'] == true) {
          emit(ServiceOperationSuccess('Услуга успешно создана'));
          add(LoadServices()); // Перезагружаем список
        } else {
          emit(ServiceError(res['message'] ?? 'Ошибка создания услуги'));
          add(LoadServices()); // Возвращаем список
        }
      } catch (e) {
        log('Error creating service: $e');
        emit(ServiceError(e.toString()));
        add(LoadServices());
      }
    });

    on<UpdateService>((event, emit) async {
      try {
        emit(ServiceLoading());
        
        var res = await ApiClient.put('api/services/${event.id}', event.serviceData);
        log('Update service response: $res');
        
        if (res['success'] == true) {
          emit(ServiceOperationSuccess('Услуга успешно обновлена'));
          add(LoadServices());
        } else {
          emit(ServiceError(res['message'] ?? 'Ошибка обновления услуги'));
          add(LoadServices());
        }
      } catch (e) {
        log('Error updating service: $e');
        emit(ServiceError(e.toString()));
        add(LoadServices());
      }
    });

    on<DeleteService>((event, emit) async {
      try {
        emit(ServiceLoading());
        
        var res = await ApiClient.delete('api/services/${event.id}');
        log('Delete service response: $res');
        
        if (res['success'] == true) {
          emit(ServiceOperationSuccess('Услуга успешно удалена'));
          add(LoadServices());
        } else {
          emit(ServiceError(res['data']['message'] ?? 'Ошибка удаления услуги'));
          add(LoadServices());
        }
      } catch (e) {
        log('Error deleting service: $e');
        emit(ServiceError(e.toString()));
        add(LoadServices());
      }
    });
  }
}
