import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:eden_command/eden_command.dart';
import 'package:eden_command/utils/utils.dart';

import 'command_config.dart';
import 'command_create.dart';
import 'command_publish.dart';

class EdenCommandRunner extends CommandRunner {
  EdenCommandRunner() : super('eden', 'eden命令组') {
    argParser
      ..addFlag(
        'clean',
        abbr: 'c',
        help: '目录下所有Flutter项目进行清理',
        negatable: false,
      )
      ..addFlag(
        'doctor',
        abbr: 'd',
        help: '环境诊断',
        negatable: false,
      )
      ..addFlag(
        'get',
        abbr: 'g',
        help: '目录下所有Flutter项目进行pub get',
        negatable: false,
      )
      ..addFlag(
        'update',
        abbr: 'u',
        help: '更新工具',
        negatable: false,
      )
      ..addFlag(
        'version',
        abbr: 'v',
        help: '版本号',
        negatable: false,
      )
      ..addFlag(
        'build_runner',
        abbr: 'b',
        help: '快捷执行build_runner',
        negatable: false,
      );

    addCommand(CommandConfig(edenCommand));
    addCommand(CommandPublish(edenCommand));
    addCommand(CommandCreate(edenCommand));
  }

  EdenCommand edenCommand = EdenCommand();

  /// 如果返回则表示需要执行后续操作
  Future<dynamic> commandRun(List<String> args) async {
    ArgResults argResults = parse(args);
    if (argResults.wasParsed('version')) {
      String? currentVersion = await edenCommand.getCurrentVersion();
      if (currentVersion != null) {
        logger.info(currentVersion);
        return true;
      }
    } else if (argResults.wasParsed('doctor')) {
      return edenCommand.doctor();
    } else if (argResults.wasParsed('build_runner')) {
      return edenRunExecutableArguments(
        'flutter',
        [
          'pub',
          'run',
          'build_runner',
          'build',
          '--delete-conflicting-outputs',
        ],
      ).then((value) {
        return value.isSuccess;
      });
    } else if (argResults.wasParsed('update')) {
      await edenRunExecutableArguments(
        'flutter',
        ['clean'],
        workingDirectory: './eden_command',
      );
      await edenRunExecutableArguments(
        'flutter',
        ['pub', 'upgrade'],
        workingDirectory: './eden_command',
      );
      List<String> arguments = [
        'pub',
        'global',
        'activate',
        '--source',
        'path',
        'eden_command',
      ];
      return edenRunExecutableArguments(
        'dart',
        arguments,
      ).then((value) {
        if (!value.isSuccess) {
          return edenRunExecutableArguments('flutter', arguments).then(
            (value) {
              return value.isSuccess;
            },
          );
        }
        return value.isSuccess;
      });
    } else if (argResults.wasParsed('clean')) {
      return edenCommand.clean();
    } else if (argResults.wasParsed('get')) {
      return edenCommand.get();
    }
    return runCommand(argResults);
  }
}
