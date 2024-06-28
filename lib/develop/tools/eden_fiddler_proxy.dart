import 'dart:io';

import 'package:dio/src/adapters/io_adapter.dart';
import 'package:eden/main.dart';
import 'package:eden_service/eden_service.dart';

///
/// 抓包代理
///
class EdenFiddlerProxy {
  /// 设置代理
  /// [clientIp] 设备IP地址
  static void setFiddlerProxy(String clientIp) {
    /// Fiddler抓包代理配置 https://www.jianshu.com/p/d831b1f7c45b
    EdenApi.dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        HttpClient client = HttpClient();
        client.findProxy = (uri) {
          //proxy all request to localhost:8888
          return 'PROXY $clientIp';
        };
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      },
      validateCertificate: (X509Certificate? cert, String host, int port) =>
          true,
    );
    HttpOverrides.global = MyHttpOverrides(clientIp);
  }
}
