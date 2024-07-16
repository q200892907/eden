import 'dart:async';

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
                registWriteCharacterListener();
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
  BluetoothCharacteristic? _writeCharacter1;
  BluetoothCharacteristic? _notifyCharacter1;
  StreamSubscription<List<int>>? _write1CharacterSubscription;
  StreamSubscription<List<int>>? _notify1CharacterSubscription;
  Timer? _batteryTimer;

  void registWriteCharacterListener() {
    final String writeKey = Guid(CHARACTERISTIC_WRITE).toString();
    if (_characteristics.containsKey(writeKey)) {
      _writeCharacter = _characteristics[writeKey];
    }

    final String notifyKey = Guid(CHARACTERISTIC_NOTIFY).toString();
    if (_characteristics.containsKey(notifyKey)) {
      _notifyCharacter = _characteristics[notifyKey];
    }

    final String write1Key = Guid(CHARACTERISTIC_WRITE1).toString();
    if (_characteristics.containsKey(write1Key)) {
      _writeCharacter1 = _characteristics[write1Key];
    }

    final String notify1Key = Guid(CHARACTERISTIC_NOTIFY1).toString();
    if (_characteristics.containsKey(notify1Key)) {
      _notifyCharacter1 = _characteristics[notify1Key];
    }


    _queue.subscribe(_writeCharacter!, (value) {
      blePrint('device battery subscribe, data = $value');
    });

    _writeCharacterSubscription = _writeCharacter!.lastValueStream.listen((event) {
      blePrint('WriteCharacter Receive: $event');
      // final int batteryValue = BleUtils.listToBattery(event);
      // ref.read(bleDeviceBatteryProvider.notifier).setState(batteryValue);
      // blePrint('device battery notify, battery = $batteryValue, data = $event');
    });

    _notifyCharacterSubscription = _notifyCharacter!.lastValueStream.listen((event) {
      blePrint('NotifyCharacter Receive: $event');
      // final int batteryValue = BleUtils.listToBattery(event);
      // ref.read(bleDeviceBatteryProvider.notifier).setState(batteryValue);
      // blePrint('device battery notify, battery = $batteryValue, data = $event');
    });

    _write1CharacterSubscription = _writeCharacter1!.lastValueStream.listen((event) {
      blePrint('NotifyCharacter Receive: $event');
      // final int batteryValue = BleUtils.listToBattery(event);
      // ref.read(bleDeviceBatteryProvider.notifier).setState(batteryValue);
      // blePrint('device battery notify, battery = $batteryValue, data = $event');
    });

    _notify1CharacterSubscription = _notifyCharacter1!.lastValueStream.listen((event) {
      blePrint('NotifyCharacter Receive: $event');
      // final int batteryValue = BleUtils.listToBattery(event);
      // ref.read(bleDeviceBatteryProvider.notifier).setState(batteryValue);
      // blePrint('device battery notify, battery = $batteryValue, data = $event');
    });
  }

  void initBatteryService() {
    _executeBatteryTask();
    _batteryTimer = Timer.periodic(const Duration(seconds: 10), (Timer t) => _executeBatteryTask());
    blePrint('device init battery service ${blueDevice.remoteId}');
  }

  void _executeBatteryTask() {
    if (_writeCharacter != null) {
      final List<int> bytes = [0x55, 0x0];
      _queue.write(_writeCharacter!, bytes, noRsp: true);
    }
  }

  BluetoothCharacteristic? _pressureCharacter;
  StreamSubscription<List<int>>? _pressureSubscription;

  void startSubscribePressure() {
    if (_characteristics.containsKey(CHARACTERISTIC_PRESSURE)) {
      _pressureCharacter = _characteristics[CHARACTERISTIC_PRESSURE];

      blePrint('device start pressure service, device = ${blueDevice.id}, character = ${_pressureCharacter?.uuid}');

      if (_pressureCharacter == null) return;
      if (_pressureCharacter!.isNotifying) return;
      _queue.subscribe(_pressureCharacter!, (value) {
        if (value[0] == 1) {
          _pressureSubscription = _pressureCharacter!.value.listen((event) {
            final int pressureValue = _revisePressure(BleUtils.listToPressure(event).toDouble());
            ref.read(bleDevicePressureProvider.notifier).setState(pressureValue);
            blePrint('device pressure pressureValue = $pressureValue, data = $value');
          });
        }
      });
    }
  }

  int _revisePressure(double pressure) {
    if (pressure < 0) {
      pressure = -pressure;
    }
    if (pressure > 1330) {
      pressure = 1330;
    }

    if (_model.pid == "MP_JK") {
      pressure *= 0.6;
      double m = pressure / 1000; /* 承重(kg) */
      double g = 10; /* 重力加速度 */
      double F = m * g;
      double S = 0.0002; /* 受力面积 */
      double p = F / S; /* 压强 */
      double mmHg = p / 133.0;
      pressure = mmHg;
    } else if (_model.pid == "MP_JKS") {
      pressure *= 0.15;
    } else if (_model.pid.contains("MP2")) {
      pressure *= 0.5;
    }

    if (pressure <= 10) pressure = 0;
    if (pressure > 199) pressure = 199;

    return pressure.toInt();
  }

  void stopSubscribePressure() {
    blePrint('device start pressure service, device = ${blueDevice.id}, character = ${_pressureCharacter?.uuid}');

    if (_pressureCharacter == null) return;
    if (!_pressureCharacter!.isNotifying) return;
    _queue.unsubscribe(_pressureCharacter!);
    _pressureSubscription?.cancel();
  }

  // ignore: prefer_final_fields
  int _prePressure = 0;

  int get prePressure => _prePressure;

  bool get isDualMotor => _characteristics.containsKey(CHARACTERISTIC_DUAL_MOTOR);

  void motor(List<int> pwm) {
    if (pwm.length != 2) return;

    if (pwm[0] == -1 && pwm[1] == -1) {
      if (_characteristics.containsKey(CHARACTERISTIC_MOTOR_END)) {
        _queue.write(_characteristics[CHARACTERISTIC_MOTOR_END]!, [isDualMotor ? 2 : 0]);
      }
    } else {
      if (pwm[0] < 0) pwm[0] = 0;
      if (pwm[0] > 100) pwm[0] = 100;
      if (pwm[1] < 0) pwm[0] = 0;
      if (pwm[1] > 100) pwm[0] = 100;

      if (isDualMotor) {
        _queue.write(_characteristics[CHARACTERISTIC_DUAL_MOTOR]!, pwm, noRsp: true);
      } else if (_characteristics.containsKey(CHARACTERISTIC_MOTOR)) {
        _queue.write(_characteristics[CHARACTERISTIC_MOTOR]!, [pwm[0]], noRsp: true);
      }
    }
  }

  void light(int pwm) {
    if (pwm == -1) {
      if (_characteristics.containsKey(CHARACTERISTIC_LIGHT_END)) {
        _queue.write(_characteristics[CHARACTERISTIC_LIGHT_END]!, []);
      }
    } else {
      if (pwm < 0) pwm = 0;
      if (pwm > 100) pwm = 100;
      if (_characteristics.containsKey(CHARACTERISTIC_LIGHT)) {
        _queue.write(_characteristics[CHARACTERISTIC_LIGHT]!, [pwm], noRsp: true);
      }
    }
  }

  void disconnect() {
    _batteryTimer?.cancel();
    _batteryTimer = null;

    blueDevice.disconnect();
    ref.read(bleDeviceBatteryProvider.notifier).setState(-1);
    ref.read(bleDevicePressureProvider.notifier).setState(0);

    _writeCharacterSubscription?.cancel();
    _pressureSubscription?.cancel();
    _queue.clear();
  }
}
