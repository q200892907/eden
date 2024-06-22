import 'package:logging/logging.dart';

Logger logger = Logger('eden_command')
  ..onRecord.listen((record) {
    print(record.message);
  });
