import 'dart:io';

import 'package:eden_command/entities/git_submodule.dart';
import 'package:eden_command/extensions/extensions.dart';
import 'package:eden_command/utils/utils.dart';

class EdenGit {
  static Future<bool> cloneOrUpdate(GitSubmodule submodule) async {
    Directory directory =
        Directory(Directory.current.path + '/' + submodule.path);
    bool isGitDir = await _isGitDir(directory.path);
    if (isGitDir) {
      logger.info('\n正在更新${submodule.submodule}\n'.brightBlue());
      var processResult = await _checkout(
        submodule.path,
        directory.path,
        submodule.branch,
      );
      if (!processResult.isSuccess) {
        logger.info('\n更新${submodule.submodule}失败，请重试\n'.brightRed());
        return false;
      }
      processResult = await _update(
        submodule.path,
        directory.path,
        branch: submodule.branch,
      );
      if (!processResult.isSuccess) {
        logger.info('\n更新${submodule.submodule}失败，请重试\n'.brightRed());
        return false;
      }
      logger.info('\n更新${submodule.submodule}成功\n'.brightGreen());
      return true;
    } else {
      logger.info('\n正在克隆${submodule.submodule}\n'.brightBlue());
      ProcessResult processResult = await _clone(
        submodule.url,
        submodule.branch,
        submodule.path,
      );
      if (processResult.isSuccess) {
        logger.info('\n克隆${submodule.submodule}成功\n'.brightGreen());
        return true;
      }
      logger.info('\n克隆${submodule.submodule}失败，请重试\n'.brightRed());
    }
    return false;
  }

  static Future<bool> _isGitDir(String path) async {
    var directory = Directory(path);
    if (directory.existsSync()) {
      if (directory.listSync().isEmpty) {
        return false;
      }
      return true;
    } else {
      return false;
    }
  }

  static Future<ProcessResult> _checkout(
      String url, String path, String branch) {
    Directory directory = Directory(path);
    if (!directory.existsSync()) {
      directory.createSync();
    }
    return edenRunExecutableArguments(
      'git',
      [
        'checkout',
        '$branch',
      ],
      workingDirectory: path,
    );
  }

  static Future<ProcessResult> _update(String url, String path,
      {String? branch}) {
    return edenRunExecutableArguments(
      'git',
      [
        'pull',
      ],
      workingDirectory: path,
    );
  }

  static Future<ProcessResult> _clone(
      String url, String branch, String folderName) {
    return edenRunExecutableArguments(
      'git',
      [
        'clone',
        '-b $branch',
        url,
        folderName,
      ],
    );
  }
}
