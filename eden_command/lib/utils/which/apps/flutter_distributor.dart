import 'package:eden_command/utils/shell.dart';
import 'package:eden_command/utils/which/which_app.dart';

class FlutterDistributor extends WhichApp {
  @override
  String get content => 'flutter_distributor';

  @override
  String get name => 'flutter_distributor(分发工具)';

  @override
  Future<bool>? get install => edenRunExecutableArguments(
        'dart',
        [
          'pub',
          'global',
          'activate',
          'flutter_distributor',
        ],
      ).then((value) {
        return value.isSuccess;
      });
}
