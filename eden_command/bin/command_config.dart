import 'package:args/command_runner.dart';
import 'package:eden_command/eden_command.dart';

class CommandConfig extends Command {
  CommandConfig(this.edenCommand) {
    argParser.addFlag(
      'git-sub-modules',
      abbr: 'g',
      help: '更新项目所需的Git仓库',
      negatable: false,
    );
  }

  final EdenCommand edenCommand;

  @override
  String get description => '项目配置初始化';

  @override
  String get name => 'config';

  @override
  Future run() {
    bool isGitSubModules = argResults?.wasParsed('git-sub-modules') ?? false;
    if (isGitSubModules) {
      return edenCommand.getSubModules();
    }
    return Future.value();
  }
}
