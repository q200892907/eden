import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:eden_logger/eden_logger.dart';
import 'package:eden_service/api/eden_api.dart';
import 'package:eden_service/config/eden_server_config.dart';
import 'package:json_annotation/json_annotation.dart';

part 'eden_api_response.g.dart';

const String kCode = 'code';
const String kData = 'data';
const String kMsg = 'msg';
const String kSuccess = '0';

@JsonSerializable(
  fieldRename: FieldRename.snake,
  explicitToJson: true,
  genericArgumentFactories: true,
)
class EdenApiResponse<T> {
  EdenApiResponse({
    required this.msg,
    required this.code,
    this.data,
  });

  final String? msg;
  final int code;
  final T? data;

  bool get isSuccess => code == 0;

  String get message => EdenApi.apiCodeMessage(code.toString());

  factory EdenApiResponse.fromJson(
          Map<String, dynamic> json, T Function(Object?) fromJsonT) =>
      _$EdenApiResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T) toJsonT) =>
      _$EdenApiResponseToJson(this, toJsonT);

  @override
  String toString() {
    return 'EdenApiResponse{msg: $msg, code: $code, data: $data}';
  }
}

class EdenServiceState<T> {
  final bool isSuccess;
  final String? message;
  final T? data;

  final int? code;

  EdenServiceState({
    required this.isSuccess,
    this.message,
    this.data,
    this.code,
  });

  @override
  String toString() {
    return 'EdenServiceState{isSuccess: $isSuccess, message: $message, data: $data}';
  }
}

extension EdenApiResponseExt<T> on EdenApiResponse<T> {
  EdenServiceState<T> get serviceState {
    return EdenServiceState<T>(
      isSuccess: isSuccess,
      message: message,
      data: data,
      code: code,
    );
  }
}

EdenServiceState<T> _apiError<T>(dynamic error) {
  EdenLogger.e(error.toString());
  String errorMsg = EdenApi.defaultMessage;
  int? errorCode;
  if (error is DioException) {
    try {
      int? statusCode = error.response?.statusCode;
      if (statusCode != null && (statusCode >= 500 || statusCode == 404)) {
        errorMsg = EdenApi.apiHttpErrorMessage(statusCode);
      } else {
        dynamic data = error.response?.data;
        if (data != null) {
          if (data is String) {
            data = jsonDecode(data);
          }
          var code = data['code']?.toString() ?? '1';
          var msg = data['msg']?.toString() ?? '';
          try {
            errorCode = int.parse(code);
          } catch (_) {}
          errorMsg = EdenApi.apiCodeMessage(code) +
              (EdenServerConfig.isRelease
                  ? ''
                  : (msg.isNotEmpty ? '($msg)' : ''));
        } else {
          if (statusCode != null) {
            errorMsg = EdenApi.apiHttpErrorMessage(statusCode);
          }
        }
      }
    } catch (e) {
      errorMsg = EdenApi.apiDioErrorMessage(e);
    }
  } else {
    errorMsg = EdenApi.apiDioErrorMessage(error);
  }
  EdenLogger.e(errorMsg);
  return EdenServiceState<T>(
    isSuccess: false,
    message: errorMsg,
    code: errorCode,
  );
}

extension FutureExtension<T> on Future<EdenApiResponse<T>> {
  Future<EdenServiceState<T>> convert(
      {Function(T?)? onSuccess, Function(String?)? onError}) {
    return then((value) {
      if (value.isSuccess) {
        onSuccess?.call(value.data);
      } else {
        onError?.call(value.message);
      }
      return value.serviceState;
    }).catchError((e) {
      EdenServiceState<T> error = _apiError<T>(e);
      onError?.call(error.message);
      return error;
    });
  }
}
