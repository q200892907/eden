import 'package:eden_intl/eden_intl.dart';
import 'package:eden_uikit/eden_uikit.dart';
import 'package:flutter/material.dart';

class EdenRefreshFooter {
  static Widget normal() {
    return ClassicFooter(
      loadingText: EdenStrings.current.loadingText,
      noDataText: EdenStrings.current.noDataText,
      canLoadingText: EdenStrings.current.canLoadingText,
      idleText: EdenStrings.current.idleText,
      failedText: EdenStrings.current.failedText,
    );
  }

  static Widget noMore() {
    return ClassicFooter(
      loadingText: EdenStrings.current.loadingText,
      noDataText: '',
      canLoadingText: EdenStrings.current.canLoadingText,
      idleText: EdenStrings.current.idleText,
      failedText: EdenStrings.current.failedText,
    );
  }
}
