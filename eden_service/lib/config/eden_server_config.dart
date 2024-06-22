import 'package:eden_logger/eden_logger.dart';

import 'eden_default_server.dart';
import 'eden_server.dart';

export 'eden_default_server.dart';
export 'eden_server.dart';

enum EdenEnvType {
  dev,
  stage,
  release,
}

class EdenServerConfig {
  static late EdenServer _server;
  static late EdenEnvType _envType;

  /// 获取当前环境配置
  static EdenServer get server => _server;

  /// 获取当前环境类型
  static EdenEnvType get envType => _envType;

  static final EdenServer _devServer = EdenDevServer();
  static final EdenServer _stageServer = EdenStageServer();
  static final EdenServer _releaseServer = EdenReleaseServer();

  static bool get isRelease => _envType == EdenEnvType.release;

  /// 初始化服务器配置信息
  ///
  /// [envType] 环境类型
  /// [server] 环境配置，不传则使用默认配置
  /// [log] 是否打印环境配置
  static initServer({
    required EdenEnvType envType,
    EdenServer? server,
    bool log = false,
  }) {
    _envType = envType;
    if (server != null) {
      _server = server;
    } else {
      switch (envType) {
        case EdenEnvType.dev:
          _server = _devServer;
          break;
        case EdenEnvType.stage:
          _server = _stageServer;
          break;
        case EdenEnvType.release:
          _server = _releaseServer;
          break;
      }
    }
    if (log) {
      EdenLogger.d('--------ZhiyaServerConfig-------\n'
          'envType: $_envType\n${_server.toString()}');
    }
  }
}
