library eden_internet_connection_checker;

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import 'listener/eden_internet_connection_listener.dart';

export 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

export 'listener/eden_internet_connection_listener.dart';
export 'widgets/eden_internet_connection_builder.dart';

/// 检测网络连接真实情况
class EdenInternetConnection {
  factory EdenInternetConnection() => _getInstance();

  static EdenInternetConnection get instance => _getInstance();
  static EdenInternetConnection? _instance;

  static ResponseStatusFn responseStatusFn = (response) {
    return response.statusCode >= 200 && response.statusCode < 500;
  };

  EdenInternetConnection._internal();

  static EdenInternetConnection _getInstance() {
    _instance ??= EdenInternetConnection._internal();
    return _instance!;
  }

  /// 用于builder使用
  final ValueNotifier<InternetStatus> _connectionNotifier =
      ValueNotifier(InternetStatus.connected);

  ValueNotifier<InternetStatus> get connectionNotifier => _connectionNotifier;

  StreamSubscription<InternetStatus>? _streamSubscription;

  final Set<EdenInternetConnectionListener> _listeners = {};

  InternetConnection? _internetConnection;

  /// 添加监听
  void addListener(EdenInternetConnectionListener listener) {
    _listeners.add(listener);
  }

  /// 移除监听
  void removeListener(EdenInternetConnectionListener listener) {
    _listeners.remove(listener);
  }

  /// 清空监听
  void _clearListener() {
    _listeners.clear();
  }

  /// 初始化
  /// [checkOptions] 检测网络使用的配置，如不添加则使用默认配置
  void init({
    List<InternetCheckOption> checkOptions = const [],
  }) {
    _internetConnection = InternetConnection.createInstance(
      checkInterval: const Duration(seconds: 10),
      customCheckOptions: [
        ...checkOptions,
        InternetCheckOption(
          uri: Uri.parse('https://1.1.1.1/'),
          timeout: const Duration(seconds: 30),
          responseStatusFn: responseStatusFn,
        ),
        InternetCheckOption(
          uri: Uri.parse('https://8.8.8.8/'),
          timeout: const Duration(seconds: 30),
          responseStatusFn: responseStatusFn,
        ),
        InternetCheckOption(
          uri: Uri.parse('https://www.baidu.com/'),
          timeout: const Duration(seconds: 30),
          responseStatusFn: responseStatusFn,
        ),
        InternetCheckOption(
          uri: Uri.parse('https://www.qq.com/'),
          timeout: const Duration(seconds: 30),
          responseStatusFn: responseStatusFn,
        ),
      ],
      useDefaultOptions: false,
    );
    _streamSubscription =
        _internetConnection?.onStatusChange.listen((InternetStatus status) {
      // print('当前网络状态');
      // print(status);
      // 通知所有builder网络变化
      _connectionNotifier.value = status;
      // 通知所有监听位置网络变化
      for (var element in _listeners) {
        element.onInternetConnectionChanged(status);
      }
    });
  }

  /// 取消监听
  void cancel() {
    _streamSubscription?.cancel();
    _streamSubscription = null;
    _clearListener();
  }

  /// 是否连接网络了
  Future<bool> get isInternetStatus {
    if (_internetConnection == null) {
      init();
    }
    if (_connectionNotifier.value == InternetStatus.connected) {
      return Future.value(true);
    }
    return _internetConnection?.hasInternetAccess ?? Future.value(false);
  }
}
