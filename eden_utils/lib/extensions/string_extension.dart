import 'dart:convert';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:intl/intl.dart' as intl;

extension StringEmptyExtension on String? {
  bool get isEmptyOrNull => this == null || (this?.isEmpty ?? true);
}

extension StringExtension on String {
  static const String _regexEmail =
      "^\\w+([-+.]\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*";
  static const String _regexPhone =
      r'^((13[0-9])|(14[0-9])|(15[0-9])|(16[0-9])|(17[0-9])|(18[0-9])|(19[0-9]))\d{8}$';

  bool isMatch({String? regex}) {
    return !isEmptyOrNull && RegExp(regex!).hasMatch(this);
  }

  /// 邮箱脱敏
  String maskEmail() {
    RegExp exp = RegExp(r"([a-zA-Z0-9_\-\.]{3})(.*)@([a-zA-Z0-9_\-\.]+)");
    RegExpMatch? match = exp.firstMatch(this);

    if (match == null) {
      return this;
    }

    String maskedPrefix =
        "${match.group(1)}${"*" * (match.group(2)?.length ?? 1)}@${match.group(3)}";

    return maskedPrefix;
  }

  /// 手机脱敏
  String maskPhone() {
    return replaceRange(3, 7, '****');
  }

  bool isValidPassword() {
    String regStr = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,18}$';
    RegExp regExp = RegExp(regStr);
    return regExp.hasMatch(this);
  }

  /// 是否为邮箱
  bool get isEmail => isMatch(regex: _regexEmail);

  /// 是否为手机号
  bool get isPhone => isMatch(regex: _regexPhone);

  // 中文2字符，英文1字符长度
  int get specialLength {
    final RegExp regexp = RegExp("[\u4e00-\u9fa5]");

    final List<RegExpMatch> r = regexp.allMatches(this).toList();
    final List<int> chinese = r.map((RegExpMatch e) => e.start).toList();
    int currentLength = 0;
    for (int i = 0; i < length; i++) {
      if (chinese.contains(i)) {
        currentLength += 2;
      } else {
        currentLength += 1;
      }
    }
    return currentLength;
  }

  /// Base64加密
  String encodeBase64() {
    final List<int> content = utf8.encode(this);
    final String digest = base64Encode(content);
    return digest;
  }

  /// Base64解密
  String decodeBase64() {
    return String.fromCharCodes(base64Decode(this));
  }

  /// 字符串转时间
  ///
  /// [format] 格式
  /// [locale] 语言
  DateTime getDateTime(
      {String format = 'yyyy-MM-dd HH:mm:ss', String? locale = 'zh'}) {
    if (this == '') {
      return DateTime.now();
    }
    final intl.DateFormat dateFormat = intl.DateFormat(format, locale);
    return dateFormat.parse(this);
  }

  /// 图片base64转Uint8List
  Uint8List get uint8List {
    if (this == '' || !contains(',')) {
      return Uint8List.fromList(<int>[]);
    }
    final List<String> list = split(',');
    String tempString = '';
    if (list.length == 2) {
      tempString = list[1];
    }
    return base64.decode(tempString);
  }

  /// 将每个字符串之间插入零宽空格
  String get showContent {
    if (isEmpty) {
      return this;
    }
    String breakWord = '';
    for (var element in runes) {
      breakWord += String.fromCharCode(element);
      breakWord += '\u200B';
    }
    return breakWord;
  }

  /// 获取字符串md5值
  String get md5 {
    final Uint8List content = const Utf8Encoder().convert(this);
    final crypto.Digest digest = crypto.md5.convert(content);
    return hex.encode(digest.bytes);
  }

  /// reverse
  String get reverse {
    if (isEmptyOrNull) {
      return '';
    }
    final StringBuffer sb = StringBuffer();
    for (int i = length - 1; i >= 0; i--) {
      sb.writeCharCode(codeUnitAt(i));
    }
    return sb.toString();
  }
}

// 优先展示字符串拓展
String priorityDisplay(List<String> data) {
  return data.firstWhere((element) => element.trim().isNotEmpty,
      orElse: () => '');
}
