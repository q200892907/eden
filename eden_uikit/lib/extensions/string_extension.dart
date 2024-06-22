import 'dart:convert';

import 'package:crypto/crypto.dart';

extension StringMd5Ext on String {
  String convertMd5() {
    final bytes = utf8.encode(this);
    final digest = md5.convert(bytes);
    return digest.toString();
  }
}
