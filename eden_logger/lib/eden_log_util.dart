import 'dart:io';

import 'package:eden_logger/eden_log_logger.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class EdenLogFile {
  static Directory? _logDirectory;

  static String getLogDirectoryPath() {
    return _logDirectory?.path ?? '';
  }

  static Future<bool> init() async {
    _logDirectory ??=
        Directory('${(await getApplicationSupportDirectory()).path}/logs');
    return Future.value(true);
  }

  static clear() {
    if (_logDirectory == null) {
      return;
    }
    _logDirectory?.deleteSync(recursive: true);
  }

  static removeDirectoriesOlderThanDays([int days = 7]) {
    if (_logDirectory == null) {
      return;
    }
    final now = DateTime.now();
    final threshold = now.subtract(Duration(days: days));

    final dir = _logDirectory;
    if (dir!.existsSync()) {
      for (final fileEntity in dir.listSync(followLinks: false)) {
        final path = fileEntity.path;
        if (fileEntity is Directory) {
          final dirModTime = File(path).statSync().modified;
          if (dirModTime.isBefore(threshold)) {
            try {
              Directory(path).deleteSync(recursive: true);
            } catch (_) {}
          }
        } else if (fileEntity is File) {
          try {
            File(path).deleteSync();
          } catch (_) {}
        }
      }
    }
  }

  static Future<void> write({
    required String info,
    required EdenLogType type,
    String fileName = 'log',
  }) {
    return _write(
      info,
      type,
      fileName,
    );
  }

  static Future<void> _write(
    String info,
    EdenLogType type, [
    String fileName = 'log',
  ]) async {
    if (_logDirectory == null) {
      return;
    }
    final dateFormat = DateFormat('yyyy-MM-dd');
    final timestamp = dateFormat.format(DateTime.now());
    final logFile = File('${_logDirectory!.path}/$timestamp/$fileName.txt');
    final content = '[${DateTime.now().toString()}][${type.name}]\n\n$info\n\n';

    if (!_logDirectory!.existsSync()) {
      _logDirectory!.createSync(recursive: true);
    }
    if (!logFile.existsSync()) {
      logFile.createSync(recursive: true);
    }
    logFile.writeAsStringSync(content, mode: FileMode.append);
  }
}
