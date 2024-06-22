import 'dart:io';

import 'package:eden_command/enum/platform.dart';
import 'package:eden_command/extensions/extensions.dart';
import 'package:eden_command/utils/utils.dart';
import 'package:eden_command/utils/which/apps/appdmg.dart';
import 'package:eden_command/utils/which/apps/dpkg_sig.dart';
import 'package:eden_command/utils/which/apps/fastlane.dart';
import 'package:eden_command/utils/which/apps/flutter_distributor.dart';
import 'package:eden_command/utils/which/apps/gnupg.dart';
import 'package:eden_command/utils/which/apps/inno_setup.dart';
import 'package:process_run/process_run.dart';

import 'which_app.dart';

extension on List<WhichApp> {
  Map<EdenPlatform, List<WhichApp>> convert() {
    Map<EdenPlatform, List<WhichApp>> temp = Map.fromEntries(
      EdenPlatform.all().map(
        (e) => MapEntry(e, []),
      ),
    );
    this.forEach((app) {
      app.platforms.forEach((platform) {
        temp[platform]?.add(app);
      });
    });
    return temp;
  }
}

class EdenWhich {
  static Future doctor() async {
    List<WhichApp> apps = [
      FlutterDistributor(),
      Fastlane(),
      AppDmg(),
      InnoSetup(),
      GnuPG(),
      DpkgSig(),
    ];

    for (var app in apps.convert().entries) {
      await _check(app.key, app.value);
    }
  }

  static Future publish() async {
    List<WhichApp> apps = [
      FlutterDistributor(),
      Fastlane(),
      AppDmg(),
      InnoSetup(),
      GnuPG(),
      DpkgSig(),
    ];

    for (var app in apps.convert().entries) {
      await _check(app.key, app.value);
    }
  }

  static _check(EdenPlatform platform, List<WhichApp> apps) async {
    if ((platform == EdenPlatform.macos && !Platform.isMacOS) ||
        platform == EdenPlatform.linux && !Platform.isLinux ||
        platform == EdenPlatform.windows && !Platform.isWindows) {
      return;
    }
    logger.info('');
    logger.info(platform.value);
    int index = 1;
    for (WhichApp element in apps) {
      String? check = whichSync(
        element.content,
        environment:
            element.path.isNotEmpty ? {element.content: element.path} : null,
      );
      if (check == null) {
        bool? install = await element.install;
        if (install == true) {
          logger.info('$index.${element.name}'.brightGreen());
        } else {
          logger.info('$index.${element.name}'.brightRed());
        }
      } else {
        logger.info('$index.${element.name}'.brightGreen());
      }
      index++;
    }
  }
}
