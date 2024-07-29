import 'package:eden/entities/toy_command_entity.dart';
import 'package:eden_database/eden_database.dart';
import 'package:eden_database/objectbox.g.dart';
import 'package:flutter/material.dart';

class EdenChartUtil {
  factory EdenChartUtil() => _getInstance();

  static EdenChartUtil get instance => _getInstance();
  static EdenChartUtil? _instance;

  EdenChartUtil._internal();

  static EdenChartUtil _getInstance() {
    _instance ??= EdenChartUtil._internal();
    return _instance!;
  }

  final ValueNotifier<List<EdenObxChart>> _chartList = ValueNotifier([]);

  ValueNotifier<List<EdenObxChart>> get charts => _chartList;

  void init(String userId) {
    EdenObjectBox.instance.getCharts(userId).then((value) {
      _chartList.value = value;
    });
  }

  void dispose() {
    _chartList.value = [];
  }

  Future<bool> addChart(
    String userId,
    String name,
    ToyChartEntity chart,
  ) async {
    EdenObxChart? obxChart = EdenObxChart(
      userId: userId,
      name: name,
      totalTime: chart.totalTime.toInt(),
      points: ToMany(),
      createTime: DateTime.now(),
    );
    obxChart = await EdenObjectBox.instance.addChart(obxChart);
    for (var point in chart.points) {
      await EdenObjectBox.instance.addPoint(
        EdenObxChartPoint(
          chart: ToOne(target: obxChart),
          time: point.x.toInt(),
          y: point.y.toInt(),
        ),
      );
    }
    obxChart = await EdenObjectBox.instance.getChart(obxChart.id);
    if (obxChart != null) {
      _chartList.value = _chartList.value.toList()..insert(0, obxChart);
    }
    return true;
  }

  Future<bool> deleteChart(EdenObxChart chart) async {
    chart.delete();
    _chartList.value = _chartList.value.toList()
      ..removeWhere((e) => e.id == chart.id);
    return true;
  }
}

extension EdenObxChartConversion on EdenObxChart {
  ToyChartEntity toToyChartEntity() {
    ToyChartEntity chart = ToyChartEntity();
    chart.totalTime = totalTime;
    chart.points = points.map((e) => ToyChartPointEntity(e.time, e.y)).toList();
    return chart;
  }
}
