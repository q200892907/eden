import 'package:eden_database/objectbox.g.dart';

import '../eden_objectbox.dart';

extension EdenObxChartExtension on EdenObjectBox {
  Future<List<EdenObxChart>> getCharts(String userId) async {
    final query = chartBox
        .query(EdenObxChart_.userId.equals(userId))
        .order(EdenObxChart_.createTime, flags: Order.descending)
        .build();
    List<EdenObxChart> allCharts = await query.findAsync();
    query.close();
    return allCharts;
  }

  Future<EdenObxChart?> getChart(int id) async {
    if (id <= 0) {
      return null;
    }
    return chartBox.get(id);
  }

  Future<EdenObxChart> addChart(EdenObxChart chart) async {
    if (chart.id > 0) {
      return chart;
    }
    return chartBox.putAndGetAsync(
      chart,
    );
  }

  Future<bool> addPoint(EdenObxChartPoint point) async {
    if (point.id > 0) {
      return false;
    }
    return chartPointBox.put(
          point,
        ) >
        0;
  }
}

extension EdenObxChartExt on EdenObxChart {
  bool delete() {
    for (var point in points) {
      point.delete();
    }
    return EdenObjectBox.instance.chartBox.remove(id);
  }
}

extension EdenObxChartPointExt on EdenObxChartPoint {
  bool delete() {
    return EdenObjectBox.instance.chartPointBox.remove(id);
  }
}
