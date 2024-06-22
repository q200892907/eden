enum EdenPublishType {
  eden('eden'),
  pgyer('pgyer'),
  testflight('testflight'),
  appstore('appstore');

  const EdenPublishType(this.value);

  final String value;

  factory EdenPublishType.byValue(String value) {
    return EdenPublishType.values.firstWhere(
      (element) => element.value == value,
      orElse: () {
        return EdenPublishType.eden;
      },
    );
  }
}
