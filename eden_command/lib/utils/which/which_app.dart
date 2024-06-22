import 'package:eden_command/enum/platform.dart';

abstract class WhichApp {
  String get name; //名称
  String get content; //内容
  List<EdenPlatform> get platforms => EdenPlatform.all(); //支持检测的平台
  String get path => ''; //检测路径，为空则进行全局检测

  Future<bool>? get install => null; //安装方法
}
