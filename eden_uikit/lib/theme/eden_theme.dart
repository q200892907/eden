import 'package:eden_uikit/eden_uikit.dart';
import 'package:flutter/material.dart';
import 'package:theme_tailor_annotation/theme_tailor_annotation.dart';

export 'eden_theme_builder.dart';

part 'eden_theme.tailor.dart';

const edenLightTheme = EdenTheme(
  brightness: Brightness.light,
  transparent: Color(0x00000000),
  background: Color(0xffffffff),
  barrierColor: Color(0x33000000),
  customHoverColor: Color(0x0f000000),
  primary: Color(0xffC58EFF),
  danger: Color(0xffff3141),
  success: Color(0xFF00b578),
  warning: Color(0xFFffaf37),
  border: Color(0xffd9d9d9),
  line: Color(0x0f000000),
  text: EdenTextTheme(
    shade100: Color(0xffffffff),
    shade200: Color(0xfff2f2f2),
    shade300: Color(0x40000000),
    shade400: Color(0x73000000),
    shade500: Color(0x8C000000),
    shade600: Color(0xBF000000),
    shade700: Color(0xD9000000),
    shade800: Color(0xE6000000),
    shade900: Color(0xFF000000),
  ),
  toast: EdenToastTheme(
    background: Color(0xffffffff),
    text: Color(0xD9000000),
  ),
);

const edenDarkTheme = EdenTheme(
  brightness: Brightness.dark,
  transparent: Color(0x00ffffff),
  background: Color(0xff1a1a1a),
  barrierColor: Color(0x40000000),
  customHoverColor: Color(0x1affffff),
  primary: Color(0xffC58EFF),
  danger: Color(0xffff3141),
  success: Color(0xFF00b578),
  warning: Color(0xFFffaf37),
  border: Color(0xff9d9d9d),
  line: Color(0xff454545),
  text: EdenTextTheme(
    shade100: Colors.black,
    shade200: Color(0xff111111),
    shade300: Color(0x40ffffff),
    shade400: Color(0x73ffffff),
    shade500: Color(0x8cffffff),
    shade600: Color(0xbfffffff),
    shade700: Color(0xd9ffffff),
    shade800: Color(0xe6ffffff),
    shade900: Color(0xffffffff),
  ),
  toast: EdenToastTheme(
    background: Color(0xff000000),
    text: Color(0xffffffff),
  ),
);

@TailorMixin(
  themeGetter: ThemeGetter.onThemeDataProps,
)
class EdenTheme extends ThemeExtension<EdenTheme> with _$EdenThemeTailorMixin {
  @override
  final Brightness brightness;
  @override
  final Color transparent;
  @override
  final Color background;
  @override
  final Color barrierColor;
  @override
  final Color customHoverColor;
  @override
  final Color primary;
  @override
  final Color danger;
  @override
  final Color success;
  @override
  final Color warning;
  @override
  final Color border;
  @override
  final Color line;
  @override
  final EdenTextTheme text;
  @override
  final EdenToastTheme toast;

  const EdenTheme({
    required this.brightness,
    required this.transparent,
    required this.background,
    required this.barrierColor,
    required this.customHoverColor,
    required this.primary,
    required this.danger,
    required this.success,
    required this.warning,
    required this.border,
    required this.line,
    required this.text,
    required this.toast,
  });
}

@tailorMixinComponent
class EdenToastTheme extends ThemeExtension<EdenToastTheme>
    with _$EdenToastThemeTailorMixin {
  @override
  final Color background;
  @override
  final Color text;

  const EdenToastTheme({
    required this.background,
    required this.text,
  });
}

@tailorMixinComponent
class EdenTextTheme extends ThemeExtension<EdenTextTheme>
    with _$EdenTextThemeTailorMixin {
  @override
  final Color shade100;
  @override
  final Color shade200;
  @override
  final Color shade300;
  @override
  final Color shade400;
  @override
  final Color shade500;
  @override
  final Color shade600;
  @override
  final Color shade700;
  @override
  final Color shade800;
  @override
  final Color shade900;

  const EdenTextTheme({
    required this.shade100,
    required this.shade200,
    required this.shade300,
    required this.shade400,
    required this.shade500,
    required this.shade600,
    required this.shade700,
    required this.shade800,
    required this.shade900,
  });
}

extension EdenThemeExt on EdenTheme {
  static EdenTheme fromBrightness(
    Brightness brightness,
  ) =>
      brightness == Brightness.light ? edenLightTheme : edenDarkTheme;

  ThemeData get theme {
    return ThemeData.from(
      colorScheme: ColorScheme(
        primary: primary,
        brightness: brightness,
        onPrimary: background,
        secondary: primary,
        onSecondary: background.invert,
        error: danger,
        onError: background,
        surface: background,
        onSurface: background.invert,
      ),
      useMaterial3: true,
    ).copyWith(
      extensions: [this],
    );
  }
}

extension ColorExt on Color {
  Color get invert {
    // 计算反色的RGB值
    int invertedRed = 255 - red;
    int invertedGreen = 255 - green;
    int invertedBlue = 255 - blue;

    // 创建反色的Color对象
    Color invertedColor =
        Color.fromRGBO(invertedRed, invertedGreen, invertedBlue, 1);

    return invertedColor;
  }
}

extension TextStyleEdenThemeExt on TextStyle {
  TextStyle get white => copyWith(
        color: Colors.white,
      );

  TextStyle danger(BuildContext? context) => copyWith(
      color: context != null
          ? context.theme.danger
          : EdenThemeBuilder.theme.danger);

  TextStyle primary(BuildContext? context) => copyWith(
      color: context != null
          ? context.theme.primary
          : EdenThemeBuilder.theme.primary);

  TextStyle success(BuildContext? context) => copyWith(
      color: context != null
          ? context.theme.success
          : EdenThemeBuilder.theme.success);

  TextStyle warning(BuildContext? context) => copyWith(
      color: context != null
          ? context.theme.warning
          : EdenThemeBuilder.theme.warning);

  TextStyle shade900(BuildContext? context) => copyWith(
      color: context != null
          ? context.theme.text.shade900
          : EdenThemeBuilder.theme.text.shade900);

  TextStyle shade800(BuildContext? context) => copyWith(
      color: context != null
          ? context.theme.text.shade800
          : EdenThemeBuilder.theme.text.shade800);

  TextStyle shade700(BuildContext? context) => copyWith(
      color: context != null
          ? context.theme.text.shade700
          : EdenThemeBuilder.theme.text.shade700);

  TextStyle shade600(BuildContext? context) => copyWith(
      color: context != null
          ? context.theme.text.shade600
          : EdenThemeBuilder.theme.text.shade600);

  TextStyle shade500(BuildContext? context) => copyWith(
      color: context != null
          ? context.theme.text.shade500
          : EdenThemeBuilder.theme.text.shade500);

  TextStyle shade400(BuildContext? context) => copyWith(
      color: context != null
          ? context.theme.text.shade400
          : EdenThemeBuilder.theme.text.shade400);

  TextStyle shade300(BuildContext? context) => copyWith(
      color: context != null
          ? context.theme.text.shade300
          : EdenThemeBuilder.theme.text.shade300);

  TextStyle shade200(BuildContext? context) => copyWith(
      color: context != null
          ? context.theme.text.shade200
          : EdenThemeBuilder.theme.text.shade200);

  TextStyle shade100(BuildContext? context) => copyWith(
      color: context != null
          ? context.theme.text.shade100
          : EdenThemeBuilder.theme.text.shade100);
}
