import 'package:eden/config/eden_config.dart';
import 'package:eden/localizations/eden_localization.dart';
import 'package:eden/router/eden_router.dart';
import 'package:eden/uikit/refresh/eden_refresh_footer.dart';
import 'package:eden_intl/eden_intl.dart';
import 'package:eden_uikit/eden_uikit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:jiffy/jiffy.dart';

late BuildContext appContext;

class EdenApp extends ConsumerStatefulWidget {
  const EdenApp({
    super.key,
    required this.themeMode,
  });

  final EdenThemeMode themeMode;

  @override
  ConsumerState<EdenApp> createState() => _EdenAppState();
}

class _EdenAppState extends ConsumerState<EdenApp> {
  @override
  Widget build(BuildContext context) {
    return EdenUikit(
      headerBuilder: () {
        return const MaterialClassicHeader();
      },
      footerBuilder: () {
        return EdenRefreshFooter.normal();
      },
      handsetSize: const Size(375, 812),
      child: EdenThemeBuilder(
        initial: widget.themeMode,
        debugShowFloatingThemeButton: EdenConfig.isDebug,
        builder: (ThemeData light, ThemeData dark) {
          return Builder(
            builder: (ctx) {
              EdenThemeBuilder.bindContext(ctx);
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                edenThemeNotifier.changeTheme(EdenThemeBuilder.of(ctx).theme);
              });
              return MaterialApp.router(
                scrollBehavior: const EdenScrollBehavior(),
                builder: EdenLoading.init(
                  builder: (_, child) {
                    return AnimatedTheme(
                      duration: const Duration(milliseconds: 1),
                      curve: Curves.easeOut,
                      data: Theme.of(_),
                      child: child!,
                    );
                  },
                ),
                theme: light,
                darkTheme: dark,
                debugShowCheckedModeBanner: false,
                // 国际化支持
                localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                  EdenLocalizationDelegate(),
                ],
                localeResolutionCallback:
                    (Locale? locale, Iterable<Locale> supportedLocales) {
                  var result =
                      supportedLocales.where((element) => element == locale);
                  if (result.isNotEmpty) {
                    return locale;
                  }
                  return EdenIntl.en;
                },
                locale: ref.watch(edenIntlProvider.select((value) {
                  Jiffy.setLocale(value.toString().toLowerCase());
                  return value;
                })),
                supportedLocales: EdenStrings.delegate.supportedLocales,
                routerConfig: EdenRouter.config,
              );
            },
          );
        },
      ),
    );
  }
}
