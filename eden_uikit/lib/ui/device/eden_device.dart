import 'dart:io';

import 'package:auto_orientation/auto_orientation.dart';
import 'package:eden_logger/eden_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 设备信息及
class EdenDevice {
  static bool isPortrait = true;

  static bool _isInit = false;

  static Orientation orientation = Orientation.landscape;

  /// 设置屏幕方向，仅支持iOS、Android
  /// 如果是手机，则固定竖屏
  /// 如果是平板，则固定横屏
  static Future<void> init([bool isPortrait = true]) async {
    if (_isInit) {
      return;
    }
    _isInit = true;
    if (isPortrait) {
      _portrait();
    } else {
      _landscape();
    }
  }

  static void _landscape() {
    EdenLogger.d('横屏');
    isPortrait = false;
    orientation = Orientation.landscape;
    AutoOrientation.landscapeAutoMode();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: <SystemUiOverlay>[SystemUiOverlay.bottom]);
    if (Platform.isIOS) {
      SystemChrome.setPreferredOrientations(<DeviceOrientation>[
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight
      ]);
    }
  }

  static void _portrait() {
    EdenLogger.d("竖屏");
    isPortrait = true;
    orientation = Orientation.portrait;
    AutoOrientation.portraitAutoMode();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: <SystemUiOverlay>[
          SystemUiOverlay.bottom,
          SystemUiOverlay.top
        ]);
    if (Platform.isIOS) {
      SystemChrome.setPreferredOrientations(
          <DeviceOrientation>[DeviceOrientation.portraitUp]);
    }
  }
}
