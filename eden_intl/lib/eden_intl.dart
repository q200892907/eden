library eden_intl;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'generated/l10n.dart';

export 'package:multiple_localization/multiple_localization.dart';

export 'generated/l10n.dart';

extension EdenIntlExtension on BuildContext {
  EdenStrings get strings {
    return EdenStrings.of(this);
  }
}

final edenIntlProvider = StateNotifierProvider<EdenIntlNotifier, Locale>((ref) {
  return EdenIntlNotifier();
});

class EdenIntl {
  static const Locale en = Locale('en');
}

class EdenIntlNotifier extends StateNotifier<Locale> {
  EdenIntlNotifier() : super(EdenIntl.en) {
    _init();
  }

  static const String _intl = 'eden_intl_key';

  static String lastIntl = EdenIntl.en.toString();

  void _init() {
    SharedPreferences.getInstance().then((value) {
      lastIntl = value.getString(_intl) ?? lastIntl;
      if (lastIntl.contains('_')) {
        List<String> intl = lastIntl.split('_');
        String languageCode = intl[0];
        String countryCode = intl[1];
        changeLanguage(
          Locale.fromSubtags(
            languageCode: languageCode,
            countryCode: countryCode,
          ),
        );
      } else {
        changeLanguage(Locale.fromSubtags(languageCode: lastIntl));
      }
    });
  }

  // 切换语言
  Future<bool> changeLanguage(Locale locale) {
    if (state == locale) {
      return Future.value(false);
    }
    lastIntl = locale.toString();
    SharedPreferences.getInstance().then((value) {
      value.setString(_intl, lastIntl);
    });
    state = locale;
    return Future.value(true);
  }
}
