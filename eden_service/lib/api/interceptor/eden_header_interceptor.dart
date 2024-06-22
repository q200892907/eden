import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:eden_database/eden_database.dart';
import 'package:eden_logger/eden_logger.dart';
import 'package:eden_service/eden_service.dart';

List<Interceptor> tokenDioInterceptors = [];
Completer<EdenObxAccount?>? _completer; //全局统一一个
DateTime? _updateTime;

/// 头部拦截器
class EdenHeaderInterceptor extends Interceptor {
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // 头部拦截
    final Map<String, dynamic> headers = options.headers;
    if (EdenAccountService.instance.isLogin) {
      headers['Authorization'] =
          'Bearer ${EdenAccountService.instance.account?.accessToken}';
    }
    return super.onRequest(options, handler);
  }

  @override
  Future<void> onResponse(
      Response response, ResponseInterceptorHandler handler) async {
    response = (await _handleResponse(response, handler))!;
    super.onResponse(response, handler);
  }

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    final Response<dynamic>? response = err.response;
    final Response<dynamic>? newResponse =
        await _handleResponse(response, handler);
    if (newResponse != null && newResponse.statusCode == 200) {
      return handler.resolve(newResponse);
    } else {
      if (err.response?.statusCode == 401 || err.response?.statusCode == 403) {
        EdenApi.send(EdenApiEventType.tokenError);
      }
      return super.onError(err, handler);
    }
  }

  Future<Response<dynamic>?> _handleResponse(
      Response<dynamic>? response, dynamic handler) async {
    try {
      if (response == null) {
        return response;
      }

      if (response.statusCode == 401 && EdenAccountService.instance.isLogin) {
        EdenLogger.e('token过期，重新获取');
        _writeLog('token过期，重新获取');
        final EdenObxAccount? user = await getToken(); //异步获取新的accessToken
        if (user != null) {
          _writeLog('重新获取token成功，更新用户');
          EdenLogger.d('重新获取token成功，更新用户');
          //更新
          EdenAccountService.instance.updateAccount(user);
        }
        if (user?.accessToken.isNotEmpty ?? false) {
          final RequestOptions request =
              response.requestOptions; //千万不要调用 err.request
          request.headers['Authorization'] = 'Bearer ${user?.accessToken}';
          String path = request.path;
          Uri uri = Uri.parse(path);
          final Map<String, String> queryParameters = uri.queryParameters;
          if (queryParameters.containsKey('Authorization')) {
            final Map<String, String> params = <String, String>{};
            params.addAll(queryParameters);
            params['Authorization'] = 'Bearer ${user?.accessToken}';
            uri = uri.replace(queryParameters: params);
          }
          path = uri.toString();
          final Dio requestDio = Dio(); //创建新的Dio实例
          final Response<dynamic> resultResponse = await requestDio.request(
            path,
            data: request.data,
            queryParameters: request.queryParameters,
            cancelToken: request.cancelToken,
            options: Options(
              method: response.requestOptions.method,
              sendTimeout: response.requestOptions.sendTimeout,
              receiveTimeout: response.requestOptions.receiveTimeout,
              extra: response.requestOptions.extra,
              headers: response.requestOptions.headers,
              responseType: response.requestOptions.responseType,
              contentType: response.requestOptions.contentType,
              validateStatus: response.requestOptions.validateStatus,
              receiveDataWhenStatusError:
                  response.requestOptions.receiveDataWhenStatusError,
              followRedirects: response.requestOptions.followRedirects,
              maxRedirects: response.requestOptions.maxRedirects,
              requestEncoder: response.requestOptions.requestEncoder,
              responseDecoder: response.requestOptions.responseDecoder,
              listFormat: response.requestOptions.listFormat,
            ),
            onReceiveProgress: request.onReceiveProgress,
            onSendProgress: request.onSendProgress,
          );
          return resultResponse;
        }
      }
      return response;
    } catch (e) {
      return response;
    }
  }

  _writeLog(String info) {
    EdenLogger.e(info);
  }

  Future<EdenObxAccount?> getToken() {
    final String refreshToken =
        EdenAccountService.instance.account?.refreshToken ?? '';
    if (_updateTime != null) {
      if ((_updateTime?.add(const Duration(days: 1)).millisecondsSinceEpoch ??
              0) >
          DateTime.now().millisecondsSinceEpoch) {
        EdenServiceState<EdenObxAccount?> account =
            EdenAccountService.instance.getCurrentAccount();
        return Future.value(account.data);
      }
    }
    if (refreshToken.isEmpty) {
      _writeLog('获取token,用户信息为空');
      return Future.value(null);
    }
    if (_completer != null) {
      _writeLog('已调用过，正在获取中');
      return _completer!.future;
    }
    _completer = Completer<EdenObxAccount?>();
    final Dio tokenDio = Dio(); //创建新的Dio实例
    tokenDio.interceptors.addAll(tokenDioInterceptors);
    try {
      //todo 接口地址
      tokenDio.post(
        EdenServerConfig.server.apiUrl,
        data: <String, String>{'refreshToken': refreshToken},
      ).then((Response<dynamic> response) async {
        final String code = getCode(response);
        _writeLog(response.toString());
        if (code == kSuccess) {
          final dynamic map = getResponseMap(response);
          if (map != null && map is Map && map.containsKey(kData)) {
            final EdenObxAccount user = EdenObxAccount.fromJson(map[kData]);
            _completer?.complete(user);
            _updateTime = DateTime.now();
            _completer = null;
          } else {
            _completer?.complete(null);
            _completer = null;
          }
        } else {
          _completer?.complete(null);
          _completer = null;
        }
      }).catchError((_) {
        _writeLog(_.toString());
        _completer?.complete(null);
        _completer = null;
      });
    } catch (_) {
      _writeLog(_.toString());
      _completer?.complete(null);
      _completer = null;
    }
    return _completer?.future ?? Future.value(null);
  }

  String getCode(Response<dynamic> response) {
    final dynamic map = getResponseMap(response);
    if (map != null && map is Map && map.containsKey(kCode)) {
      return map[kCode].toString();
    }
    return '';
  }

  dynamic getResponseMap(Response<dynamic> response) {
    final dynamic data = response.data;
    dynamic map;
    if (data is String) {
      map = jsonDecode(data);
    } else {
      map = data;
    }
    return map;
  }
}
