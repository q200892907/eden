library eden_service;

import 'package:eden_service/service/eden_base_service.dart';

export 'api/eden_api.dart';
export 'config/eden_server_config.dart';
export 'service/eden_account_service.dart';

class EdenService {
  static final Set<EdenBaseService> _services = {};

  static void addService(EdenBaseService service) {
    _services.add(service);
  }

  static void resetService() {
    for (var service in _services) {
      service.initService();
    }
  }
}
