import 'package:args/command_runner.dart';
import 'package:eden_command/eden_command.dart';

class CommandPublish extends Command {
  CommandPublish(this.edenCommand) {
    argParser.addFlag(
      'check',
      abbr: 'c',
      help: '检测发布所需库',
      negatable: false,
    );
  }

  final EdenCommand edenCommand;

  @override
  String get description => '项目打包发布';

  @override
  String get name => 'publish';

  @override
  Future run() {
    bool isCheck = argResults?.wasParsed('check') ?? false;
    if (isCheck) {
      return edenCommand.publishCheck();
    }
    return edenCommand.publish();
  }
}
