import 'package:eden_logger/eden_logger.dart';
import 'package:eden_service/eden_service.dart';
import 'package:flutter/services.dart';

import 'eden_version.dart';

/// eden 配置，主要读取.config对应文件
class EdenConfig {
  // 工厂模式
  factory EdenConfig() => _getInstance();

  EdenConfig._internal() {
    _env = const String.fromEnvironment("ENV", defaultValue: _dev);
    channel = const String.fromEnvironment("APP_CHANNEL", defaultValue: '');
  }

  static const String _tag = 'EdenConfig';

  static EdenConfig get instance => _getInstance();
  static EdenConfig? _instance;

  static const String _dev = 'dev';
  static const String _stage = 'stage';
  static const String _release = 'release';

  static EdenConfig _getInstance() {
    _instance ??= EdenConfig._internal();
    return _instance!;
  }

  /// --------------------------------- 固定配置 ---------------------------------------
  /// debug开关，上线需要关闭
  /// App运行在Release环境时，isDebug为false；当App运行在Debug和Profile环境时，isDebug为true
  static const bool isDebug = !bool.fromEnvironment("dart.vm.product");

  String get logTag => appName;

  /// --------------------------------- 动态配置 ---------------------------------------
  late String _env; // 环境配置

  // 测试使用
  late Map<String, dynamic> _envConfigs;

  List<MapEntry<String, dynamic>> get envConfigs =>
      _envConfigs.entries.toList();

  bool get isDevelopEnv => EdenServerConfig.envType == EdenEnvType.dev;

  bool get isStageEnv => EdenServerConfig.envType == EdenEnvType.stage;

  bool get isReleaseEnv => EdenServerConfig.envType == EdenEnvType.release;

  EdenEnvType get envType {
    EdenEnvType envType = EdenEnvType.release;
    if (_env == _dev) {
      envType = EdenEnvType.dev;
    } else if (_env == _stage) {
      envType = EdenEnvType.stage;
    } else if (_env == _release) {
      envType = EdenEnvType.release;
    }
    return envType;
  }

  String appName = 'Eden'; // app名称

  // 渠道名
  late String channel;

  // 初始化环境配置
  Future init() async {
    Map<String, dynamic> configs = {};
    String value = await rootBundle.loadString(_getEnvFile());
    value = value.replaceAll('\r', ''); //解决windows系统换行符问题
    List<String> list = value.split("\n");
    for (var element in list) {
      if (element.contains("=")) {
        String key = element.substring(0, element.indexOf("="));
        String value = element.substring(element.indexOf("=") + 1);
        configs[key] = value;
      }
    }
    _log(configs);
    _parserConfig(configs);
    return Future.value();
  }

  void _log(Map msg) {
    if (_env != _release) {
      String msgStr = '';
      msg.forEach((key, value) {
        msgStr += '$key:$value\n';
      });
      EdenLogger.d('--------------------$_tag--------------------\n'
          '编译时间：${DateTime.fromMillisecondsSinceEpoch(EdenVersion.publishTime).toString()}\n'
          '-------------------环境配置内容--------------------\n'
          '$msgStr'
          '--------------------$_tag--------------------\n');
    }
  }

  // 获取环境配置文件
  String _getEnvFile() {
    if (_env == _dev) {
      return 'assets/config/.env.dev';
    } else if (_env == _stage) {
      return 'assets/config/.env.stage';
    } else if (_env == _release) {
      return 'assets/config/.env.release';
    }
    return 'assets/config/.env.dev';
  }

  String _wipeOffPrefix(String value, String prefix) {
    return value.replaceAll(prefix, '');
  }

  void _parserConfig(Map<String, dynamic> configs) {
    _envConfigs = configs;
    _env = configs['ENV'];
    appName = configs['APP_NAME'];
  }
}
