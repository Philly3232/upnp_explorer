import 'package:injectable/injectable.dart';

import '../../domain/device/service_repository_type.dart';
import '../../infrastructure/upnp/models/service_description.dart';

@named
@LazySingleton(as: ServiceRepositoryType)
class ServiceRepository extends ServiceRepositoryType {
  Map<String, ServiceDescription> services = {};
  @override
  ServiceDescription? get(String id) {
    if (!services.containsKey(id)) {
      return null;
    }

    return services[id];
  }

  @override
  bool has(String id) {
    return services.containsKey(id);
  }

  @override
  void insert(String id, ServiceDescription service) {
    services[id] = service;
  }
}
