import 'dart:collection';

import 'package:dio/dio.dart' as d;
import 'package:flutter/services.dart';

export 'apis/entities/api_entity.dart';
export 'apis/user/eden_user_client.dart';
export 'interceptor/eden_header_interceptor.dart';

typedef OnApiCodeMessage = String Function(String code);
typedef OnApiParamsErrorMessage = String Function();
typedef OnApiParseFailedMessage = String Function();
typedef OnApiHttpErrorMessage = String Function(int httpCode);
typedef OnApiDioErrorMessage = String Function(dynamic dioError);

enum EdenApiEventType {
  tokenError,
}

class EdenApi {
  static late String defaultMessage;
  static late OnApiCodeMessage apiCodeMessage;
  static late OnApiParamsErrorMessage apiParamsErrorMessage;
  static late OnApiParseFailedMessage apiParseFailedMessage;
  static late OnApiHttpErrorMessage apiHttpErrorMessage;
  static late OnApiDioErrorMessage apiDioErrorMessage;

  /// api发送异常
  static final HashMap<EdenApiEventType, ValueChanged<dynamic>> _listeners =
      HashMap();

  static void addListener(
    EdenApiEventType type,
    ValueChanged<dynamic> listener,
  ) {
    _listeners.putIfAbsent(type, () => listener);
  }

  static void removeListener(EdenApiEventType type) {
    _listeners.removeWhere((key, value) => key == type);
  }

  static void send(EdenApiEventType type, [dynamic data]) {
    _listeners[type]?.call(data);
  }

  static final d.Dio _dio = d.Dio(
    d.BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      contentType: 'application/json;charset=UTF-8',
      responseType: d.ResponseType.plain,
    ),
  );

  static d.Dio get dio => _dio;

  static void init({
    required String message, //默认提示信息
    required OnApiCodeMessage onApiCodeMessage,
    required OnApiParamsErrorMessage onApiParamsErrorMessage,
    required OnApiParseFailedMessage onApiParseFailedMessage,
    required OnApiHttpErrorMessage onApiHttpErrorMessage,
    required OnApiDioErrorMessage onApiDioErrorMessage,
  }) {
    apiHttpErrorMessage = onApiHttpErrorMessage;
    apiParseFailedMessage = onApiParseFailedMessage;
    apiParamsErrorMessage = onApiParamsErrorMessage;
    apiDioErrorMessage = onApiDioErrorMessage;
    apiCodeMessage = onApiCodeMessage;
    defaultMessage = message;
  }
}
