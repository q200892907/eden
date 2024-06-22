import 'package:eden_command/enum/platform.dart';
import 'package:eden_command/utils/shell.dart';
import 'package:eden_command/utils/which/which_app.dart';

class GnuPG extends WhichApp {
  @override
  String get content => 'gpg';

  @override
  String get name => 'GnuPG(Linux签名工具)';

  @override
  List<EdenPlatform> get platforms => [EdenPlatform.linux];

  @override
  Future<bool>? get install => edenRunExecutableArguments('sudo apt-get', [
        'install',
        'gnupg',
      ]).then((value) {
        return value.isSuccess;
      });
}
