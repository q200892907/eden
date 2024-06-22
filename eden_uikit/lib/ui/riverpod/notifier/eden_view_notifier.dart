import 'package:eden_uikit/eden_uikit.dart';
import 'package:flutter/material.dart';

import 'eden_base_notifier.dart';

/// 单数据源
abstract class EdenViewStateNotifier<T> extends EdenBaseStateNotifier<T>
    with
        EdenRetryNotifier,
        WidgetsBindingObserver,
        EdenNotifierWidgetsBindingObserver {
  bool get autoInit => true;
  bool _requesting = false;

  /// 初始化，默认状态为idle
  EdenViewStateNotifier() {
    addObserver();
    if (autoInit) {
      init();
    }
  }

  @override
  void dispose() {
    removeObserver();
    super.dispose();
  }

  T? _data;

  T? get data => _data;

  bool get autoEmpty => true; //自动空布局

  /// 自动加载数据
  void init() async {
    refreshStatus = EdenStateRefreshStatus.init;
    // 更改页面状态为loading
    setLoading();
    // 判断网络状态
    if (await checkNet()) {
      // 无网络，显示无网络状态
      setNoNetwork();
      // return;
    }
    await _fetchData(fetch: true);
  }

  /// 刷新数据
  Future refresh() async {
    refreshStatus = EdenStateRefreshStatus.refresh;
    await _fetchData();
  }

  @override
  void setEmpty() {
    _data = null;
    super.setEmpty();
  }

  @override
  void setReady(T data) {
    _data = data;
    super.setReady(data);
  }

  @override
  int get retryMaxNum => 2;

  @override
  void retry() async {
    _fetchData();
  }

  @override
  void backgroundReturnRefresh(EdenNotifierRefreshType type) {
    if (type != EdenNotifierRefreshType.normal) {
      retry();
    }
  }

  /// 真实逻辑
  _fetchData({bool fetch = false}) async {
    if (_requesting) {
      return;
    }
    _requesting = true;
    try {
      EdenStateNotifierEntity<T> temp = await loadData();
      if (temp.isSuccess && temp.data != null) {
        _data = temp.data;
        if (((_data is List && (data as List).isEmpty) ||
                (_data is Map && (_data as Map).isEmpty)) &&
            autoEmpty) {
          setEmpty();
        } else {
          setReady(_data as T);
        }
      } else {
        setError(error: temp.message ?? '');

        bool isToast = true;
        if (!temp.isFirstToast && fetch) {
          isToast = false;
        }

        /// 自动提示消息
        if (temp.autoToast && temp.isMessage && isToast) {
          EdenToast.failed(temp.message ?? '');
        }
      }
    } catch (e) {
      setError(error: e.toString());
    }
    _requesting = false;
  }

  // 获取数据源
  Future<EdenStateNotifierEntity<T>> loadData();
}
