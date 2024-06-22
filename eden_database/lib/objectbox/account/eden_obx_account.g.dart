// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'eden_obx_account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EdenObxAccountImpl _$$EdenObxAccountImplFromJson(Map<String, dynamic> json) =>
    _$EdenObxAccountImpl(
      localId: (json['localId'] as num?)?.toInt() ?? 0,
      id: json['id'] as String,
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
      isLogin: json['isLogin'] as bool? ?? true,
    );

Map<String, dynamic> _$$EdenObxAccountImplToJson(
        _$EdenObxAccountImpl instance) =>
    <String, dynamic>{
      'localId': instance.localId,
      'id': instance.id,
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'isLogin': instance.isLogin,
    };
