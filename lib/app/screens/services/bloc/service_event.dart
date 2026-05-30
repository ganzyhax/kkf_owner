import 'package:flutter/foundation.dart';
import 'package:kff_owner_admin/app/models/service_model.dart';

@immutable
abstract class ServiceEvent {}

class LoadServices extends ServiceEvent {}

class CreateService extends ServiceEvent {
  final Map<String, dynamic> serviceData;
  CreateService(this.serviceData);
}

class UpdateService extends ServiceEvent {
  final String id;
  final Map<String, dynamic> serviceData;
  UpdateService(this.id, this.serviceData);
}

class DeleteService extends ServiceEvent {
  final String id;
  DeleteService(this.id);
}
