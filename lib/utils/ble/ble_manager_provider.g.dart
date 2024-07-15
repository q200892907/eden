// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ble_manager_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$bleStateHash() => r'1f9ed7fb273a607d2e7c0f8840bf4e96987ba325';

///
/// 蓝牙管理相关Provider
///
/// Created by Jack Zhang on 2023/5/10 .
///
///
/// Copied from [BleState].
@ProviderFor(BleState)
final bleStateProvider =
    NotifierProvider<BleState, BluetoothAdapterState>.internal(
  BleState.new,
  name: r'bleStateProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$bleStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BleState = Notifier<BluetoothAdapterState>;
String _$bleDeviceStateHash() => r'150d408beb9d1ede4d8e833d17a13d78a96d1ffa';

/// See also [BleDeviceState].
@ProviderFor(BleDeviceState)
final bleDeviceStateProvider =
    NotifierProvider<BleDeviceState, BleDevice?>.internal(
  BleDeviceState.new,
  name: r'bleDeviceStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$bleDeviceStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BleDeviceState = Notifier<BleDevice?>;
String _$bleDeviceBatteryHash() => r'33c631364fcbe23d6187ca1895f9bfb2988654a7';

/// See also [BleDeviceBattery].
@ProviderFor(BleDeviceBattery)
final bleDeviceBatteryProvider =
    NotifierProvider<BleDeviceBattery, int>.internal(
  BleDeviceBattery.new,
  name: r'bleDeviceBatteryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$bleDeviceBatteryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BleDeviceBattery = Notifier<int>;
String _$bleDevicePressureHash() => r'995cab494e1f0d57b7e987692e6798bebb4bd9ea';

/// See also [BleDevicePressure].
@ProviderFor(BleDevicePressure)
final bleDevicePressureProvider =
    NotifierProvider<BleDevicePressure, int>.internal(
  BleDevicePressure.new,
  name: r'bleDevicePressureProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$bleDevicePressureHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BleDevicePressure = Notifier<int>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
