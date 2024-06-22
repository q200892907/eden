import 'package:eden_service/eden_service.dart';

abstract class EdenBaseService {
  void initService() {
    EdenService.addService(this);
  }
}
