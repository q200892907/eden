abstract class EdenServer {
  String get apiUrl; // 普通接口服务
  String get objectbox;

  //
  @override
  String toString() {
    return '-----------ZhiyaServer----------\n'
        'apiUrl: $apiUrl\n'
        'objectbox: $objectbox\n'
        '-----------ZhiyaServer----------';
  }
}
