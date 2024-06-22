import 'package:eden_command/enum/platform.dart';
import 'package:eden_command/utils/shell.dart';
import 'package:eden_command/utils/which/which_app.dart';

class DpkgSig extends WhichApp {
  @override
  String get content => 'dpkg-sig';

  @override
  String get name => 'DpkgSig(Linux签名工具)';

  @override
  List<EdenPlatform> get platforms => [EdenPlatform.linux];

  @override
  Future<bool>? get install => edenRunExecutableArguments('sudo apt-get', [
        'install',
        'dpkg-sig',
      ]).then((value) {
        return value.isSuccess;
      });
}
