enum EdenPlatform {
  android('android'),
  ios('ios'),
  windows('windows'),
  macos('macos'),
  linux('linux'),
  unknown('unknown');

  const EdenPlatform(this.value);

  final String value;

  static List<EdenPlatform> all() {
    return EdenPlatform.values.toList()
      ..removeWhere((element) => element == EdenPlatform.unknown);
  }

  factory EdenPlatform.byValue(String value) {
    return EdenPlatform.values.firstWhere((element) => element.value == value,
        orElse: () {
      return EdenPlatform.unknown;
    });
  }
}
