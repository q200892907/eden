import 'package:objectbox/objectbox.dart';

@Entity()
class EdenObxChart {
  @Id()
  int id;
  @Index(type: IndexType.value)
  final String userId;
  final String name; // 自定义名称
  final int totalTime;
  @Property(type: PropertyType.date)
  DateTime createTime; //创建时间
  @Backlink('chart')
  ToMany<EdenObxChartPoint> points; //关联点

  EdenObxChart({
    this.id = 0,
    required this.userId,
    required this.name,
    required this.createTime,
    required this.totalTime,
    required this.points,
  });

  @override
  String toString() {
    return 'EdenObxChart{name: $name, totalTime: $totalTime, points: $points}';
  }
}

@Entity()
class EdenObxChartPoint {
  @Id()
  int id;
  final ToOne<EdenObxChart> chart;
  final int time;
  final int y;

  EdenObxChartPoint({
    this.id = 0,
    required this.chart,
    required this.time,
    required this.y,
  });

  @override
  String toString() {
    return '($time, $y)';
  }
}
