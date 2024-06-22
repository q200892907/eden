import 'dart:convert';
import 'dart:io';

import 'package:eden_command/extensions/extensions.dart';

import 'logger.dart';

class EdenIcons {
  static Future<bool> createIcons() async {
    Directory directory = Directory(Directory.current.path + '/eden_icons');
    if (!directory.existsSync()) {
      logger.info('未查询到zhiya_icons项目，请确保当前目录存在此项目'.brightRed());
      return false;
    }
    Directory iconfont = Directory(directory.path + '/iconfont');
    String? path;
    if (iconfont.existsSync()) {
      path = iconfont.path;
    }
    if (path == null) {
      logger.info('请输入iconfont文件所在目录:'.brightCyan());
      path = stdin.readLineSync()?.trim();
      if (path == null) {
        logger.info('未选择iconfont所在目录'.brightRed());
        return false;
      }
    }
    if (path.endsWith('/')) {
      path = path.substring(path.length - 1);
    }
    File ttfFile = File(path + '/iconfont.ttf');
    File jsonFile = File(path + '/iconfont.json');
    if (!ttfFile.existsSync() || !jsonFile.existsSync()) {
      logger.info('目录未包含所需文件iconfont.ttf/iconfont.json，请检查后重试'.brightRed());
      return false;
    }
    logger.info('复制iconfont.ttf到zhiya_icons/assets下');
    ttfFile.copySync(directory.path + '/assets/eden_icons.ttf');
    logger.info('读取iconfont.json文件中...');
    try {
      String jsonString = await jsonFile.readAsString();
      Map map = jsonDecode(jsonString);
      String? fontFamily = map['font_family'];
      List list = map['glyphs'] ?? '';
      logger.info('生成eden_icons文件中...');
      // 进行文件处理
      var desc =
          "library eden_icons;\n\nimport 'package:flutter/material.dart';\n\nclass EdenIcons {\n\tstatic const String _package = 'eden_icons';\n\n";
      var names =
          "\t///所有图标\n\tstatic const Map<String, IconData> values = <String, IconData>{\n";
      int i = 0;
      for (Map value in list) {
        String? name = value['font_class'];
        name = name
            ?.replaceAll('-', '_')
            .replaceAll(' ', '_')
            .replaceAll('1:1', 'one_to_one')
            .toLowerCase();
        String? unicode = value['unicode'];
        if (name != null && unicode != null) {
          desc =
              '$desc\t///图标${name}\n\tstatic const IconData ${name} = IconData(0x${unicode}, fontFamily: "$fontFamily", fontPackage: _package);';
        }
        if (i == list.length - 1) {
          desc = "${desc}\n\n";
          names = "${names}\t\t'$name': ${name},\n\t};";
        } else {
          desc = "${desc}\n\n";
          names = "${names}\t\t'$name': ${name},\n";
        }
        i++;
      }
      desc = "${desc}${names}";
      desc = '${desc}\n}';
      File file = File(directory.path + '/lib/src/eden_icons.dart');
      await file.writeAsString(desc);
    } catch (e) {
      logger.info('生成eden_icons文件失败，请重试'.brightRed());
      return false;
    }
    logger.info('EdenIcons处理完成'.brightGreen());
    return true;
  }
}
