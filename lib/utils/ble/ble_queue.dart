import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'ble_utils.dart';

enum BleAction {
  read,
  write,
  writeNoRsp,
  subscribe,
  unsubscribe,
}

class BleOperate {
  final BleAction action;
  final BluetoothCharacteristic characteristic;
  final List<int>? data;
  final ValueChanged<List<int>>? onData;

  BleOperate({required this.action, required this.characteristic, this.data, this.onData});

  Future<dynamic> handle() {
    if (action == BleAction.read) {
      return characteristic.read().then((value) => onData!(value));
    } else if (action == BleAction.write || action == BleAction.writeNoRsp) {
      return characteristic.write(data!, withoutResponse: action == BleAction.writeNoRsp);
    } else {
      return characteristic.setNotifyValue(action == BleAction.subscribe).then((value) {
        if (onData != null) onData!([value ? 1 : 0]);
      });
    }
  }
}

class BleQueue {
  final List<BleOperate> _queue = [];
  bool _busy = false;

  void clear() {
    _queue.clear();
    _busy = false;
  }

  void read(BluetoothCharacteristic characteristic, ValueChanged<List<int>> onData) {
    _queue.add(BleOperate(action: BleAction.read, characteristic: characteristic, onData: onData));
    _handleQueue();
  }

  void write(BluetoothCharacteristic characteristic, List<int> data, {bool noRsp = false}) {
    _queue.add(BleOperate(
      action: noRsp ? BleAction.writeNoRsp : BleAction.write,
      characteristic: characteristic,
      data: data,
    ));
    _handleQueue();
  }

  void subscribe(BluetoothCharacteristic characteristic, ValueChanged<List<int>> onData) {
    _queue.add(BleOperate(action: BleAction.subscribe, characteristic: characteristic, onData: onData));
    _handleQueue();
  }

  void unsubscribe(BluetoothCharacteristic characteristic) {
    _queue.add(BleOperate(action: BleAction.unsubscribe, characteristic: characteristic));
    _handleQueue();
  }

  void _handleQueue() {
    if (_queue.isNotEmpty && !_busy) {
      _busy = true;
      BleOperate operate = _queue.removeAt(0);
      operate.handle().then((value) {
        // 增加了延时操作，避免频繁交互
        Future.delayed(const Duration(milliseconds: 120), () {
          _busy = false;
          _handleQueue();
        });
      }).onError((error, stackTrace) {
        blePrint(error.toString());
        Future.delayed(const Duration(milliseconds: 120), () {
          _busy = false;
          _handleQueue();
        });
      });
    }
  }
}
