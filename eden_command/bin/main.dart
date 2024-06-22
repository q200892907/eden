import 'command_runner.dart';

Future<void> main(List<String> args) async {
  final EdenCommandRunner runner = EdenCommandRunner();

  return runner.commandRun(args);
}
