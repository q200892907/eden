import 'package:eden_uikit/eden_uikit.dart';
import 'package:flutter/services.dart';

class EdenDevelopClipboardUtil {
  static void copy(String text) {
    Clipboard.setData(ClipboardData(text: text)).then((value) {
      EdenToast.show('复制成功');
    });
  }
}
