import 'package:intl/intl.dart' as intl;
import 'package:jiffy/jiffy.dart';

/// 时间类型
enum EdenDateType {
  day, //日
  week, //星期
  month, //月
  year, //年
}

extension DateTimeExtension on DateTime {
  /// 时间转字符串
  ///
  /// [format] 格式
  /// [locale] 语言
  String getString(
      {String format = 'yyyy-MM-dd HH:mm:ss', String? locale = 'zh'}) {
    final intl.DateFormat dateFormat = intl.DateFormat(format, locale);
    return dateFormat.format(this);
  }

  /// 是否为同天
  ///
  /// [date] 匹配判断的时间
  bool isSameDay({DateTime? date}) {
    date ??= DateTime.now();
    return year == date.year && month == date.month && day == date.day;
  }

  bool isBeforeDay({DateTime? date}) {
    date ??= DateTime.now();
    return differenceInDays(date) < 0;
  }

  /// 是否为闰年
  bool isLeapYear() {
    return year % 4 == 0 && year % 100 != 0 || year % 400 == 0;
  }

  /// 是否为同年
  ///
  /// [date] 匹配判断的时间
  bool isSameYear({DateTime? date}) {
    date ??= DateTime.now();
    return year == date.year;
  }

  /// 是否是同年同月
  ///
  /// [date] 匹配判断的时间
  bool isSameMonth({DateTime? date}) {
    date ??= DateTime.now();
    return year == date.year && month == date.month;
  }

  /// 是否为周六、周日
  bool isWeekend() {
    return weekday == DateTime.saturday || weekday == DateTime.sunday;
  }

  /// 下个月
  DateTime get nextMonth => DateTime(year, month + 1, day);

  /// 上个月
  DateTime get previousMonth => DateTime(year, month - 1, day);

  /// 下一年
  DateTime get nextYear => DateTime(year + 1, month, day);

  /// 上一年
  DateTime get previousYear => DateTime(year - 1, month, day);

  /// 获取年月日时间
  DateTime get ymd => DateTime(year, month, day);

  /// 天数差
  int differenceInDays(DateTime date) => ymd.difference(date.ymd).inDays;

  /// 获取当前时间的时间区间
  ///
  /// [type] 时间区间类型
  List<DateTime> interval({required EdenDateType type}) {
    DateTime startTime = this;
    DateTime endTime = this;
    switch (type) {
      case EdenDateType.day:
        startTime = DateTime(year, month, day);
        endTime = DateTime(year, month, day, 23, 59, 59);
        break;
      case EdenDateType.week:
        startTime = DateTime(year, month, day - weekday + 1);
        endTime = DateTime(year, month, day + (7 - weekday), 23, 59, 59);
        break;
      case EdenDateType.month:
        startTime = DateTime(year, month, 1);
        endTime = DateTime.fromMillisecondsSinceEpoch(
            DateTime(year, month + 1, 1).millisecondsSinceEpoch - 1000);
        break;
      case EdenDateType.year:
        startTime = DateTime(year);
        endTime = DateTime(year, 12, 31, 23, 59, 59);
        break;
    }

    return <DateTime>[startTime, endTime];
  }

  /// 获取当前时间的时间范围
  ///
  /// [rangeType] 范围类型
  /// [range] 范围值及类型，>=0 之后日期，<0 为之前日志，day为前后几天、默认当天，week为前后几周，默认前1周，month为前后几月，默认前1个月，year为前后几年，默认前1年
  List<DateTime> range({required EdenDateType rangeType, int? range}) {
    range ??= rangeType == EdenDateType.day ? 0 : -1;
    final DateTime time1 = this;
    DateTime time2;
    switch (rangeType) {
      case EdenDateType.day:
        time2 = DateTime(year, month, day + range);
        break;
      case EdenDateType.week:
        time2 = DateTime(year, month, day + (range * 7));
        break;
      case EdenDateType.month:
        time2 = DateTime.fromMillisecondsSinceEpoch(
            DateTime(year, month + range, day).millisecondsSinceEpoch - 1000);
        break;
      case EdenDateType.year:
        time2 = DateTime(year + range, month, day);
        break;
    }

    DateTime startTime;
    DateTime endTime;
    if (range < 0) {
      startTime = DateTime(time2.year, time2.month, time2.day, 0, 0, 0);
      endTime = DateTime(time1.year, time1.month, time1.day, 23, 59, 59);
    } else {
      startTime = DateTime(time1.year, time1.month, time1.day, 0, 0, 0);
      endTime = DateTime(time2.year, time2.month, time2.day, 23, 59, 59);
    }
    return <DateTime>[startTime, endTime];
  }

  /// 相对时间 xxx ago
  String form([DateTime? time]) {
    time ??= DateTime.now();
    return Jiffy.parseFromDateTime(this).from(Jiffy.parseFromDateTime(time));
  }

  /// 相对时间 in xxx
  String to([DateTime? time]) {
    time ??= DateTime.now();
    return Jiffy.parseFromDateTime(this).to(Jiffy.parseFromDateTime(time));
  }
}
