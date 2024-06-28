import 'dart:async';
import 'dart:io';

import 'package:eden/config/eden_config.dart';
import 'package:eden/plugin/eden_plugin.dart';
import 'package:eden_logger/eden_logger.dart';
import 'package:eden_uikit/eden_uikit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'develop/custom/error/eden_error_tool.dart';
import 'eden_app.dart';
import 'uikit/error/eden_flutter_error_view.dart';

final RouteObserver<PageRoute<dynamic>> routeObserver =
    RouteObserver<PageRoute<dynamic>>();

class MyHttpOverrides extends HttpOverrides {
  final String proxyIp;

  MyHttpOverrides([this.proxyIp = '']);

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    HttpClient client = super.createHttpClient(context);
    client.maxConnectionsPerHost = 20;
    if (proxyIp.isNotEmpty) {
      client.findProxy = (uri) {
        //proxy all request to localhost:8888
        return 'PROXY $proxyIp';
      };
    }
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return client;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();

  // 初始化应用配置
  await EdenConfig.instance.init();

  // 设置方向
  await EdenDevice.init();

  // 初始化插件相关配置
  await EdenPlugin.instance.init();

  if (Platform.isAndroid) {
    // 设置Android头部的导航栏透明
    const SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.black,
    );
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }

  final themeMode = await EdenThemeBuilder.getThemeMode();

  // 捕获Flutter framework异常.
  FlutterError.onError = (FlutterErrorDetails details) async {
    EdenErrorLogger.instance.add(details);
    Zone.current.handleUncaughtError(details.exception, details.stack!);
  };

  // 自定义错误页面，仅在非debug模式添加
  if (!EdenConfig.isDebug) {
    ErrorWidget.builder = (FlutterErrorDetails flutterErrorDetails) {
      EdenLogger.e(flutterErrorDetails.toString());
      return EdenFlutterErrorView(errorDetails: flutterErrorDetails);
    };
  }
  runApp(
    ProviderScope(
      observers: [
        EdenRiverpodLogger(isDebug: EdenConfig.isDebug),
      ],
      child: InheritedConsumer(
        child: EdenApp(
          themeMode: themeMode,
        ),
      ),
    ),
  );
}
