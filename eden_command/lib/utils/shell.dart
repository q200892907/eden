import 'dart:io';

import 'package:eden_command/extensions/extensions.dart';
import 'package:process_run/process_run.dart';

import 'logger.dart';

extension ProcessResultExt on ProcessResult {
  bool get isSuccess => exitCode == 0;
}

Future<ProcessResult> edenRunExecutableArguments(
    String executable, List<String> arguments,
    {String? workingDirectory}) async {
  Shell shell = Shell();
  if (workingDirectory != null) {
    shell = shell.cd(workingDirectory);
  }
  List<String> scripts = [executable];
  scripts.addAll(arguments);
  String script = scripts.join(' ');
  List<ProcessResult> processResults = await shell.run(script);
  if (processResults.first.exitCode != 0) {
    logger.info(processResults.first.errText.brightRed());
  }
  return processResults.first;
}
