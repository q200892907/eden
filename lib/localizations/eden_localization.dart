import 'package:eden/plugin/eden_plugin.dart';
import 'package:eden_intl/eden_intl.dart';
import 'package:eden_intl/generated/intl/messages_all.dart';
import 'package:eden_uikit/eden_uikit.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';

class EdenLocalization {
  static Future change(BuildContext context, Locale locale) {
    return context
        .read(edenIntlProvider.notifier)
        .changeLanguage(locale)
        .then((value) {
      if (value) {
        // EdenLogger.d('切换语言:$locale');
        // EdenStrings.load(locale);
        // EdenEditorStrings.load(locale);
        // AppFlowyEditorLocalizations.load(locale);
        Jiffy.setLocale(locale.toString().toLowerCase());
        EdenPlugin.instance.initHttpMessage();
      }
    });
  }
}

class EdenLocalizationDelegate extends AppLocalizationDelegate {
  const EdenLocalizationDelegate();

  @override
  Future<EdenStrings> load(Locale locale) {
    return MultipleLocalizations.load(
      (localeName) => initializeMessages(localeName),
      locale,
      (locale) => EdenStrings.load(Locale(locale)),
      setDefaultLocale: true,
    );
  }
}
