import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String toy_bind_state = 'key_toy_bind_state';

class BleUtils {
  static int listToInt(List<int> list) {
    if (list.length > 3) {
      Uint8List data = Uint8List.fromList(list).sublist(0, 4);
      ByteData byteData = ByteData.view(data.buffer);
      return byteData.getInt32(0, Endian.little);
    }
    return 0;
  }

  static int listToShort(List<int> list) {
    if (list.length > 1) {
      Uint8List data = Uint8List.fromList(list).sublist(0, 2);
      ByteData byteData = ByteData.view(data.buffer);
      return byteData.getInt16(0, Endian.little);
    }
    return 0;
  }

  static String listToMac(List<int> list) {
    String mac = '';
    if (list.length == 6) {
      for (int item in list) {
        String value = item.toRadixString(16);
        if (value.length == 1) value = '0$value';
        mac += value;
      }
    }
    return mac;
  }

  static String listToString(List<int> list) {
    return ascii.decode(list.takeWhile((value) => value != 0).toList());
  }

  static int listToBattery(List<int> list) {
    if (list.isNotEmpty) return list.first;
    return 0;
  }

  static int listToPressure(List<int> list) {
    return listToShort(list);
  }

  static Future<bool> saveToyBindState(bool state) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(toy_bind_state, state);
  }

  static Future<bool> getToyBindState() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(toy_bind_state) ?? false;
  }
}

void blePrint(String log) {
  debugPrint('ble：$log');
}
