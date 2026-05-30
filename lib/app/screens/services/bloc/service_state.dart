import 'package:flutter/foundation.dart';
import 'package:kff_owner_admin/app/models/service_model.dart';

@immutable
abstract class ServiceState {}

class ServiceInitial extends ServiceState {}

class ServiceLoading extends ServiceState {}

class ServicesLoaded extends ServiceState {
  final List<ServiceModel> services;
  ServicesLoaded(this.services);
}

class ServiceOperationSuccess extends ServiceState {
  final String message;
  ServiceOperationSuccess(this.message);
}

class ServiceError extends ServiceState {
  final String message;
  ServiceError(this.message);
}
