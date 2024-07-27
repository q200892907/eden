import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ble_constants.dart';
import 'ble_manager_provider.dart';
import 'ble_model.dart';
import 'ble_queue.dart';
import 'ble_utils.dart';

class BleDevice {
  final BluetoothDevice blueDevice;
  NotifierProviderRef<BleDevice?> ref;

  bool hasNewDianJi = false;
  bool hasHeat = false;
  bool hasBreath = false;
  bool hasPaiDa = false;
  bool hasShenSuo = false;
  bool hasSuck = false;

  /// 马达编号（即马达数，默认为0）
  int motorNum = 0;

  final BleQueue _queue = BleQueue();

  final BleModel _model = BleModel();
  final Map<String, BluetoothService> _services = {};
  final Map<String, BluetoothCharacteristic> _characteristics = {};

  BleDevice(this.blueDevice, this.ref);

  BleModel get model => _model;

  Future<bool> init() {
    blePrint("device discover service, device = ${blueDevice.remoteId}");
    return Future.delayed(const Duration(milliseconds: 100)).then((value) => blueDevice.discoverServices().then((value) {
          blePrint("device discover service callback, device = ${blueDevice.remoteId}, value = $value");
          for (BluetoothService service in value) {
            _services[service.uuid.toString()] = service;
            for (var characteristic in service.characteristics) {
              bool a = characteristic.properties.write;
              bool b = characteristic.properties.read;
              bool c = characteristic.properties.writeWithoutResponse;
              print('aa: a = $a & b = $b & c = $c');
              _characteristics[characteristic.uuid.toString()] = characteristic;
            }
          }

          return Future.delayed(const Duration(milliseconds: 100)).then((value) => _fetchInfo().then((value) {
                registNotifyCharacteristicsListener();
                registWriteCharacteristicsListener();
                initBatteryService();
                return value;
              }));
        }));
  }

  Future<bool> _fetchInfo() {
    blePrint("device fetch info, device = ${blueDevice.remoteId}");
    return Future.value(true);
  }

  BluetoothCharacteristic? _writeCharacter;
  BluetoothCharacteristic? _notifyCharacter;
  StreamSubscription<List<int>>? _writeCharacterSubscription;
  StreamSubscription<List<int>>? _notifyCharacterSubscription;
  Timer? _batteryTimer;

  void registNotifyCharacteristicsListener() {
    final String notifyKey = Guid(CHARACTERISTIC_NOTIFY).toString();
    if (_characteristics.containsKey(notifyKey)) {
      _notifyCharacter = _characteristics[notifyKey];
      _notifyCharacter!.setNotifyValue(true);
    }

    _queue.subscribe(_notifyCharacter!, (value) {
      blePrint('NotifyCharacter subscribe, data = $value');
    });

    _notifyCharacterSubscription = _notifyCharacter!.lastValueStream.listen((data) {
      blePrint('NotifyCharacter Receive: $data');

      if (data.length >= 6 && (data[0] & 0xff) == 0x55 && (data[1] & 0xff) == 0x80) {
        final int battery = (data[5] & 0xff);
        ref.read(bleDeviceBatteryProvider.notifier).setState(battery);
        blePrint('device battery notify, battery = $battery');
        motorNum = data[2];
      }
    });
  }

  void registWriteCharacteristicsListener() {
    final String writeKey = Guid(CHARACTERISTIC_WRITE).toString();
    if (_characteristics.containsKey(writeKey)) {
      _writeCharacter = _characteristics[writeKey];
    }

    _queue.subscribe(_writeCharacter!, (value) {
      blePrint('WriteCharacter subscribe, data = $value');
    });

    _writeCharacterSubscription = _writeCharacter!.lastValueStream.listen((event) {
      blePrint('WriteCharacter Receive: $event');
    });
  }

  void initBatteryService() {
    _executeBatteryTask();
    _batteryTimer = Timer.periodic(const Duration(seconds: 60), (Timer t) => _executeBatteryTask());
    blePrint('device init battery service ${blueDevice.remoteId}');
  }

  void _executeBatteryTask() {
    if (_writeCharacter != null) {
      final List<int> bytes = [0x55, 0x0];
      _queue.write(_writeCharacter!, bytes, noRsp: true);
    }
  }

  /// 模式类震动
  ///
  /// [mode] 模式，取值1~10
  /// [strong] 强度，取值1~10
  void modeMotor(int mode, int strong) {
    assert(mode >= 1 && mode <= 10, 'mode 必须在 1 到 10 之间');
    assert(strong >= 1 && strong <= 10, 'strong 必须在 1 到 10 之间');
    if (_writeCharacter != null) {
      final List<int> bytes = [0x55, 0x3, motorNum & 0xff, 0x0, mode & 0xff, strong & 0xff];
      _queue.write(_writeCharacter!, bytes, noRsp: true);
    }
  }

  /// 停止模式类震动
  void stopModeMotor() {
    if (_writeCharacter != null) {
      final List<int> bytes = [0x55, 0x3, 0x0, 0x0, 0x0, 0x0];
      _queue.write(_writeCharacter!, bytes, noRsp: true);
    }
  }

  /// 交互类震动——滑屏
  ///
  /// [touchY] Y坐标
  /// [height] 控件高度
  void touchActionMotor(num touchY, num height) {
    if (_writeCharacter != null) {
      final List<int> bytes = [0x55, 0x4, motorNum & 0xff, 0x0, 0x0, (touchY / height * 255).round() & 0xff, 0xAA];
      _queue.write(_writeCharacter!, bytes, noRsp: true);
    }
  }

  /// 交互类震动——滑屏——暴走模式
  void rampageActionMotor() {
    if (_writeCharacter != null) {
      final List<int> bytes = [0x55, 0x4, motorNum & 0xff, 0x0, 0x0, 0xff, 0xAA];
      _queue.write(_writeCharacter!, bytes, noRsp: true);
    }
  }

  /// 交互类震动——音乐模式
  ///
  /// [pcm] PCM数据
  void musicMotor(num pcm) {
    if (_writeCharacter != null) {
      final List<int> bytes = [0x55, 0x4, motorNum & 0xff, 0x0, 0x0, min((pcm * 255).round(), 255) & 0xff, 0xAA];
      _queue.write(_writeCharacter!, bytes, noRsp: true);
    }
  }

  /// 交互类震动——声音模式
  ///
  /// [intensity] 强度
  void soundMotor(num intensity) {
    if (_writeCharacter != null) {
      final List<int> bytes = [0x55, 0x4, motorNum & 0xff, 0x0, 0x0, (intensity * 255).round() & 0xff, 0xAA];
      _queue.write(_writeCharacter!, bytes, noRsp: true);
    }
  }

  /// 停止交互类震动
  void stopActionMotor() {
    if (_writeCharacter != null) {
      final List<int> bytes = [0x55, 0x4, motorNum & 0xff, 0x0, 0x0, 0x0, 0xAA];
      _queue.write(_writeCharacter!, bytes, noRsp: true);
    }
  }

  /// 吮吸模式
  ///
  /// [mode] 模式，取值1~10
  void suckMotor(int mode) {
    assert(mode >= 1 && mode <= 10, 'mode 必须在 1 到 10 之间');
    if (_writeCharacter != null) {
      final List<int> bytes = [0x55, 0x9, 0x0, 0x0, mode & 0xff, 0x0];
      _queue.write(_writeCharacter!, bytes, noRsp: true);
    }
  }

  /// 停止吮吸模式
  void stopSuckMotor() {
    if (_writeCharacter != null) {
      final List<int> bytes = [0x55, 0x9, 0x0, 0x0, 0x0, 0x0];
      _queue.write(_writeCharacter!, bytes, noRsp: true);
    }
  }

  //
  // BluetoothCharacteristic? _pressureCharacter;
  // StreamSubscription<List<int>>? _pressureSubscription;
  //
  // void startSubscribePressure() {
  //   if (_characteristics.containsKey(CHARACTERISTIC_PRESSURE)) {
  //     _pressureCharacter = _characteristics[CHARACTERISTIC_PRESSURE];
  //
  //     blePrint('device start pressure service, device = ${blueDevice.id}, character = ${_pressureCharacter?.uuid}');
  //
  //     if (_pressureCharacter == null) return;
  //     if (_pressureCharacter!.isNotifying) return;
  //     _queue.subscribe(_pressureCharacter!, (value) {
  //       if (value[0] == 1) {
  //         _pressureSubscription = _pressureCharacter!.value.listen((event) {
  //           final int pressureValue = _revisePressure(BleUtils.listToPressure(event).toDouble());
  //           ref.read(bleDevicePressureProvider.notifier).setState(pressureValue);
  //           blePrint('device pressure pressureValue = $pressureValue, data = $value');
  //         });
  //       }
  //     });
  //   }
  // }
  //
  // int _revisePressure(double pressure) {
  //   if (pressure < 0) {
  //     pressure = -pressure;
  //   }
  //   if (pressure > 1330) {
  //     pressure = 1330;
  //   }
  //
  //   if (_model.pid == "MP_JK") {
  //     pressure *= 0.6;
  //     double m = pressure / 1000; /* 承重(kg) */
  //     double g = 10; /* 重力加速度 */
  //     double F = m * g;
  //     double S = 0.0002; /* 受力面积 */
  //     double p = F / S; /* 压强 */
  //     double mmHg = p / 133.0;
  //     pressure = mmHg;
  //   } else if (_model.pid == "MP_JKS") {
  //     pressure *= 0.15;
  //   } else if (_model.pid.contains("MP2")) {
  //     pressure *= 0.5;
  //   }
  //
  //   if (pressure <= 10) pressure = 0;
  //   if (pressure > 199) pressure = 199;
  //
  //   return pressure.toInt();
  // }
  //
  // void stopSubscribePressure() {
  //   blePrint('device start pressure service, device = ${blueDevice.id}, character = ${_pressureCharacter?.uuid}');
  //
  //   if (_pressureCharacter == null) return;
  //   if (!_pressureCharacter!.isNotifying) return;
  //   _queue.unsubscribe(_pressureCharacter!);
  //   _pressureSubscription?.cancel();
  // }
  //
  // // ignore: prefer_final_fields
  // int _prePressure = 0;
  //
  // int get prePressure => _prePressure;
  //
  //
  //
  // void motor(List<int> pwm) {
  //   if (pwm.length != 2) return;
  //
  //   if (pwm[0] == -1 && pwm[1] == -1) {
  //     if (_characteristics.containsKey(CHARACTERISTIC_MOTOR_END)) {
  //       _queue.write(_characteristics[CHARACTERISTIC_MOTOR_END]!, [motorNum ? 2 : 0]);
  //     }
  //   } else {
  //     if (pwm[0] < 0) pwm[0] = 0;
  //     if (pwm[0] > 100) pwm[0] = 100;
  //     if (pwm[1] < 0) pwm[0] = 0;
  //     if (pwm[1] > 100) pwm[0] = 100;
  //
  //     if (motorNum) {
  //       _queue.write(_characteristics[CHARACTERISTIC_DUAL_MOTOR]!, pwm, noRsp: true);
  //     } else if (_characteristics.containsKey(CHARACTERISTIC_MOTOR)) {
  //       _queue.write(_characteristics[CHARACTERISTIC_MOTOR]!, [pwm[0]], noRsp: true);
  //     }
  //   }
  // }
  //
  // void light(int pwm) {
  //   if (pwm == -1) {
  //     if (_characteristics.containsKey(CHARACTERISTIC_LIGHT_END)) {
  //       _queue.write(_characteristics[CHARACTERISTIC_LIGHT_END]!, []);
  //     }
  //   } else {
  //     if (pwm < 0) pwm = 0;
  //     if (pwm > 100) pwm = 100;
  //     if (_characteristics.containsKey(CHARACTERISTIC_LIGHT)) {
  //       _queue.write(_characteristics[CHARACTERISTIC_LIGHT]!, [pwm], noRsp: true);
  //     }
  //   }
  // }

  void disconnect() {
    _batteryTimer?.cancel();
    _batteryTimer = null;

    blueDevice.disconnect();
    ref.read(bleDeviceBatteryProvider.notifier).setState(-1);
    ref.read(bleDevicePressureProvider.notifier).setState(0);

    _writeCharacterSubscription?.cancel();
    _notifyCharacterSubscription?.cancel();
    // _pressureSubscription?.cancel();
    _queue.clear();
  }
}
