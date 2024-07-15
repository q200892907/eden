// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'toy_command_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ToyCommandEntity _$ToyCommandEntityFromJson(Map<String, dynamic> json) =>
    ToyCommandEntity(
      (json['unit'] as List<dynamic>?)
              ?.map((e) =>
                  ToyVibrationCommandEntity.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      (json['repeat'] as num?)?.toInt() ?? 1,
      json['is_toy'] as bool? ?? true,
    );

Map<String, dynamic> _$ToyCommandEntityToJson(ToyCommandEntity instance) =>
    <String, dynamic>{
      'repeat': instance.repeat,
      'unit': instance.unit.map((e) => e.toJson()).toList(),
      'is_toy': instance.isToy,
    };

ToyRoomCommandOffsetEntity _$ToyRoomCommandOffsetEntityFromJson(
        Map<String, dynamic> json) =>
    ToyRoomCommandOffsetEntity(
      (json['x'] as num).toDouble(),
      (json['y'] as num).toDouble(),
    );

Map<String, dynamic> _$ToyRoomCommandOffsetEntityToJson(
        ToyRoomCommandOffsetEntity instance) =>
    <String, dynamic>{
      'x': instance.x,
      'y': instance.y,
    };

ToyRoomCommandEntity _$ToyRoomCommandEntityFromJson(
        Map<String, dynamic> json) =>
    ToyRoomCommandEntity(
      (json['vibration'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      (json['lines'] as List<dynamic>?)
              ?.map((e) => (e as List<dynamic>)
                  .map((e) => ToyRoomCommandOffsetEntity.fromJson(
                      e as Map<String, dynamic>))
                  .toList())
              .toList() ??
          [],
    );

Map<String, dynamic> _$ToyRoomCommandEntityToJson(
        ToyRoomCommandEntity instance) =>
    <String, dynamic>{
      'vibration': instance.vibration,
      'lines':
          instance.lines.map((e) => e.map((e) => e.toJson()).toList()).toList(),
    };

_$ToyVibrationCommandEntityImpl _$$ToyVibrationCommandEntityImplFromJson(
        Map<String, dynamic> json) =>
    _$ToyVibrationCommandEntityImpl(
      duration: json['duration'] as num,
      motor: json['motor'] as num,
    );

Map<String, dynamic> _$$ToyVibrationCommandEntityImplToJson(
        _$ToyVibrationCommandEntityImpl instance) =>
    <String, dynamic>{
      'duration': instance.duration,
      'motor': instance.motor,
    };
