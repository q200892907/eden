import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:eden_uikit/eden_uikit.dart';
import 'package:eden_uikit/theme/eden_theme.dart';
import 'package:flutter/material.dart';

export 'eden_scroll_behavior.dart';

/// 三种模式
enum EdenThemeMode {
  light,
  dark,
  system;
}

/// 拓展AdaptiveTheme
/// [light] 正常主题
/// [dark] 暗夜主题
/// [initial] 模式，默认light
/// [builder] 初始化回调
class EdenThemeBuilder extends AdaptiveTheme {
  static ThemeData get theme => edenThemeNotifier.value;

  static BuildContext? _context;

  static BuildContext get context => _context!;

  /// 绑定上下文
  static void bindContext(BuildContext ctx) {
    _context = ctx;
  }

  static bool get isDark => of(context).theme.brightness == Brightness.dark;

  static AdaptiveThemeManager<ThemeData> of(BuildContext context) {
    return AdaptiveTheme.of(context);
  }

  static AdaptiveThemeManager<ThemeData>? maybeOf(BuildContext context) {
    return AdaptiveTheme.of(context);
  }

  static Future<EdenThemeMode> getThemeMode() async {
    return AdaptiveTheme.getThemeMode().then((value) {
      switch (value) {
        case AdaptiveThemeMode.light:
          return EdenThemeMode.light;
        case AdaptiveThemeMode.dark:
          return EdenThemeMode.dark;
        case AdaptiveThemeMode.system:
        default:
          return EdenThemeMode.system;
      }
    });
  }

  static changeTheme(BuildContext context, EdenThemeMode type) {
    switch (type) {
      case EdenThemeMode.light:
        EdenThemeBuilder.of(context).setLight();
        break;
      case EdenThemeMode.dark:
        EdenThemeBuilder.of(context).setDark();
        break;
      default:
        EdenThemeBuilder.of(context).setSystem();
        break;
    }
  }

  EdenThemeBuilder({
    super.key,
    EdenThemeMode initial = EdenThemeMode.light,
    required super.builder,
    super.debugShowFloatingThemeButton,
  }) : super(
          light: edenLightTheme.theme,
          dark: edenDarkTheme.theme,
          initial: initial == EdenThemeMode.light
              ? AdaptiveThemeMode.light
              : initial == EdenThemeMode.dark
                  ? AdaptiveThemeMode.dark
                  : AdaptiveThemeMode.system,
        );
}

final edenThemeNotifier = EdenThemeNotifier();

class EdenThemeChangedNotifier extends StatelessWidget {
  const EdenThemeChangedNotifier({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: edenThemeNotifier,
      builder: (_, theme, __) {
        return child;
      },
    );
  }
}

class EdenThemeNotifier extends ValueNotifier<ThemeData> {
  EdenThemeNotifier() : super(edenLightTheme.theme);

  void changeTheme(ThemeData theme) {
    if (value == theme) {
      return;
    }
    value = theme;
    EdenLoading.initialize();
  }
}
