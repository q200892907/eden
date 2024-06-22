import 'package:eden_command/enum/platform.dart';
import 'package:eden_command/utils/shell.dart';
import 'package:eden_command/utils/which/which_app.dart';

class AppDmg extends WhichApp {
  @override
  String get content => 'appdmg';

  @override
  String get name => 'appdmg(MacOS构建工具)';

  @override
  List<EdenPlatform> get platforms => [EdenPlatform.macos];

  @override
  Future<bool>? get install => edenRunExecutableArguments('sudo npm', [
        'install',
        '-g',
        'appdmg',
      ]).then((value) {
        return value.isSuccess;
      });
}
