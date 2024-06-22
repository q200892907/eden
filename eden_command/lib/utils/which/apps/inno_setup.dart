import 'package:eden_command/enum/platform.dart';
import 'package:eden_command/utils/which/which_app.dart';

class InnoSetup extends WhichApp {
  @override
  String get content => 'iscc';

  @override
  String get name => 'Inno Setup(Windows构建工具)';

  @override
  List<EdenPlatform> get platforms => [EdenPlatform.windows];

  @override
  String get path => 'C:\\Program Files (x86)\\Inno Setup 6';
}
