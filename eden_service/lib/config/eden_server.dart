abstract class EdenServer {
  bool get isHttps => true;

  String get apiUrl =>
      '${isHttps ? 'https' : 'http'}://${apiDns ?? apiUri}'; // 普通接口服务

  String get objectbox;

  String? apiDns;

  String get apiUri;

  //
  @override
  String toString() {
    return '-----------EdenServer----------\n'
        'apiUrl: $apiUrl\n'
        'objectbox: $objectbox\n'
        '-----------EdenServer----------';
  }
}
