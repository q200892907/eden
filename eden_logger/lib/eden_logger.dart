library eden_logger;

import 'package:eden_logger/eden_log_logger.dart';
import 'package:eden_logger/eden_log_util.dart';
import 'package:logger/logger.dart';

export 'eden_log_logger.dart';
export 'eden_log_util.dart';

class EdenLogger {
  static Logger _logger = _defaultLogger;

  static final Logger _defaultLogger = Logger(
    printer: SimplePrinter(printTime: true),
  );

  static void init({Logger? logger}) {
    _logger = logger ?? _defaultLogger;
  }

  static void d(dynamic message, {bool write = false}) {
    _logger.d(message);
    EdenLogLogger.instance.add(EdenLogType.debug, message.toString());
    if (write) {
      EdenLogFile.write(type: EdenLogType.debug, info: message.toString());
    }
  }

  static void i(dynamic message, {bool write = false}) {
    _logger.i(message);
    EdenLogLogger.instance.add(EdenLogType.info, message.toString());
    if (write) {
      EdenLogFile.write(type: EdenLogType.info, info: message.toString());
    }
  }

  static void w(dynamic message, {bool write = false}) {
    _logger.w(message);
    EdenLogLogger.instance.add(EdenLogType.warning, message.toString());
    if (write) {
      EdenLogFile.write(type: EdenLogType.warning, info: message.toString());
    }
  }

  static void e(dynamic message) {
    _logger.e(message);
    EdenLogLogger.instance.add(EdenLogType.error, message.toString());
    EdenLogFile.write(type: EdenLogType.error, info: message.toString());
  }
}
