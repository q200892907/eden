// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class EdenStrings {
  EdenStrings();

  static EdenStrings? _current;

  static EdenStrings get current {
    assert(_current != null,
        'No instance of EdenStrings was loaded. Try to initialize the EdenStrings delegate before accessing EdenStrings.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<EdenStrings> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = EdenStrings();
      EdenStrings._current = instance;

      return instance;
    });
  }

  static EdenStrings of(BuildContext context) {
    final instance = EdenStrings.maybeOf(context);
    assert(instance != null,
        'No instance of EdenStrings present in the widget tree. Did you add EdenStrings.delegate in localizationsDelegates?');
    return instance!;
  }

  static EdenStrings? maybeOf(BuildContext context) {
    return Localizations.of<EdenStrings>(context, EdenStrings);
  }

  /// `Theme Mode`
  String get themeMode {
    return Intl.message(
      'Theme Mode',
      name: 'themeMode',
      desc: '',
      args: [],
    );
  }

  /// `Theme`
  String get theme {
    return Intl.message(
      'Theme',
      name: 'theme',
      desc: '',
      args: [],
    );
  }

  /// `Light`
  String get lightTheme {
    return Intl.message(
      'Light',
      name: 'lightTheme',
      desc: '',
      args: [],
    );
  }

  /// `Dark`
  String get darkTheme {
    return Intl.message(
      'Dark',
      name: 'darkTheme',
      desc: '',
      args: [],
    );
  }

  /// `System`
  String get systemTheme {
    return Intl.message(
      'System',
      name: 'systemTheme',
      desc: '',
      args: [],
    );
  }

  /// `Network anomaly`
  String get httpTimeout {
    return Intl.message(
      'Network anomaly',
      name: 'httpTimeout',
      desc: '',
      args: [],
    );
  }

  /// `The service is abnormal-Err.{code}`
  String httpCodeError(Object code) {
    return Intl.message(
      'The service is abnormal-Err.$code',
      name: 'httpCodeError',
      desc: '',
      args: [code],
    );
  }

  /// `The network connection is abnormal-Err.{code}`
  String httpStatusCodeError(Object code) {
    return Intl.message(
      'The network connection is abnormal-Err.$code',
      name: 'httpStatusCodeError',
      desc: '',
      args: [code],
    );
  }

  /// `Parameter abnormality`
  String get httpParamsError {
    return Intl.message(
      'Parameter abnormality',
      name: 'httpParamsError',
      desc: '',
      args: [],
    );
  }

  /// `Parsing exceptions`
  String get httpParseError {
    return Intl.message(
      'Parsing exceptions',
      name: 'httpParseError',
      desc: '',
      args: [],
    );
  }

  /// `Loading...`
  String get loadingText {
    return Intl.message(
      'Loading...',
      name: 'loadingText',
      desc: '',
      args: [],
    );
  }

  /// `No more data`
  String get noDataText {
    return Intl.message(
      'No more data',
      name: 'noDataText',
      desc: '',
      args: [],
    );
  }

  /// `Release to load more`
  String get canLoadingText {
    return Intl.message(
      'Release to load more',
      name: 'canLoadingText',
      desc: '',
      args: [],
    );
  }

  /// `Pull up Load more`
  String get idleText {
    return Intl.message(
      'Pull up Load more',
      name: 'idleText',
      desc: '',
      args: [],
    );
  }

  /// `Load Failed`
  String get failedText {
    return Intl.message(
      'Load Failed',
      name: 'failedText',
      desc: '',
      args: [],
    );
  }

  /// `Click to try again`
  String get clickToTryAgain {
    return Intl.message(
      'Click to try again',
      name: 'clickToTryAgain',
      desc: '',
      args: [],
    );
  }

  /// `Eden`
  String get appName {
    return Intl.message(
      'Eden',
      name: 'appName',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get home {
    return Intl.message(
      'Home',
      name: 'home',
      desc: '',
      args: [],
    );
  }

  /// `Community`
  String get community {
    return Intl.message(
      'Community',
      name: 'community',
      desc: '',
      args: [],
    );
  }

  /// `AI Chat`
  String get aiChat {
    return Intl.message(
      'AI Chat',
      name: 'aiChat',
      desc: '',
      args: [],
    );
  }

  /// `Personage`
  String get personage {
    return Intl.message(
      'Personage',
      name: 'personage',
      desc: '',
      args: [],
    );
  }

  /// `Play`
  String get play {
    return Intl.message(
      'Play',
      name: 'play',
      desc: '',
      args: [],
    );
  }

  /// `Touch`
  String get touch {
    return Intl.message(
      'Touch',
      name: 'touch',
      desc: '',
      args: [],
    );
  }

  /// `Automatic`
  String get automatic {
    return Intl.message(
      'Automatic',
      name: 'automatic',
      desc: '',
      args: [],
    );
  }

  /// `Sound`
  String get sound {
    return Intl.message(
      'Sound',
      name: 'sound',
      desc: '',
      args: [],
    );
  }

  /// `Music`
  String get music {
    return Intl.message(
      'Music',
      name: 'music',
      desc: '',
      args: [],
    );
  }

  /// `Remote`
  String get remote {
    return Intl.message(
      'Remote',
      name: 'remote',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<EdenStrings> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<EdenStrings> load(Locale locale) => EdenStrings.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
