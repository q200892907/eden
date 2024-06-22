import 'dart:io';

import 'package:eden_command/enum/platform.dart';
import 'package:eden_command/utils/shell.dart';
import 'package:eden_command/utils/which/which_app.dart';

class Fastlane extends WhichApp {
  @override
  String get content => 'fastlane';

  @override
  String get name => 'fastlane(Android/iOS快速打包构建工具)';

  @override
  List<EdenPlatform> get platforms => [
        EdenPlatform.android,
        EdenPlatform.ios,
      ];

  @override
  Future<bool>? get install {
    if (Platform.isMacOS) {
      return edenRunExecutableArguments('sudo gem', [
        'install',
        'fastlane',
        '-NV',
      ]).then((value) {
        return value.isSuccess;
      });
    }
    return Future.value(false);
  }
}
