import 'package:eden_command/enum/platform.dart';
import 'package:eden_command/enum/publish_type.dart';

class PublishConfig {
  final String apiUrl; //上传地址
  final String appleId;
  final String bundleId;
  final String appstoreApiKey;
  final String appstoreApiIssuer;
  final String appstoreP8;
  final String alTool;
  final String macosProfileName;
  final String windowsSignHash;

  final String linuxPrivate;
  final String linuxPrivatePassword;
  final String linuxPublic;
  final String linuxUserId;
  final List<String> linuxThirdPartyLibraries;
  final String testFlight;
  final Map<String, dynamic> publishTypes;
  final List<EdenPlatform> platforms;
  final String output;
  final String version;
  final List<PublishEnv> envs;
  final Pgyer pgyer;

  const PublishConfig({
    this.apiUrl = '',
    this.appleId = '',
    this.bundleId = '',
    this.appstoreApiKey = '',
    this.appstoreApiIssuer = '',
    this.appstoreP8 = '',
    this.alTool = '',
    this.testFlight = '',
    this.macosProfileName = '',
    this.windowsSignHash = '',
    this.linuxPrivate = '',
    this.linuxPublic = '',
    this.linuxUserId = '',
    this.linuxPrivatePassword = '',
    this.linuxThirdPartyLibraries = const [],
    this.publishTypes = const {},
    this.platforms = const [],
    this.output = 'publishFile',
    this.version = '',
    this.envs = const [],
    this.pgyer = const Pgyer(),
  });

  bool get isEmpty => platforms.isEmpty;

  bool get isEdenUpload => apiUrl.isNotEmpty;

  bool get isAppstoreEmpty =>
      appstoreApiKey.isEmpty ||
      appstoreApiIssuer.isEmpty ||
      appstoreP8.isEmpty ||
      appleId.isEmpty ||
      bundleId.isEmpty;

  bool get isWindowsCodeSign => windowsSignHash.isNotEmpty;

  bool get isMacosAccepted => macosProfileName.isNotEmpty; //是否去公认

  bool get isLinuxCodeSign =>
      linuxPrivate.isNotEmpty &&
      linuxPublic.isNotEmpty &&
      linuxPrivatePassword.isNotEmpty &&
      linuxUserId.isNotEmpty;

  int get publishTime => DateTime.now().millisecondsSinceEpoch;

  EdenPublishType getPublishType(EdenPlatform platform, PublishEnv env) {
    String type = publishTypes[platform.value]?[env.env] ?? 'zhiya';
    return EdenPublishType.byValue(type);
  }

  factory PublishConfig.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> envs = json['envs'] ?? {};
    return PublishConfig(
      apiUrl: json['apiUrl'] ?? '',
      appleId: json['appleId'] ?? '',
      bundleId: json['bundleId'] ?? '',
      appstoreApiKey: json['appstoreApiKey'] ?? '',
      appstoreApiIssuer: json['appstoreApiIssuer'] ?? '',
      appstoreP8: json['appstoreP8'] ?? '',
      alTool: json['alTool'] ?? '',
      macosProfileName: json['macosProfileName'] ?? '',
      windowsSignHash: json['windowsSignHash'] ?? '',
      linuxPrivate: json['linuxPrivate'] ?? '',
      linuxPrivatePassword: json['linuxPrivatePassword'] ?? '',
      linuxPublic: json['linuxPublic'] ?? '',
      linuxUserId: json['linuxUserId'] ?? '',
      linuxThirdPartyLibraries:
          List<String>.from(json['linuxThirdPartyLibraries'] ?? [])
              .map((e) => e)
              .toList(),
      testFlight: json['testFlight'] ?? '',
      publishTypes: json['publishTypes'] ?? const {},
      platforms: List<String>.from(json['platforms'] ?? [])
          .map((e) => EdenPlatform.byValue(e))
          .toList(),
      output: json['output'] ?? 'publishFile',
      version: json['version'] ?? '',
      envs: envs
          .map((key, value) {
            return MapEntry(key, PublishEnv(name: value, env: key));
          })
          .values
          .toList(),
      pgyer: Pgyer.fromJson(json['pgyer'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'apiUrl': apiUrl,
      'appleId': appleId,
      'bundleId': bundleId,
      'appstoreApiKey': appstoreApiKey,
      'appstoreApiIssuer': appstoreApiIssuer,
      'appstoreP8': appstoreP8,
      'alTool': alTool,
      'testFlight': testFlight,
      'macosProfileName': macosProfileName,
      'windowsSignHash': windowsSignHash,
      'linuxPrivate': linuxPrivate,
      'linuxPrivatePassword': linuxPrivatePassword,
      'linuxPublic': linuxPublic,
      'linuxUserId': linuxUserId,
      'linuxThirdPartyLibraries':
          linuxThirdPartyLibraries.map((e) => e).toList(),
      'publishTypes': publishTypes,
      'platforms': platforms.map((e) => e.value).toList(),
      'output': output,
      'version': version,
      'envs': Map.fromEntries(
        envs.map((e) => MapEntry(e.env, e.name)),
      ),
      'pgyer': pgyer.toJson(),
    };
  }

  @override
  String toString() {
    return 'PublishConfig{appleId: $appleId, bundleId: $bundleId, appstoreApiKey: $appstoreApiKey, appstoreApiIssuer: $appstoreApiIssuer, appstoreP8: $appstoreP8, alTool: $alTool, testFlight: $testFlight, publishTypes: $publishTypes, platforms: $platforms, output: $output, version: $version, envs: $envs, pgyer: $pgyer}';
  }
}

class PublishEnv {
  final String name;
  final String env;

  const PublishEnv({required this.name, required this.env});

  @override
  String toString() {
    return 'PublishEnv{name: $name, env: $env}';
  }
}

class Pgyer {
  final bool upload;
  final String fsAccessToken;
  final String apiKey;
  final String userKey;
  final String password;
  final int installType;
  final Map<String, Map<String, PgyerChannelShortcut>> channelShortcuts;

  const Pgyer({
    this.upload = false,
    this.fsAccessToken = '',
    this.apiKey = '',
    this.userKey = '',
    this.password = '',
    this.installType = 1,
    this.channelShortcuts = const {},
  });

  bool get isEmpty => !upload || apiKey.isEmpty || userKey.isEmpty;

  factory Pgyer.fromJson(Map<String, dynamic> json) {
    return Pgyer(
      upload: json['upload'] ?? false,
      fsAccessToken: json['fsAccessToken'] ?? '',
      apiKey: json['apiKey'] ?? "",
      userKey: json['userKey'] ?? '',
      password: json['password'] ?? '',
      installType: json['installType'] ?? 1,
      channelShortcuts: Map.from(
        (json['channelShortcuts'] ?? {}).map(
          (key, value) {
            return MapEntry(
              key,
              Map<String, PgyerChannelShortcut>.from(
                value.map(
                  (key1, value1) {
                    return MapEntry(
                      key1,
                      PgyerChannelShortcut(
                        name: value1['name'] ?? '',
                        arm64Name: value1['arm64Name'] ?? '',
                        pgyerEnv: value1['pgyEnv'] ?? '',
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'upload': upload,
      'fsAccessToken': fsAccessToken,
      'apiKey': apiKey,
      'userKey': userKey,
      'password': password,
      'installType': installType,
      'channelShortcuts': Map.from(
        channelShortcuts.map(
          (key, value) => MapEntry(
            key,
            Map.from(
              value.map(
                (key1, value1) => MapEntry(
                  key1,
                  {
                    'name': value1.name,
                    'arm64Name': value1.arm64Name,
                    'pgyEnv': value1.pgyerEnv,
                  },
                ),
              ),
            ),
          ),
        ),
      )
    };
  }

  @override
  String toString() {
    return 'Pgyer{fsAccessToken: $fsAccessToken, apiKey: $apiKey, userKey: $userKey, password: $password, installType: $installType, channelShortcuts: $channelShortcuts}';
  }
}

class PgyerChannelShortcut {
  final String name; //蒲公英短链名字
  final String arm64Name; //蒲公英短链名字-64位，仅支持android
  final String pgyerEnv; //蒲公英的渠道信息

  String get url => 'https://www.pgyer.com/${name}';

  String get url64 => 'https://www.pgyer.com/${arm64Name}';

  const PgyerChannelShortcut({
    required this.name,
    required this.pgyerEnv,
    this.arm64Name = '',
  });

  @override
  String toString() {
    return 'PgyerChannelShortcut{name: $name, pgyerEnv: $pgyerEnv}';
  }
}
