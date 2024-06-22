// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element, unnecessary_cast

part of 'eden_theme.dart';

// **************************************************************************
// TailorAnnotationsGenerator
// **************************************************************************

mixin _$EdenThemeTailorMixin on ThemeExtension<EdenTheme> {
  Brightness get brightness;
  Color get transparent;
  Color get background;
  Color get barrierColor;
  Color get customHoverColor;
  Color get primary;
  Color get danger;
  Color get success;
  Color get warning;
  Color get border;
  Color get line;
  EdenTextTheme get text;
  EdenToastTheme get toast;

  @override
  EdenTheme copyWith({
    Brightness? brightness,
    Color? transparent,
    Color? background,
    Color? barrierColor,
    Color? customHoverColor,
    Color? primary,
    Color? danger,
    Color? success,
    Color? warning,
    Color? border,
    Color? line,
    EdenTextTheme? text,
    EdenToastTheme? toast,
  }) {
    return EdenTheme(
      brightness: brightness ?? this.brightness,
      transparent: transparent ?? this.transparent,
      background: background ?? this.background,
      barrierColor: barrierColor ?? this.barrierColor,
      customHoverColor: customHoverColor ?? this.customHoverColor,
      primary: primary ?? this.primary,
      danger: danger ?? this.danger,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      border: border ?? this.border,
      line: line ?? this.line,
      text: text ?? this.text,
      toast: toast ?? this.toast,
    );
  }

  @override
  EdenTheme lerp(covariant ThemeExtension<EdenTheme>? other, double t) {
    if (other is! EdenTheme) return this as EdenTheme;
    return EdenTheme(
      brightness: t < 0.5 ? brightness : other.brightness,
      transparent: Color.lerp(transparent, other.transparent, t)!,
      background: Color.lerp(background, other.background, t)!,
      barrierColor: Color.lerp(barrierColor, other.barrierColor, t)!,
      customHoverColor:
          Color.lerp(customHoverColor, other.customHoverColor, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      border: Color.lerp(border, other.border, t)!,
      line: Color.lerp(line, other.line, t)!,
      text: text.lerp(other.text, t) as EdenTextTheme,
      toast: toast.lerp(other.toast, t) as EdenToastTheme,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is EdenTheme &&
            const DeepCollectionEquality()
                .equals(brightness, other.brightness) &&
            const DeepCollectionEquality()
                .equals(transparent, other.transparent) &&
            const DeepCollectionEquality()
                .equals(background, other.background) &&
            const DeepCollectionEquality()
                .equals(barrierColor, other.barrierColor) &&
            const DeepCollectionEquality()
                .equals(customHoverColor, other.customHoverColor) &&
            const DeepCollectionEquality().equals(primary, other.primary) &&
            const DeepCollectionEquality().equals(danger, other.danger) &&
            const DeepCollectionEquality().equals(success, other.success) &&
            const DeepCollectionEquality().equals(warning, other.warning) &&
            const DeepCollectionEquality().equals(border, other.border) &&
            const DeepCollectionEquality().equals(line, other.line) &&
            const DeepCollectionEquality().equals(text, other.text) &&
            const DeepCollectionEquality().equals(toast, other.toast));
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType.hashCode,
      const DeepCollectionEquality().hash(brightness),
      const DeepCollectionEquality().hash(transparent),
      const DeepCollectionEquality().hash(background),
      const DeepCollectionEquality().hash(barrierColor),
      const DeepCollectionEquality().hash(customHoverColor),
      const DeepCollectionEquality().hash(primary),
      const DeepCollectionEquality().hash(danger),
      const DeepCollectionEquality().hash(success),
      const DeepCollectionEquality().hash(warning),
      const DeepCollectionEquality().hash(border),
      const DeepCollectionEquality().hash(line),
      const DeepCollectionEquality().hash(text),
      const DeepCollectionEquality().hash(toast),
    );
  }
}

extension EdenThemeThemeDataProps on ThemeData {
  EdenTheme get edenTheme => extension<EdenTheme>()!;
  Brightness get brightness => edenTheme.brightness;
  Color get transparent => edenTheme.transparent;
  Color get background => edenTheme.background;
  Color get barrierColor => edenTheme.barrierColor;
  Color get customHoverColor => edenTheme.customHoverColor;
  Color get primary => edenTheme.primary;
  Color get danger => edenTheme.danger;
  Color get success => edenTheme.success;
  Color get warning => edenTheme.warning;
  Color get border => edenTheme.border;
  Color get line => edenTheme.line;
  EdenTextTheme get text => edenTheme.text;
  EdenToastTheme get toast => edenTheme.toast;
}

mixin _$EdenToastThemeTailorMixin on ThemeExtension<EdenToastTheme> {
  Color get background;
  Color get text;

  @override
  EdenToastTheme copyWith({
    Color? background,
    Color? text,
  }) {
    return EdenToastTheme(
      background: background ?? this.background,
      text: text ?? this.text,
    );
  }

  @override
  EdenToastTheme lerp(
      covariant ThemeExtension<EdenToastTheme>? other, double t) {
    if (other is! EdenToastTheme) return this as EdenToastTheme;
    return EdenToastTheme(
      background: Color.lerp(background, other.background, t)!,
      text: Color.lerp(text, other.text, t)!,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is EdenToastTheme &&
            const DeepCollectionEquality()
                .equals(background, other.background) &&
            const DeepCollectionEquality().equals(text, other.text));
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType.hashCode,
      const DeepCollectionEquality().hash(background),
      const DeepCollectionEquality().hash(text),
    );
  }
}

mixin _$EdenTextThemeTailorMixin on ThemeExtension<EdenTextTheme> {
  Color get shade100;
  Color get shade200;
  Color get shade300;
  Color get shade400;
  Color get shade500;
  Color get shade600;
  Color get shade700;
  Color get shade800;
  Color get shade900;

  @override
  EdenTextTheme copyWith({
    Color? shade100,
    Color? shade200,
    Color? shade300,
    Color? shade400,
    Color? shade500,
    Color? shade600,
    Color? shade700,
    Color? shade800,
    Color? shade900,
  }) {
    return EdenTextTheme(
      shade100: shade100 ?? this.shade100,
      shade200: shade200 ?? this.shade200,
      shade300: shade300 ?? this.shade300,
      shade400: shade400 ?? this.shade400,
      shade500: shade500 ?? this.shade500,
      shade600: shade600 ?? this.shade600,
      shade700: shade700 ?? this.shade700,
      shade800: shade800 ?? this.shade800,
      shade900: shade900 ?? this.shade900,
    );
  }

  @override
  EdenTextTheme lerp(covariant ThemeExtension<EdenTextTheme>? other, double t) {
    if (other is! EdenTextTheme) return this as EdenTextTheme;
    return EdenTextTheme(
      shade100: Color.lerp(shade100, other.shade100, t)!,
      shade200: Color.lerp(shade200, other.shade200, t)!,
      shade300: Color.lerp(shade300, other.shade300, t)!,
      shade400: Color.lerp(shade400, other.shade400, t)!,
      shade500: Color.lerp(shade500, other.shade500, t)!,
      shade600: Color.lerp(shade600, other.shade600, t)!,
      shade700: Color.lerp(shade700, other.shade700, t)!,
      shade800: Color.lerp(shade800, other.shade800, t)!,
      shade900: Color.lerp(shade900, other.shade900, t)!,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is EdenTextTheme &&
            const DeepCollectionEquality().equals(shade100, other.shade100) &&
            const DeepCollectionEquality().equals(shade200, other.shade200) &&
            const DeepCollectionEquality().equals(shade300, other.shade300) &&
            const DeepCollectionEquality().equals(shade400, other.shade400) &&
            const DeepCollectionEquality().equals(shade500, other.shade500) &&
            const DeepCollectionEquality().equals(shade600, other.shade600) &&
            const DeepCollectionEquality().equals(shade700, other.shade700) &&
            const DeepCollectionEquality().equals(shade800, other.shade800) &&
            const DeepCollectionEquality().equals(shade900, other.shade900));
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType.hashCode,
      const DeepCollectionEquality().hash(shade100),
      const DeepCollectionEquality().hash(shade200),
      const DeepCollectionEquality().hash(shade300),
      const DeepCollectionEquality().hash(shade400),
      const DeepCollectionEquality().hash(shade500),
      const DeepCollectionEquality().hash(shade600),
      const DeepCollectionEquality().hash(shade700),
      const DeepCollectionEquality().hash(shade800),
      const DeepCollectionEquality().hash(shade900),
    );
  }
}
