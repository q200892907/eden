import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'toy_command_entity.freezed.dart';
part 'toy_command_entity.g.dart';

const toyTest = {
  'repeat': 2, //循环次数
  'unit': [
    {
      'duration': 300, //持续时间 毫秒值
      'motor': 0.3,
    },
    {
      'duration': 400, //持续时间 毫秒值
      'motor': 0.7,
    },
    {
      'duration': 1000, //持续时间 毫秒值
      'motor': 1,
    },
    {
      'duration': 300, //持续时间 毫秒值
      'motor': 0.7,
    },
    {
      'duration': 400, //持续时间 毫秒值
      'motor': 0.2,
    },
  ],
};

/// 礼物命令
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class ToyCommandEntity {
  ToyCommandEntity(this.unit, this.repeat, this.isToy);

  @JsonKey(defaultValue: 1)
  final int repeat;
  @JsonKey(defaultValue: [])
  final List<ToyVibrationCommandEntity> unit;

  @JsonKey(defaultValue: true)
  late bool isToy;

  List<ToyVibrationCommandEntity>? _realVibrations;

  ToyChartEntity? _chartDetail; //用于折线图展示

  int get _repeat => max(repeat, 1);

  List<ToyVibrationCommandEntity> get realVibrations {
    if (_realVibrations == null) {
      _realVibrations = <ToyVibrationCommandEntity>[];
      for (int i = 0; i < _repeat; i++) {
        _realVibrations?.addAll(unit.toList());
      }
    }
    return _realVibrations!;
  }

  ToyChartEntity get chartDetail {
    if (_chartDetail == null) {
      _chartDetail = ToyChartEntity();
      _chartDetail?.points.add(ToyChartPointEntity(0, 0));
      int index = 6;
      for (var element in realVibrations) {
        _chartDetail?.points.add(ToyChartPointEntity(
            _chartDetail!.totalTime + element.duration / index, element.value));
        _chartDetail?.points.add(ToyChartPointEntity(
            _chartDetail!.totalTime + element.duration / index * (index - 1),
            element.value));
        _chartDetail?.totalTime += element.duration; //计算总时长
      }
      _chartDetail?.points.add(ToyChartPointEntity(_chartDetail!.totalTime, 0));
    }
    return _chartDetail!;
  }

  factory ToyCommandEntity.fromJson(Map<String, dynamic> json) {
    return _$ToyCommandEntityFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ToyCommandEntityToJson(this);
}

@freezed
class ToyVibrationCommandEntity with _$ToyVibrationCommandEntity {
  const factory ToyVibrationCommandEntity({
    required num duration,
    required num motor,
  }) = _ToyVibrationCommandEntity;

  factory ToyVibrationCommandEntity.fromJson(Map<String, dynamic> json) =>
      _$ToyVibrationCommandEntityFromJson(json);
}

extension ToyVibrationCommandEntityExtension on ToyVibrationCommandEntity {
  int get value {
    return min<num>(motor * 100, 100).toInt();
  }
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class ToyRoomCommandOffsetEntity {
  ToyRoomCommandOffsetEntity(this.x, this.y);

  final double x;
  final double y;

  factory ToyRoomCommandOffsetEntity.fromJson(Map<String, dynamic> json) {
    return _$ToyRoomCommandOffsetEntityFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ToyRoomCommandOffsetEntityToJson(this);
}

extension ToyRoomCommandOffsetEntityExt on ToyRoomCommandOffsetEntity {
  Offset get offset => Offset(x, y);
}

extension OffsetExt on Offset {
  ToyRoomCommandOffsetEntity get commandOffset =>
      ToyRoomCommandOffsetEntity(dx, dy);
}

/// 房间命令
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class ToyRoomCommandEntity {
  ToyRoomCommandEntity(this.vibration, this.lines);

  final List<int> vibration;
  @JsonKey(defaultValue: [])
  final List<List<ToyRoomCommandOffsetEntity>> lines; //轨迹

  factory ToyRoomCommandEntity.fromJson(Map<String, dynamic> json) {
    return _$ToyRoomCommandEntityFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ToyRoomCommandEntityToJson(this);
}

class ToyChartEntity {
  num totalTime = 0; //总时长
  List<ToyChartPointEntity> points = [];
}

class ToyChartPointEntity {
  final num x;
  final num y;

  ToyChartPointEntity(this.x, this.y);
}

extension ToyChartEntityExt on ToyChartEntity {
  ToyChartEntity addPoint(num time, num value) {
    num totalTime = this.totalTime + time;
    List<ToyChartPointEntity> points = this.points.toList()
      ..add(ToyChartPointEntity(totalTime, value));
    return ToyChartEntity()
      ..totalTime = totalTime
      ..points = points;
  }
}
