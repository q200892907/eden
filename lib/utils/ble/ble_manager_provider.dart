import 'dart:async';
import 'dart:io';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'ble_device.dart';
import 'ble_model.dart';
import 'ble_utils.dart';

export 'package:flutter_blue_plus/flutter_blue_plus.dart';

part 'ble_manager_provider.g.dart';

///
/// 蓝牙管理相关Provider
///
/// Created by Jack Zhang on 2023/5/10 .
///

@Riverpod(keepAlive: true)
class BleState extends _$BleState {
  /// 蓝牙状态监听器
  StreamSubscription? _stateSubscription;

  @override
  BluetoothAdapterState build() {
    return BluetoothAdapterState.unknown;
  }

  /// 获取当前蓝牙状态
  Future<BluetoothAdapterState> fetchState() async {
    if (await FlutterBluePlus.isSupported == false) {
      state = BluetoothAdapterState.unavailable;
      return state;
    }
    _stateSubscription?.cancel();
    blePrint('fetch state $state');
    state = await FlutterBluePlus.adapterState.first;
    blePrint('fetch state result $state');
    ref.read(bleDeviceStateProvider.notifier).init();
    _stateSubscription = FlutterBluePlus.adapterState.listen(onBluetoothStateChange);

    // turn on bluetooth ourself if we can
    // for iOS, the user controls bluetooth enable/disable
    if (state == BluetoothAdapterState.off && Platform.isAndroid) {
      await FlutterBluePlus.turnOn();
    }
    return state;
  }

  void onBluetoothStateChange(BluetoothAdapterState bluetoothState) {
    blePrint('on state change $bluetoothState');
    if (state != bluetoothState) {
      state = bluetoothState;
      switch (bluetoothState) {
        case BluetoothAdapterState.on:
          ref.read(bleDeviceStateProvider.notifier).judgeAutoScan();
          break;

        case BluetoothAdapterState.off:
          ref.read(bleDeviceStateProvider.notifier).disconnectBleDevice();
          break;

        default:
      }
    }
  }
}

@Riverpod(keepAlive: true)
class BleDeviceState extends _$BleDeviceState {
  /// 是否正在扫描
  bool _scanning = false;

  bool get scanning => _scanning;

  /// 是否正在运行，该状态位为true时，才可真正扫描设备
  bool _running = false;

  /// 是否自动扫描蓝牙
  bool _autoScan = false;

  set autoScan(bool value) {
    _autoScan = value;
    blePrint('BleDeviceState set autoScan $value');
  }

  bool get autoScan => _autoScan;

  /// 蓝牙准备连接状态
  bool _readyToConnect = false;

  /// 蓝牙是否已连接
  bool get isConnected => state != null;

  /// 蓝牙设备信息
  BleModel? get deviceModel => state?.model;

  /// 蓝牙设备状态监听器
  StreamSubscription<BluetoothConnectionState>? _subscriptionDevice;

  /// 蓝牙扫描结果监听器
  StreamSubscription<List<ScanResult>>? _scanResultsSubscription;

  /// 蓝牙扫描状态监听器
  StreamSubscription<bool>? _isScanningSubscription;

  List<BluetoothDevice> _systemDevices = [];

  BleDevice? _bleDevice;

  @override
  BleDevice? build() {
    return null;
  }

  /// 由蓝牙状态改变触发——判断是否需要自动开始扫描
  void judgeAutoScan() {
    if (autoScan) {
      _scan();
    }
  }

  /// 由蓝牙状态改变触发——断开蓝牙设备连接
  void disconnectBleDevice() {
    _scanning = false;
    _readyToConnect = false;
    FlutterBluePlus.stopScan();
    state?.disconnect();
    state = null;
    _subscriptionDevice?.cancel();
    _subscriptionDevice = null;
    _isScanningSubscription?.cancel();
    _isScanningSubscription = null;
    _scanResultsSubscription?.cancel();
    _scanResultsSubscription = null;
  }

  void init() {
    FlutterBluePlus.setLogLevel(LogLevel.verbose, color: false);

    _isScanningSubscription?.cancel();
    _scanResultsSubscription?.cancel();

    _isScanningSubscription = FlutterBluePlus.isScanning.listen((state) {
      _scanning = state;
    });
    _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) async {
      if (!_running || _readyToConnect) {
        return;
      }
      if (results.isNotEmpty) {
        final ScanResult item = results.last;
        if (item.advertisementData.manufacturerData.isNotEmpty) {
          final List<int> firstManufacturerData = item.advertisementData.manufacturerData.values.first;
          if (firstManufacturerData.length >= 12 &&
              (firstManufacturerData[0] & 0xff) == 0x53 &&
              (firstManufacturerData[1] & 0xff) == 0x56 &&
              (firstManufacturerData[2] & 0xff) == 0x41) {
            _readyToConnect = true;
            blePrint("scan result, success, device = $item");
            await _connect(item.device, manufacturerData: firstManufacturerData);
          }
        } else {
          blePrint("scan result, device = $item");
        }
      }
    }, onError: (e) {
      blePrint("Ble Scan Error: $e");
    });
  }

  /// 开始扫描
  Future _scan() async {
    final BluetoothAdapterState state = ref.read(bleStateProvider);
    blePrint("scan, state = $state, scanning = $_scanning, running = $_running");
    if (state == BluetoothAdapterState.on && !_scanning && _running) {
      _scanning = true;
      // TODO 暂时不考虑已连接的设备
      // try {
      //   _systemDevices = await FlutterBluePlus.systemDevices;
      //   blePrint("Ble SystemDevices: $_systemDevices");
      // } catch (e) {
      //   blePrint("Ble Scan Error: $e");
      // }
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
    }
    return Future.value(null);
  }

  /// 连接蓝牙设备
  Future _connect(BluetoothDevice device, {List<int>? manufacturerData}) {
    blePrint("connecting, device = $device");
    _readyToConnect = false;
    bool timeout = false;
    return device.disconnect().then((value) {
      return device.connect(autoConnect: false).timeout(const Duration(seconds: 20), onTimeout: () async {
        blePrint("connect timeout, device = $device");
        timeout = true;
        await device.disconnect();
      }).then((value) async {
        if (timeout) {
          return Future.value(null);
        }
        BleDevice bleDevice = BleDevice(device, ref);
        if (manufacturerData != null && manufacturerData.isNotEmpty) {
          int function = (manufacturerData[11] & 0xff);
          bleDevice.hasNewDianJi = ((function & 1) == 1 ? true : false);
          bleDevice.hasHeat = (((function >> 1) & 1) == 1 ? true : false);
          bleDevice.hasBreath = (((function >> 2) & 1) == 1 ? true : false);
          bleDevice.hasPaiDa = (((function >> 3) & 1) == 1 ? true : false);
          bleDevice.hasShenSuo = (((function >> 4) & 1) == 1 ? true : false);
          bleDevice.hasSuck = (((function >> 5) & 1) == 1 ? true : false);
        }
        _bleDevice = bleDevice;
        return bleDevice.init().then((value) {
          blePrint("device init callback, result = $value");
          if (!value) {
            // if (!bleDevice.model.isCompleted) {
            //   blePrint('device info incomplete ${state?.model}');
            // }
            bleDevice.disconnect();
          } else {
            state = bleDevice;
            _subscriptionDevice = device.connectionState.listen(onDeviceStateChange);
          }
          return state;
        }).timeout(const Duration(seconds: 10), onTimeout: () {
          device.disconnect();
          blePrint("init timeout, device = $device");
          return null;
        }).onError((error, stackTrace) {
          device.disconnect();
          blePrint('init error:$error stack$stackTrace');
          return null;
        });
      }).onError((error, stackTrace) {
        device.disconnect();
        blePrint('connect error:$error stack$stackTrace');
        return null;
      });
    }).onError((error, stackTrace) {
      blePrint('disconnect error:$error stack$stackTrace');
      return null;
    });
  }

  void onDeviceStateChange(BluetoothConnectionState deviceState) {
    blePrint('on device state change $deviceState');
    if (deviceState == BluetoothConnectionState.connected) {
      blePrint("connect success, device = $_bleDevice");
      //  连接蓝牙成功，保存玩具已绑定状态，此状态在退出登录时需置为false，WowAccountNotifier logout方法已添加
      BleUtils.saveToyBindState(true);
    } else if (deviceState == BluetoothConnectionState.disconnected) {
      stop();
      if (autoScan) {
        start();
      }
    }
  }

  /// 由已连接的蓝牙设备断开连接触发，重新开始扫描
  Future start() async {
    blePrint("start, running = $_running");
    _running = true;
    return _scan();
  }

  /// 由已连接的蓝牙设备断开连接触发，停止监听并断开连接
  void stop() {
    blePrint("stop, running = $_running");
    if (_running) {
      _running = false;
      _scanning = false;
      FlutterBluePlus.stopScan();
      state?.disconnect();
      state = null;
      _bleDevice = null;
      _subscriptionDevice?.cancel();
      _subscriptionDevice = null;
    }
  }
}

@Riverpod(keepAlive: true)
class BleDeviceBattery extends _$BleDeviceBattery {
  @override
  int build() {
    return -1;
  }

  void setState(int value) {
    state = value;
  }
}

@Riverpod(keepAlive: true)
class BleDevicePressure extends _$BleDevicePressure {
  @override
  int build() {
    return 0;
  }

  void setState(int value) {
    state = value;
  }
}
