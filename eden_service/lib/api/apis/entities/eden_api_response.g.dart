// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'eden_api_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EdenApiResponse<T> _$EdenApiResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    EdenApiResponse<T>(
      msg: json['msg'] as String?,
      code: (json['code'] as num).toInt(),
      data: _$nullableGenericFromJson(json['data'], fromJsonT),
    );

Map<String, dynamic> _$EdenApiResponseToJson<T>(
  EdenApiResponse<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'msg': instance.msg,
      'code': instance.code,
      'data': _$nullableGenericToJson(instance.data, toJsonT),
    };

T? _$nullableGenericFromJson<T>(
  Object? input,
  T Function(Object? json) fromJson,
) =>
    input == null ? null : fromJson(input);

Object? _$nullableGenericToJson<T>(
  T? input,
  Object? Function(T value) toJson,
) =>
    input == null ? null : toJson(input);
