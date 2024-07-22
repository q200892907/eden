import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:eden/socket/listeners/eden_socket_listener.dart';
import 'package:eden_internet_connection_checker/eden_internet_connection_checker.dart';
import 'package:eden_logger/eden_logger.dart';
import 'package:eden_utils/eden_utils.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

export 'listeners/eden_socket_listener.dart';


class EdenSocket
    with WidgetsBindingObserver
    implements EdenInternetConnectionListener {
  factory EdenSocket() => _getInstance();

  static EdenSocket get instance => _getInstance();
  static EdenSocket? _instance;

  EdenSocket._internal() {
    WidgetsBinding.instance.addObserver(this);
    EdenInternetConnection.instance.addListener(this);
  }

  static EdenSocket _getInstance() {
    _instance ??= EdenSocket._internal();
    return _instance!;
  }

  IOWebSocketChannel? _channel;
  StreamSubscription? _subscription;
  final Map<String, Set<int>> _receivedMessages = {};//todo 已接收集合
  final Set<EdenSocketListener> _listeners = {};
  late String _url;
  Map<String, dynamic>? _headers;
  bool _isClose = true;

  final ValueNotifier<bool> _connected =
      ValueNotifier(false); //使用ValueNotifier来记录，可以在后续的页面中使用监听来进行展示
  ValueNotifier<bool> get connected => _connected;
  static const List<int> _reconnectIntervals = [
    1,
    1000,
    5000,
    10000,
    15000,
    30000
  ]; //连接间隔
  int _reconnectCount = 0;
  int _reconnectIntervalNum = 1; //当前连接间隔下标
  Timer? _reconnectTimer; //重连计时器
  bool _isForeground = true;

  bool get _isMobile =>
      Platform.isAndroid || Platform.isIOS; // 暂时只支持android/ios的前后台操作

  void addListener(EdenSocketListener listener) {
    _listeners.add(listener);
  }

  void removeListener(EdenSocketListener listener) {
    _listeners.remove(listener);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (!_isMobile) {
      return;
    }
    if (state == AppLifecycleState.resumed) {
      //前台 自动重连
      EdenLogger.d('EdenSocket进入前台，自动重连');
      _isForeground = true;
      _reconnect();
    } else if (state == AppLifecycleState.hidden) {
      // 后台 自动关闭socket
      _realClose();
      _isForeground = false;
      EdenLogger.d('EdenSocket进入后台，关闭重连机制，关闭连接');
    }
  }

  // 网络状态变更
  @override
  void onInternetConnectionChanged(InternetStatus status) {
    // 如果当前未连接且网络状态变为连接后，直接触发重连
    if (!_connected.value &&
        status == InternetStatus.connected &&
        _isForeground) {
      _realClose();
      _reconnect();
    }
  }

  /// 连接方法
  Future<void> connect(String url, {Map<String, dynamic>? headers}) async {
    _isClose = false;
    if (_connected.value) return;
    _url = url;
    _headers = headers;
    if (_url.isEmpty) {
      EdenLogger.e('EdenSocket链接地址错误，请填写正确地址');
      return;
    }

    // todo 连接地址及房间
    String uri = _url;
    EdenLogger.d('EdenSocket连接地址:$uri');

    if (_channel != null && _channel?.sink != null) {
      _channel?.sink.close();
      _channel = null;
    }
    _channel = IOWebSocketChannel.connect(
      uri,
      headers: headers,
      pingInterval: const Duration(milliseconds: 5000),
    );
    _subscription?.cancel();
    _subscription = null;
    _subscription = _channel?.stream.listen((e) {
      EdenLogger.d('EdenSocket接收到消息: $e');
      Map? json;
      if (e is String) {
        if (e.startsWith('{') && e.endsWith('}')) {
          try {
            json = jsonDecode(e);
          } catch (error) {
            EdenLogger.e('EdenSocket消息解析失败: $error');
          }
        }
      } else if (e is Map) {
        json = e;
      }
      if (json != null) {
        // todo 如何判断是否处理过了
        // EdenSocketReceivedMessage message =
        //     EdenSocketReceivedMessage.fromJson(Map.castFrom(json));
        // if (message.type != EdenSocketMessageType.syncMessage) {
        //   String key = message.to.isNotEmpty ? message.to : message.groupId;
        //   int messageSn = message.sn;
        //   if (messageSn != 0 &&
        //       (_receivedMessages[key]?.contains(messageSn) ?? false)) {
        //     EdenLogger.d('EdenSocket消息已处理,${message.sn}');
        //     return;
        //   }
        //   _receivedMessages[key] ??= <int>{};
        //   if (messageSn != 0) {
        //     _receivedMessages[key]?.add(message.sn);
        //   }
        // }
        _onMessage(json);
      }
    }, onError: (e) {
      EdenLogger.e('EdenSocket发生错误: $e');
      _disconnected();
      _reconnect();
    }, onDone: () {
      // 1005 手动关闭
      // 1002 网络问题
      EdenLogger.d('EdenSocket连接关闭:${_channel?.closeCode}');
      _disconnected();
      _reconnect();
    });
    _channel?.ready.then((value) {
      EdenLogger.d('EdenSocket连接到$uri');
      _realConnected();
    });
  }

  void _onMessage(dynamic message) {
    EdenLogger.d('EdenSocket开始处理消息，$message');
    for (var element in _listeners) {
      element.onReceivedMessage(message);
    }
  }

  /// 真实连接成功
  void _realConnected() {
    _reconnectIntervalNum = 1;
    _connected.value = true;
    _connectedNotify();
  }

  final String _key = 'EdenSocket';

  void _connectedNotify() {
    EdenDebounce.debounce(_key, const Duration(seconds: 1), () {
      for (var element in _listeners) {
        element.onSocketConnected();
      }
    });
  }

  void _cancelConnectedNotify() {
    EdenDebounce.cancel(_key);
  }

  /// 关闭连接，外部调用
  /// 同时清空未发送的消息
  void close() {
    _isClose = true;
    _realClose();
    EdenLogger.d('EdenSocket手动关闭连接');
  }

  // 真实关闭
  void _realClose() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _reconnectIntervalNum = 0;
    _reconnectCount = 0;
    _disconnected();
  }

  /// 关闭连接
  void _disconnected() {
    try {
      if (_subscription != null) {
        _subscription?.cancel();
        _subscription = null;
      }
      if (_channel != null && _channel?.sink != null) {
        _channel?.sink.close();
        _channel = null;
      }
    } catch (e) {
      EdenLogger.e('EdenSocket关闭发生错误:$e');
    }
    _connected.value = false;
    _cancelConnectedNotify();
    EdenLogger.d('EdenSocket与$_url关闭连接');
  }

  /// 重连
  void _reconnect() {
    if (_isClose) {
      return;
    }
    if (_reconnectTimer == null) {
      int reconnectInterval = _reconnectIntervals[_reconnectIntervalNum];
      EdenLogger.d(
          'EdenSocket重连中($_reconnectCount), 等待:${reconnectInterval / 1000}s');
      _reconnectTimer = Timer(Duration(milliseconds: reconnectInterval), () {
        _reconnectTimer?.cancel();
        _reconnectTimer = null;
        _reconnectIntervalNum += 1;
        _reconnectCount += 1; //设置重连次数
        _reconnectIntervalNum =
            min(_reconnectIntervals.length - 1, _reconnectIntervalNum);
        connect(_url, headers: _headers);
      });
    }
  }
}
