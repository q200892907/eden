library eden_command;

import 'dart:convert';
import 'dart:io';

import 'package:eden_command/eden_command_options.dart';
import 'package:eden_command/entities/git_submodule.dart';
import 'package:eden_command/entities/ios_info.dart';
import 'package:eden_command/entities/publish_config.dart';
import 'package:eden_command/enum/platform.dart';
import 'package:eden_command/enum/publish_type.dart';
import 'package:eden_command/extensions/extensions.dart';
import 'package:eden_command/utils/project.dart';
import 'package:eden_command/utils/utils.dart';
import 'package:path/path.dart' as p;
import 'package:process_run/package/package.dart';
import 'package:process_run/process_run.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:xml/xml.dart';
import 'package:yaml/yaml.dart';

class EdenCommand {
  EdenCommand();

  Pubspec? _pubspec;

  Pubspec get pubspec {
    if (_pubspec == null) {
      final yamlString = File('pubspec.yaml').readAsStringSync();
      _pubspec = Pubspec.parse(yamlString);
    }
    return _pubspec!;
  }

  EdenCommandOptions? _commandOptions;

  EdenCommandOptions get commandOptions {
    if (_commandOptions == null) {
      File file = File('eden_command_options.yaml');
      if (file.existsSync()) {
        final yamlString = File('eden_command_options.yaml').readAsStringSync();
        final yamlDoc = loadYaml(yamlString);
        try {
          _commandOptions = EdenCommandOptions.fromJson(
            json.decode(json.encode(yamlDoc)),
          );
        } catch (e) {
          _commandOptions = EdenCommandOptions();
        }
      } else {
        _commandOptions = EdenCommandOptions();
      }
    }
    return _commandOptions!;
  }

  /// 获取当前版本
  Future<String?> getCurrentVersion() async {
    return await _getCurrentVersion();
  }

  Future<String?> _getCurrentVersion() async {
    try {
      var scriptFile = Platform.script.toFilePath();
      var pathToPubSpecYaml = p.join(p.dirname(scriptFile), '../pubspec.yaml');
      var pathToPubSpecLock = p.join(p.dirname(scriptFile), '../pubspec.lock');

      var pubSpecYamlFile = File(pathToPubSpecYaml);

      var pubSpecLockFile = File(pathToPubSpecLock);

      if (pubSpecLockFile.existsSync()) {
        var yamlDoc = loadYaml(await pubSpecLockFile.readAsString());
        if (yamlDoc['packages']['eden_command'] == null) {
          var yamlDoc = loadYaml(await pubSpecYamlFile.readAsString());
          return yamlDoc['version'];
        }

        return yamlDoc['packages']['eden_command']['version'];
      } else {
        final localFile = File('eden_command/pubspec.yaml');
        if (localFile.existsSync()) {
          final yamlString = localFile.readAsStringSync();
          var pubspec = Pubspec.parse(yamlString);
          return pubspec.version?.toString();
        }
      }
    } catch (_) {}
    return '1.0.0';
  }

  Future<IOSInfo?> _getIOSInfo() async {
    File file = File('ios/Runner/info.plist');
    if (file.existsSync()) {
      String plistContent = file.readAsStringSync();
      XmlDocument document = XmlDocument.parse(plistContent);

      // 从XML文档中提取所需的信息
      var bundleVersion = document
          .findAllElements('key')
          .firstWhere((node) => node.innerText == 'CFBundleVersion')
          .nextElementSibling
          ?.innerText;
      if (bundleVersion != null) {
        return IOSInfo(bundleVersion: bundleVersion);
      }
    }
    return Future.value(null);
  }

  Future<bool> doctor() async {
    await edenRunExecutableArguments(
      'flutter',
      ['doctor', '-v'],
    );
    await EdenWhich.doctor();
    await _linuxDoctor();
    return true;
  }

  Future<bool> _linuxDoctor() async {
    PublishConfig config = commandOptions.publishConfig;
    if (config.linuxThirdPartyLibraries.isEmpty || !Platform.isLinux) {
      return false;
    }
    Shell shell = Shell();
    List<String> commands = [
      'sudo',
      'apt',
      'install',
      ...config.linuxThirdPartyLibraries,
    ];
    String fastlaneCommand = commands.join(' ');
    List<ProcessResult> processResults = await shell.run(fastlaneCommand);
    if (processResults.first.exitCode != 0) {
      return Future.value(false);
    }
    return _linuxCodeSignConfig(config);
  }

  Future<bool> publishCheck() async {
    await EdenWhich.publish();
    await _linuxDoctor();
    return true;
  }

  Future<bool> createVersion() {
    PublishConfig config = commandOptions.publishConfig;
    if (config.isEmpty) {
      logger.info(
        '未配置publish，请在项目的eden_command_options.yaml中配置'.brightRed(),
      );
      return Future.value(false);
    }
    return _createVersion(config).then((value) {
      return value.$1;
    });
  }

  Future<(bool, String, int)> _createVersion(PublishConfig config) async {
    Version? version = await getPackageVersion();
    String versionString = '';
    String versionName = '';
    int versionCode = 0;
    if (version != null && config.version.isNotEmpty) {
      versionString = version.toString();
      List<String> versions = versionString.split('+');
      versionName = versions.first;
      versionCode = 1;
      if (versionString.contains('+')) {
        try {
          versionCode = int.parse(versions.last);
        } catch (_) {}
      }
      File versionFile = File(config.version);
      versionFile.writeAsString('''class EdenVersion {
  static const String versionName = '${versionName}';
  static const int versionCode = ${versionCode};
  static const int publishTime = ${config.publishTime};
}''');
    }
    if (versionString.isEmpty || versionCode == 0 || versionName.isEmpty) {
      return Future.value((false, '', -1));
    }
    return Future.value((true, versionName, versionCode));
  }

  Future<bool> publish() async {
    PublishConfig config = commandOptions.publishConfig;
    if (config.isEmpty) {
      logger.info(
        '未配置publish，请在项目的eden_command_options.yaml中配置'.brightRed(),
      );
      return Future.value(false);
    }
    bool isGetSubmodule = await getSubModules();
    if (!isGetSubmodule) {
      return Future.value(false);
    }
    var versionConfig = await _createVersion(config);
    bool isCreateVersion = versionConfig.$1;
    String versionName = versionConfig.$2;
    int versionCode = versionConfig.$3;
    if (!isCreateVersion) {
      return Future.value(false);
    }
    int? platformIndex = await _write(
      '发布平台',
      config.platforms.map((e) => e.value).toList(),
    );
    if (platformIndex == null) {
      return Future.value(false);
    }
    int? envIndex = await _write(
      '环境',
      config.envs.map((e) => e.name).toList(),
      0,
    );
    if (envIndex == null) {
      return Future.value(false);
    }
    int skip = (await _write(
          '是否跳过构建',
          ['否', '是'],
          0,
        )) ??
        0;
    int isUpload = 0;
    isUpload = (await _write(
          '是否跳过上传',
          ['否', '是'],
          0,
        )) ??
        0;
    int force = 0;
    if (config.isEdenUpload) {
      force = (await _write(
            '是否强制更新',
            ['否', '是'],
            0,
          )) ??
          0;
    }
    EdenPlatform platform = config.platforms[platformIndex];
    PublishEnv env = config.envs[envIndex];
    EdenPublishType publishType =
        commandOptions.publishConfig.getPublishType(platform, env);
    // 打包
    Shell shell = Shell();
    if (skip == 0) {
      List<ProcessResult> processResults = await shell.run(
        'flutter_distributor release --name ${platform.value} --jobs ${env.env}',
      );
      if (processResults.first.exitCode != 0) {
        logger.info(
          '打包失败，请重新尝试(${processResults.first.exitCode})'.brightRed(),
        );
        return Future.value(false);
      }
      if (platform == EdenPlatform.android) {
        await _copyAndroidApk(config, '$versionName+$versionCode');
      }
    }
    bool upload = false;
    String? uploadUrl; //下载/打开网址
    String? uploadUrl64; //下载/打开地址，仅android
    bool isDownload = true; //是否下载模式
    // 如果是iOS
    if ((publishType == EdenPublishType.testflight ||
            publishType == EdenPublishType.appstore) &&
        platform == EdenPlatform.ios) {
      // 正式环境，上传appstore
      isDownload = false;
      if (isUpload != 1) {
        upload = await _uploadAppstore(
          platform,
          config,
          env,
          versionName,
          versionCode,
        );
      } else {
        upload = true;
      }
      if (publishType == EdenPublishType.testflight) {
        uploadUrl = 'https://testflight.apple.com/join/${config.testFlight}';
      } else {
        uploadUrl = 'https://apps.apple.com/app/id${config.appleId}';
      }
    } else if (publishType == EdenPublishType.pgyer &&
        (platform == EdenPlatform.android || platform == EdenPlatform.ios)) {
      if (isUpload != 1) {
        upload = await _uploadPgyer(platform, config, env);
      } else {
        upload = true;
      }
      PgyerChannelShortcut? pgyerChannelShortcut =
          config.pgyer.channelShortcuts[platform.value]?[env.env];
      isDownload = false;
      if (pgyerChannelShortcut != null) {
        uploadUrl = pgyerChannelShortcut.url;
        if (platform == EdenPlatform.android) {
          uploadUrl64 = pgyerChannelShortcut.url64;
        }
      }
    } else {
      List<String>? uploadUrls =
          await _uploadEden(platform, config, env, versionName, versionCode);
      if (uploadUrls != null && uploadUrls.isNotEmpty) {
        upload = true;
        uploadUrl = uploadUrls.first;
        if (uploadUrls.length == 2) {
          uploadUrl64 = uploadUrls.last;
        }
      }
    }

    /// 上传成功，修改服务器信息
    if (upload && uploadUrl != null) {
      return _updateEdenVersion(
        platform,
        config,
        env,
        versionName,
        versionCode,
        uploadUrl,
        uploadUrl64,
        isDownload,
        force,
      );
    }
    return Future.value(true);
  }

  Future<void> _copyAndroidApk(PublishConfig config, String version) async {
    String path = Directory.current.path;
    List<String> copys = [
      '$path/build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk',
      '$path/build/app/outputs/flutter-apk/app-arm64-v8a-release.apk',
    ];
    for (var copyPath in copys) {
      await File(copyPath)
          .copy('$path/${config.output}/$version/${copyPath.split('/').last}');
    }
  }

  /// 获取发布文件地址，可能多个
  List<String> _getPublishFiles(
      PublishConfig config, EdenPlatform platform, String version) {
    String path = Directory.current.path;
    if (platform == EdenPlatform.android) {
      return [
        '$path/${config.output}/$version/app-armeabi-v7a-release.apk',
        '$path/${config.output}/$version/app-arm64-v8a-release.apk',
      ];
    } else {
      if (platform == EdenPlatform.ios) {
        path +=
            '/${config.output}/$version/zhiya-${version}-${platform.value}.ipa';
      } else if (platform == EdenPlatform.macos) {
        path +=
            '/${config.output}/$version/zhiya-${version}-${platform.value}.dmg';
      } else if (platform == EdenPlatform.windows) {
        path +=
            '/${config.output}/$version/zhiya-${version}-${platform.value}-setup.exe';
      } else if (platform == EdenPlatform.linux) {
        path +=
            '/${config.output}/$version/zhiya-${version}-${platform.value}.deb';
      }
      return [path];
    }
  }

  Future<bool> _uploadAppstore(
    EdenPlatform platform,
    PublishConfig config,
    PublishEnv env,
    String versionName,
    int versionCode,
  ) async {
    String version = '$versionName+$versionCode';
    if (platform != EdenPlatform.ios || !Platform.isMacOS) {
      return Future.value(true);
    }
    if (config.isAppstoreEmpty) {
      return Future.value(true);
    }
    // copy p8
    File p8File = File(config.appstoreP8);
    if (!p8File.existsSync()) {
      logger.info(
        '上传失败，${config.appstoreP8}文件不存在'.brightRed(),
      );
      return Future.value(false);
    }
    String? homeDir = Platform.environment['HOME'];
    if (homeDir == null) {
      logger.info(
        '上传失败，获取HOME目录失败'.brightRed(),
      );
      return Future.value(false);
    }
    File newP8File = await p8File
        .copy('${homeDir}/private_keys/${p8File.path.split('/').last}');
    if (!newP8File.existsSync()) {
      logger.info(
        '上传失败，${config.appstoreP8}文件复制失败'.brightRed(),
      );
      return Future.value(false);
    }
    IOSInfo? iosInfo = await _getIOSInfo();
    if (iosInfo == null) {
      logger.info(
        '上传失败，info.plist读取失败'.brightRed(),
      );
      return Future.value(false);
    }
    List<String> publishFiles = _getPublishFiles(config, platform, version);
    for (String filePath in publishFiles) {
      List<String> commands = [
        './altool',
        '-t ios',
        '--apiKey ${config.appstoreApiKey}',
        '--apiIssuer ${config.appstoreApiIssuer}',
        '--apple-id ${config.appleId}',
        '--bundle-id ${config.bundleId}',
        '--bundle-short-version-string $versionName',
        '--bundle-version ${iosInfo.bundleVersion}',
        '--upload-package $filePath'
      ];
      Shell shell = Shell();
      String fastlaneCommand = commands.join(' ');
      shell = shell.cd(config.alTool);
      List<ProcessResult> processResults = await shell.run(fastlaneCommand);
      if (processResults.first.exitCode != 0) {
        logger.info(
          '上传失败，请重新尝试(${processResults.first.exitCode})'.brightRed(),
        );
        return Future.value(false);
      }
    }
    return Future.value(true);
  }

  Future<bool> _uploadPgyer(
    EdenPlatform platform,
    PublishConfig config,
    PublishEnv env,
  ) async {
    if (config.pgyer.isEmpty) {
      return Future.value(false);
    }
    // 上传
    PgyerChannelShortcut? pgyerChannelShortcut =
        config.pgyer.channelShortcuts[platform.value]?[env.env];
    if (pgyerChannelShortcut == null) {
      logger.info(
        '上传失败，未查询到对应环境的蒲公英短链配置'.brightRed(),
      );
      return Future.value(false);
    }
    List<String> commands = [
      'fastlane',
      platform.value,
      pgyerChannelShortcut.pgyerEnv,
      'api_key:${config.pgyer.apiKey}',
      'user_key:${config.pgyer.userKey}',
      'password:${config.pgyer.password}',
      'install_type:${config.pgyer.installType}',
      'fs_access_token:${config.pgyer.fsAccessToken}',
      'channel_shortcut:${pgyerChannelShortcut.name}',
      'build_type:${platform == EdenPlatform.android ? 'app-armeabi-v7a-release.apk' : 'Release'}',
      'desc:${env.name}',
      'outputDir:${config.output}'
    ];
    Shell shell = Shell();
    String fastlaneCommand = commands.join(' ');
    shell = shell.cd(platform.value);
    List<ProcessResult> processResults = await shell.run(fastlaneCommand);
    if (processResults.first.exitCode != 0) {
      logger.info(
        '上传失败，请重新尝试(${processResults.first.exitCode})'.brightRed(),
      );
      return Future.value(false);
    }
    if (platform == EdenPlatform.android) {
      List<String> commands = [
        'fastlane',
        platform.value,
        pgyerChannelShortcut.pgyerEnv,
        'api_key:${config.pgyer.apiKey}',
        'user_key:${config.pgyer.userKey}',
        'password:${config.pgyer.password}',
        'install_type:${config.pgyer.installType}',
        'fs_access_token:${config.pgyer.fsAccessToken}',
        'channel_shortcut:${pgyerChannelShortcut.arm64Name}',
        'build_type:${platform == EdenPlatform.android ? 'app-arm64-v8a-release.apk' : 'Release'}',
        'desc:${env.name} arm64',
        'outputDir:${config.output}'
      ];
      String fastlaneCommand = commands.join(' ');
      List<ProcessResult> processResults = await shell.run(fastlaneCommand);
      if (processResults.first.exitCode != 0) {
        logger.info(
          '上传失败，请重新尝试(${processResults.first.exitCode})'.brightRed(),
        );
        return Future.value(false);
      }
    }
    return Future.value(true);
  }

  Future<bool> _windowsCodeSign(PublishConfig config, String file) async {
    if (!config.isWindowsCodeSign) {
      return false;
    }
    Shell shell = Shell();
    List<String> commands = [
      'signtool',
      'sign',
      '/fd',
      'sha256',
      '/sha1',
      config.windowsSignHash,
      '/tr',
      'http://timestamp.digicert.com',
      '/td',
      'sha256',
      file,
    ];
    String fastlaneCommand = commands.join(' ');
    List<ProcessResult> processResults = await shell.run(fastlaneCommand);
    if (processResults.first.exitCode != 0) {
      return Future.value(false);
    }
    return Future.value(true);
  }

  Future<bool> _linuxCodeSignConfig(PublishConfig config) async {
    if (!config.isLinuxCodeSign) {
      return false;
    }
    Shell shell = Shell();
    List<String> commands = [
      'gpg',
      '--import',
      '--pinentry-mode',
      'loopback',
      '--batch',
      '--passphrase',
      config.linuxPrivatePassword,
      config.linuxPrivate,
    ];
    String fastlaneCommand = commands.join(' ');
    List<ProcessResult> processResults = await shell.run(fastlaneCommand);
    if (processResults.first.exitCode != 0) {
      return Future.value(false);
    }
    commands = ['gpg', '--import', config.linuxPublic];
    fastlaneCommand = commands.join(' ');
    List<ProcessResult> processResults1 = await shell.run(fastlaneCommand);
    if (processResults1.first.exitCode != 0) {
      return Future.value(false);
    }
    commands = [
      'gpg',
      '--send-keys',
      config.linuxUserId,
    ];
    fastlaneCommand = commands.join(' ');
    List<ProcessResult> processResults2 = await shell.run(fastlaneCommand);
    if (processResults2.first.exitCode != 0) {
      return Future.value(false);
    }
    return Future.value(true);
  }

  Future<bool> _linuxCodeSign(PublishConfig config, String file) async {
    if (!config.isLinuxCodeSign) {
      return false;
    }
    if (!(await _linuxCodeSignConfig(config))) {
      return Future.value(false);
    }
    Shell shell = Shell();
    List<String> commands = [
      'dpkg-sig',
      '-k',
      config.linuxUserId,
      '-s',
      'zhiya',
      file,
    ];
    String fastlaneCommand = commands.join(' ');
    List<ProcessResult> processResults = await shell.run(fastlaneCommand);
    if (processResults.first.exitCode != 0) {
      return Future.value(false);
    }
    return Future.value(true);
  }

  Future<bool> _accepted(PublishConfig config, String file) async {
    if (!config.isMacosAccepted) {
      return false;
    }
    Shell shell = Shell();
    List<String> commands = [
      'xcrun',
      'notarytool',
      'submit',
      file,
      '--keychain-profile',
      config.macosProfileName,
      '--wait',
    ];
    String fastlaneCommand = commands.join(' ');
    List<ProcessResult> processResults = await shell.run(fastlaneCommand);
    if (processResults.first.exitCode != 0) {
      return Future.value(false);
    }
    return Future.value(true);
  }

  ///  上传到知丫服务器
  Future<List<String>?> _uploadEden(
    EdenPlatform platform,
    PublishConfig config,
    PublishEnv env,
    String versionName,
    int versionCode,
  ) async {
    if (!config.isEdenUpload) {
      return null;
    }
    String version = '$versionName+$versionCode';
    List<String> publishFiles = _getPublishFiles(config, platform, version);
    List<String> list = [];
    int index = 0;
    for (String file in publishFiles) {
      if (platform == EdenPlatform.windows) {
        //codesign
        bool codesign = await _windowsCodeSign(config, file);
        if (!codesign) {
          logger.info('$file文件签名失败'.brightRed());
        }
      } else if (platform == EdenPlatform.macos) {
        bool accepted = await _accepted(config, file);
        if (!accepted) {
          logger.info('$file公认失败'.brightRed());
        }
      } else if (platform == EdenPlatform.linux) {
        bool codesign = await _linuxCodeSign(config, file);
        if (!codesign) {
          logger.info('$file文件签名失败'.brightRed());
        }
      }
      String envTypeString = env.env == 'dev'
          ? 'dev'
          : env.env == 'stage'
              ? 'test'
              : '';
      String suffix = '';
      if (platform == EdenPlatform.ios) {
        suffix = '.ipa';
      } else if (platform == EdenPlatform.macos) {
        suffix = '.dmg';
      } else if (platform == EdenPlatform.windows) {
        suffix = '.exe';
      } else if (platform == EdenPlatform.linux) {
        suffix = '.deb';
      } else if (platform == EdenPlatform.android) {
        suffix = '.apk';
      }
      String fileName =
          'zhiya_${platform.value}_${version}${envTypeString.isEmpty ? '' : '_$envTypeString'}${index > 0 ? '_64' : ''}$suffix'
              .replaceAll('+', '_');
      //todo 上传eden服务器
      // EdenBackendServiceState<String?> state =
      //     await EdenBackendService.instance.uploadVersionFile(
      //   file,
      //   fileName,
      //   onProgress: (progress) {
      //     // 使用ANSI转义码 \x1B[2K 将当前行清空
      //     stdout.write('\x1B[2K\r');
      //     stdout.write(
      //         '${'上传进度:${(progress * 100).toStringAsFixed(2)}%'.brightBlue()}\r');
      //   },
      // );
      // stdout.write('\x1B[2K\r');
      // if (state.isSuccess && state.data != null) {
      //   list.add(state.data!);
      // } else {
      //   logger.info('上传失败了,${state}'.brightRed());
      //   return null;
      // }
      // index++;
    }
    if (list.length != publishFiles.length) {
      logger.info('上传失败了，数量不对'.brightRed());
      return null;
    }
    return Future.value(list);
  }

  /// 修改服务器信息
  Future<bool> _updateEdenVersion(
    EdenPlatform platform,
    PublishConfig config,
    PublishEnv env,
    String versionName,
    int versionCode,
    String url, //下载或打开的url
    String? url64, //android使用
    bool isDownload, //是否是下载模式
    int force, //是否强制 1是
  ) async {
    if (!config.isEdenUpload) {
      return false;
    }
    bool isRelease = env.env == 'release';
    // todo 发布到eden
    // EdenAppPlatform appPlatform;
    // switch (platform) {
    //   case EdenPlatform.android:
    //     appPlatform = EdenAppPlatform.android;
    //     break;
    //   case EdenPlatform.ios:
    //     appPlatform = EdenAppPlatform.ios;
    //     break;
    //   case EdenPlatform.windows:
    //     appPlatform = EdenAppPlatform.windows;
    //     break;
    //   case EdenPlatform.macos:
    //     appPlatform = EdenAppPlatform.macos;
    //     break;
    //   case EdenPlatform.linux:
    //     appPlatform = EdenAppPlatform.linux;
    //     break;
    //   case EdenPlatform.unknown:
    //     appPlatform = EdenAppPlatform.unknown;
    //     break;
    // }
    // EdenAppVersion appVersion = EdenAppVersion(
    //   name: versionName,
    //   code: versionCode,
    //   openMode: isDownload ? EdenAppOpenMode.download : EdenAppOpenMode.open,
    //   url: url,
    //   url1: url64 ?? '',
    //   versionType:
    //       isRelease ? EdenAppVersionType.release : EdenAppVersionType.test,
    //   upgradeType:
    //       force == 1 ? EdenAppUpgradeType.force : EdenAppUpgradeType.normal,
    //   platform: appPlatform,
    //   publishState: isRelease
    //       ? EdenAppPublishState.unpublished
    //       : EdenAppPublishState.published,
    // );
    // logger.info('发布配置:${appVersion}');
    // EdenBackendServiceState create =
    //     await EdenBackendService.instance.createVersion(
    //   appVersion,
    // );
    // if (create.isSuccess) {
    //   logger.info('发布成功'.brightGreen());
    //   return Future.value(true);
    // }
    // logger.info(create.message?.brightRed());
    return Future.value(false);
  }

  Future<int?> _write(String title, List<String> options, [int? defaultIndex]) {
    logger.info('$title:'.brightBlue());
    int index = 1;
    for (var option in options) {
      logger.info('$index.$option'.brightBlue());
      index++;
    }
    if (defaultIndex != null) {
      stdout.write('请选择(默认${defaultIndex + 1}):'.brightCyan());
    } else {
      stdout.write('请选择:'.brightCyan());
    }
    String? optionIndex = stdin.readLineSync()?.trim();
    if (optionIndex == null || optionIndex.isEmpty) {
      if (defaultIndex != null) {
        optionIndex = '${defaultIndex + 1}';
      } else {
        logger.info('未选择$title'.brightRed());
        return Future.value(null);
      }
    }
    int? tempIndex = int.tryParse(optionIndex);
    if (tempIndex == null || (tempIndex < 1 || tempIndex > options.length)) {
      logger.info('请输入正确的$title'.brightRed());
      return Future.value(null);
    }
    logger.info('您选择了${options[tempIndex - 1]}'.brightCyan());
    return Future.value(tempIndex - 1);
  }

  Future<bool> getSubModules() async {
    List<GitSubmodule> submodules = GitSubmodule.get();
    for (GitSubmodule submodule in submodules) {
      bool isSuccess = await EdenGit.cloneOrUpdate(submodule);
      if (!isSuccess) {
        return isSuccess;
      }
    }
    return Future.value(true);
  }

  Future<bool> createIcons() async {
    return EdenIcons.createIcons();
  }

  List<Directory> _getFlutterProjects() {
    return FlutterProjects.getProjects();
  }

  Future<bool> clean() async {
    var projects = _getFlutterProjects();
    for (var project in projects) {
      var processResult = await edenRunExecutableArguments(
        'flutter',
        ['clean'],
        workingDirectory: project.path,
      );
      if (!processResult.isSuccess) {
        logger
            .info('${FlutterProjects.getProjectName(project)}清理失败'.brightRed());
      }
    }
    return true;
  }

  Future<bool> get() async {
    var projects = _getFlutterProjects();
    for (var project in projects) {
      var processResult = await edenRunExecutableArguments(
        'flutter',
        [
          'pub',
          'upgrade',
        ],
        workingDirectory: project.path,
      );
      if (!processResult.isSuccess) {
        logger
            .info('${FlutterProjects.getProjectName(project)}获取失败'.brightRed());
      }
    }
    return true;
  }
}
