import 'eden_server.dart';

class EdenDevServer extends EdenServer {
  @override
  String get apiUrl => '';

  @override
  String get objectbox => 'eden_objectbox_dev';
}

/// 测试环境默认配置
class EdenStageServer extends EdenServer {
  @override
  String get apiUrl => '';

  @override
  String get objectbox => 'eden_objectbox_stage';
}

/// 正式环境默认配置
class EdenReleaseServer extends EdenServer {
  @override
  String get apiUrl => '';

  @override
  String get objectbox => 'eden_objectbox';
}
