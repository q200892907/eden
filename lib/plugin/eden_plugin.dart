import 'dart:async';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:eden/config/eden_config.dart';
import 'package:eden/develop/custom/dio/lib/network_logger.dart';
import 'package:eden_internet_connection_checker/eden_internet_connection_checker.dart';
import 'package:eden_intl/eden_intl.dart';
import 'package:eden_logger/eden_logger.dart';
import 'package:eden_service/eden_service.dart';
import 'package:eden_uikit/eden_uikit.dart';

/// 相关插件初始化
class EdenPlugin {
  // 工厂模式
  factory EdenPlugin() => _getInstance();

  EdenPlugin._internal();

  static EdenPlugin get instance => _getInstance();
  static EdenPlugin? _instance;

  static EdenPlugin _getInstance() {
    _instance ??= EdenPlugin._internal();
    return _instance!;
  }

  /// 真实初始化
  Future<bool> init() async {
    EdenImage.initCacheManager(
      CacheManager(
        Config(
          EdenImage.key,
          stalePeriod: const Duration(days: 90),
          maxNrOfCacheObjects: 2000,
        ),
      ),
    );
    // 初始化打印工具
    EdenLogger.init();
    // 初始化环境信息
    EdenServerConfig.initServer(
      envType: EdenConfig.instance.envType,
      log: EdenConfig.isDebug,
    );
    // 初始化网络工具库
    _initEdenHttp();
    _initInternetConnection();
    // 初始化sp
    await EdenSpUtil.getInstance();
    EdenLogFile.init().then((value) {
      EdenLogFile.removeDirectoriesOlderThanDays();
    });
    EdenPermissionUtil.showTips = (tips) {
      EdenToast.show(tips);
    };
    return Future.value(true);
  }

  // 初始化网络检测
  void _initInternetConnection() {
    EdenInternetConnection.instance.init(checkOptions: [
      InternetCheckOption(
        uri: Uri.parse(EdenServerConfig.server.apiUrl),
        timeout: const Duration(seconds: 30),
        responseStatusFn: EdenInternetConnection.responseStatusFn,
      ),
    ]);
  }

  /// 初始化三方插件, 需同意协议后调用
  void initTripartitePlugin() {}

  // 配置网络库
  void _initEdenHttp() {
    //设置拦截器
    tokenDioInterceptors = [
      EdenDioNetworkLogger(),
    ];
    EdenApi.dio.interceptors.addAll(
      [
        EdenHeaderInterceptor(),
        EdenDioNetworkLogger(),
        CookieManager(CookieJar()),
      ],
    );
  }

  void initHttpMessage() {
    EdenApi.init(
      message: EdenStrings.current.httpTimeout,
      onApiCodeMessage: (code) {
        if (code == '0') {
          return '';
        }
        Map<String, String> codeTips = {};
        return codeTips[code.toString()] ??
            EdenStrings.current.httpCodeError(code);
      },
      onApiParamsErrorMessage: () => EdenStrings.current.httpParamsError,
      onApiParseFailedMessage: () => EdenStrings.current.httpParseError,
      onApiHttpErrorMessage: (httpCode) {
        return EdenStrings.current.httpCodeError(httpCode);
      },
      onApiDioErrorMessage: (error) {
        if (error is SocketException) {
          return EdenStrings.current.httpTimeout; //'网络异常.请检查你的网络.';
        } else if (error is HttpException) {
          return EdenStrings.current.httpTimeout; //'服务器异常.请稍后重试.';
        } else if (error is FormatException) {
          return EdenStrings.current.httpParseError;
        } else if (error is TimeoutException) {
          return EdenStrings.current.httpTimeout; //'连接超时.请稍后重试.';
        }
        return EdenStrings.current.httpTimeout; //'dio异常';
      },
    );
  }
}
