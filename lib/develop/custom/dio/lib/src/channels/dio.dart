import 'package:dio/dio.dart' as dio;

import '../network_event.dart';
import '../network_logger.dart';

class EdenDioNetworkLogger extends dio.Interceptor {
  final NetworkEventList eventList;
  final _requests = <dio.RequestOptions, NetworkEvent>{};

  EdenDioNetworkLogger({NetworkEventList? eventList})
      : eventList = eventList ?? NetworkLogger.instance;

  @override
  Future<void> onRequest(
      dio.RequestOptions options, dio.RequestInterceptorHandler handler) async {
    super.onRequest(options, handler);
    eventList.add(_requests[options] = NetworkEvent.now(
      request: options.toRequest(),
      error: null,
      response: null,
    ));
    return Future.value();
  }

  @override
  void onResponse(
    dio.Response response,
    dio.ResponseInterceptorHandler handler,
  ) {
    super.onResponse(response, handler);
    final event = _requests.remove(response.requestOptions);
    if (event != null) {
      eventList.updated(
        event
          ..response = response.toResponse()
          ..completedTimestamp = DateTime.now(),
      );
    } else {
      eventList.add(
        NetworkEvent.now(
          request: response.requestOptions.toRequest(),
          response: response.toResponse(),
        )..completedTimestamp = DateTime.now(),
      );
    }
  }

  @override
  void onError(dio.DioException err, dio.ErrorInterceptorHandler handler) {
    super.onError(err, handler);
    var event = _requests[err.requestOptions];
    if (event != null) {
      _requests.remove(err.requestOptions);
      eventList.updated(
        event
          ..error = err.toNetworkError()
          ..response = err.response?.toResponse()
          ..completedTimestamp = DateTime.now(),
      );
    } else {
      eventList.add(
        NetworkEvent.now(
          request: err.requestOptions.toRequest(),
          response: err.response?.toResponse(),
          error: err.toNetworkError(),
        )..completedTimestamp = DateTime.now(),
      );
    }
  }
}

extension _RequestOptionsX on dio.RequestOptions {
  Request toRequest() => Request(
        uri: uri.toString(),
        data: data,
        method: method,
        headers: Headers(headers.entries.map(
          (kv) => MapEntry(kv.key, '${kv.value}'),
        )),
      );
}

extension _ResponseX on dio.Response {
  Response toResponse() => Response(
        data: data,
        statusCode: statusCode ?? -1,
        statusMessage: statusMessage ?? 'unknown',
        headers: Headers(
          headers.map.entries.fold<List<MapEntry<String, String>>>(
            [],
            (p, e) => p..addAll(e.value.map((v) => MapEntry(e.key, v))),
          ),
        ),
      );
}

extension _DioErrorX on dio.DioException {
  NetworkError toNetworkError() => NetworkError(message: toString());
}
