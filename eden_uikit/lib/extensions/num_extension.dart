import 'package:romanice/romanice.dart';

extension FileNumExt on num {
  static const _rollupSizeUnits = ["GB", "MB", "KB", "B"];

  // 返回文件大小字符串
  String getRollupSize() {
    var size = toInt();
    if (size < 0) return '-';
    int idx = 3;
    int r1 = 0;
    String result = "";
    while (idx >= 0) {
      int s1 = size % 1024;
      size = size >> 10;
      if (size == 0 || idx == 0) {
        r1 = (r1 * 100) ~/ 1024;
        if (r1 > 0) {
          if (r1 >= 10) {
            result = "$s1.$r1${_rollupSizeUnits[idx]}";
          } else {
            result = "$s1.0$r1${_rollupSizeUnits[idx]}";
          }
        } else {
          result = s1.toString() + _rollupSizeUnits[idx];
        }
        break;
      }
      r1 = s1;
      idx--;
    }
    return result;
  }
}

extension IntToStringExt on int {
  String toLatinString() {
    String result = '';
    int number = this;
    while (number > 0) {
      int remainder = (number - 1) % 26;
      result = String.fromCharCode(remainder + 65) + result;
      number = (number - 1) ~/ 26;
    }
    return result.toLowerCase();
  }

  String toRomanString() {
    final ToRoman standardToRoman = ToRoman.standard();

    return standardToRoman(this).toLowerCase();
  }
}
