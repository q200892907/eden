class BleModel {
  String mac = '';
  String pid = '';
  String hid = '';
  String fv = '';

  bool get isCompleted => mac.isNotEmpty && pid.isNotEmpty && hid.isNotEmpty && fv.isNotEmpty;

  @override
  String toString() {
    return 'mac = $mac, pid = $pid, hid = $hid, fv = $fv';
  }
}
