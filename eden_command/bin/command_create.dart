import 'package:args/command_runner.dart';
import 'package:eden_command/eden_command.dart';
import 'package:eden_command/utils/utils.dart';

class CommandCreate extends Command {
  CommandCreate(this.edenCommand) {
    argParser.addFlag(
      'icons_launcher',
      abbr: 'i',
      help: '快捷执行图标生成',
      negatable: false,
    );
    argParser.addFlag(
      'eden_icons',
      abbr: 'e',
      help: '快捷更新EdenIcons',
      negatable: false,
    );
    argParser.addFlag(
      'eden_version',
      abbr: 'v',
      help: '生成EdenVersion文件',
      negatable: false,
    );
  }

  final EdenCommand edenCommand;

  @override
  String get description => '项目创建功能';

  @override
  String get name => 'create';

  @override
  Future run() {
    bool isIconsLauncher = argResults?.wasParsed('icons_launcher') ?? false;
    if (isIconsLauncher) {
      return edenRunExecutableArguments(
        'dart',
        [
          'run',
          'icons_launcher:create',
        ],
      ).then((value) {
        return value.isSuccess;
      });
    }
    bool isZhiyaIcons = argResults?.wasParsed('eden_icons') ?? false;
    if (isZhiyaIcons) {
      return edenCommand.createIcons();
    }
    bool isZhiyaVersion = argResults?.wasParsed('eden_version') ?? false;
    if (isZhiyaVersion) {
      return edenCommand.createVersion();
    }
    return Future.value();
  }
}
