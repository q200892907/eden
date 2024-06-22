import 'dart:async';

import 'package:eden_internet_connection_checker/eden_internet_connection_checker.dart';
import 'package:eden_uikit/ui/riverpod/state/eden_view_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

export 'eden_list_view_notifier.dart';
export 'eden_view_notifier.dart';

enum EdenStateRefreshStatus {
  init,
  refresh,
  loadMore,
}

/// 状态回调封装实体
class EdenStateNotifierEntity<T> {
  final T? data; //数据
  final bool isSuccess; //是否成功
  final String? message; //是否失败
  final bool autoToast; //自动提示
  final bool isFirstToast; //页面第一次是否提示

  bool get isMessage => message != null && message?.trim() != ''; //是否存在消息

  EdenStateNotifierEntity({
    this.data,
    required this.isSuccess,
    this.message,
    this.autoToast = true,
    this.isFirstToast = false,
  });
}

abstract class EdenBaseStateNotifier<T> extends StateNotifier<EdenViewState<T>>
    with NetworkStatusBinding {
  EdenBaseStateNotifier() : super(EdenViewState<T>.idle());

  EdenStateRefreshStatus refreshStatus = EdenStateRefreshStatus.init;

  void setState(EdenViewState<T> value) {
    /// 安全设置
    if (mounted) {
      state = value;
    }
  }

  /// 变更为loading态
  void setLoading() {
    setState(EdenViewState<T>.loading());
  }

  /// 变更为empty态
  void setEmpty() {
    setState(EdenViewState<T>.empty());
  }

  /// 变更为error态
  void setError(
      {EdenViewStateErrorType errorType = EdenViewStateErrorType.normal,
      String? error}) {
    setState(EdenViewState<T>.error(errorType: errorType, error: error));
  }

  /// 变更为idle态
  void setIdle({bool updateUI = true}) {
    setState(EdenViewState<T>.idle());
  }

  /// 变更为完成态
  void setReady(T data) {
    setState(EdenViewState<T>.ready(data));
  }

  /// 变更为无网络态
  void setNoNetwork() {
    setError(errorType: EdenViewStateErrorType.network);
  }
}

/// 绑定context
mixin BuildContextBinding<T> on StateNotifier<T> {
  late BuildContext context;

  void bindContext(BuildContext context) {
    this.context = context;
  }
}

/// 混入网络检查
mixin NetworkStatusBinding<T> on StateNotifier<T> {
  ///检查网络状态
  Future<bool> checkNet() async {
    return EdenInternetConnection.instance.isInternetStatus
        .then((value) => !value);
  }
}

enum EdenNotifierRefreshType {
  normal, //正常，无需刷新
  error, //错误
  timeout, //后台时间过长
}

mixin EdenNotifierWidgetsBindingObserver<T>
    on EdenBaseStateNotifier<T>, WidgetsBindingObserver {
  EdenNotifierRefreshType _type = EdenNotifierRefreshType.normal;
  DateTime? _enterBackgroundTime;

  void addObserver() {
    WidgetsBinding.instance.addObserver(this);
  }

  void removeObserver() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void setReady(data) {
    _type = EdenNotifierRefreshType.normal;
    super.setReady(data);
  }

  @override
  void setError(
      {EdenViewStateErrorType errorType = EdenViewStateErrorType.normal,
      String? error}) {
    _type = EdenNotifierRefreshType.error;
    super.setError(errorType: errorType, error: error);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState appLifecycleState) {
    super.didChangeAppLifecycleState(appLifecycleState);
    if (appLifecycleState == AppLifecycleState.resumed) {
      //前台 自动刷新
      if (_type == EdenNotifierRefreshType.normal &&
          _enterBackgroundTime != null) {
        int time = DateTime.now().difference(_enterBackgroundTime!).inMinutes;
        if (time > 30) {
          backgroundReturnRefresh(EdenNotifierRefreshType.timeout);
        }
      } else {
        backgroundReturnRefresh(_type);
      }
      _enterBackgroundTime = null;
    } else if (appLifecycleState == AppLifecycleState.paused) {
      _enterBackgroundTime = DateTime.now();
    }
  }

  void backgroundReturnRefresh(EdenNotifierRefreshType type);
}

mixin EdenRetryNotifier<T> on EdenBaseStateNotifier<T> {
  int get retryMaxNum => 0; //最大次数

  int _retryNum = 0; //当前重试次数

  Duration get retryDuration => const Duration(seconds: 3); //重试间隔

  bool get _isRetry => _retryNum < retryMaxNum; //是否还可以重试

  Timer? _retryTimer;

  @override
  void setReady(data) {
    _retryNum = 0;
    _cancelRetry();
    super.setReady(data);
  }

  @override
  void setError({
    EdenViewStateErrorType errorType = EdenViewStateErrorType.normal,
    String? error,
  }) {
    super.setState(
      EdenViewState<T>.error(
        errorType: errorType,
        error: error,
      ),
    );
    if (_isRetry && errorType != EdenViewStateErrorType.network) {
      _cancelRetry();
      _retryTimer = Timer(retryDuration, () {
        _retryNum++;
        retry();
        _cancelRetry();
      });
    }
  }

  void _cancelRetry() {
    _retryTimer?.cancel();
    _retryTimer = null;
  }

  @override
  void dispose() {
    _cancelRetry();
    super.dispose();
  }

  void retry();
}

/// 混入刷新控制器
mixin RefreshControllerBinding<T> on EdenBaseStateNotifier<T> {
  RefreshController? _refreshController;

  RefreshController? get refreshController => _refreshController;

  void bindController(RefreshController controller) {
    _refreshController = controller;
  }

  @override
  void setReady(data) {
    super.setReady(data);
    if (refreshStatus == EdenStateRefreshStatus.refresh) {
      _refreshController?.refreshCompleted();
    } else {
      _refreshController?.loadComplete();
    }
  }

  @override
  void setEmpty() {
    super.setEmpty();
    if (refreshStatus == EdenStateRefreshStatus.refresh) {
      _refreshController?.refreshCompleted();
    } else {
      _refreshController?.loadComplete();
    }
  }

  @override
  void setError(
      {EdenViewStateErrorType errorType = EdenViewStateErrorType.normal,
      String? error}) {
    super.setError(error: error, errorType: errorType);
    if (refreshStatus == EdenStateRefreshStatus.refresh) {
      _refreshController?.refreshFailed();
    } else {
      _refreshController?.loadFailed();
    }
  }
}
