import 'package:eden_uikit/eden_uikit.dart';
import 'package:flutter/material.dart';

import 'eden_base_notifier.dart';

/// 列表数据源
abstract class EdenListViewStateNotifier<T>
    extends EdenBaseStateNotifier<List<T>>
    with
        RefreshControllerBinding,
        EdenRetryNotifier,
        WidgetsBindingObserver,
        EdenNotifierWidgetsBindingObserver {
  EdenListViewStateNotifier() {
    if (autoInit) {
      _initData();
    }
    addObserver();
  }

  bool get autoInit => true;

  @override
  void dispose() {
    removeObserver();
    super.dispose();
  }

  /// 分页第一页页码
  final int pageNumFirst = 1;

  /// 分页条目数量
  int get pageSize => 10;

  /// 页面数据
  List<T> _items = [];

  List<T> get items => _items;

  /// 第一次加载
  bool firstInit = true;
  bool _requesting = false;

  /// 当前页码
  int _currentPageNum = 1;

  int get currentPageNum => _currentPageNum;

  /// 自动加载数据
  void _initData() async {
    refreshStatus = EdenStateRefreshStatus.init;
    // 更改页面状态为loading
    setLoading();
    // 判断网络状态
    if (await checkNet()) {
      // 无网络，显示无网络状态
      setNoNetwork();
      // return;
    }
    await refresh(init: true);
  }

  Future refresh({bool init = false}) async {
    refreshStatus = EdenStateRefreshStatus.refresh;
    _currentPageNum = pageNumFirst;
    await _fetchData(true, _currentPageNum, init: init);
  }

  /// 上拉加载更多
  Future loadMore() async {
    refreshStatus = EdenStateRefreshStatus.loadMore;
    await _fetchData(false, ++_currentPageNum);
  }

  @override
  int get retryMaxNum => 2;

  @override
  void retry() async {
    /// 重试 如果已加载过就不重试了
    if (items.isEmpty) {
      _fetchData(true, pageNumFirst, init: true);
    }
  }

  @override
  void backgroundReturnRefresh(EdenNotifierRefreshType type) {
    if (type != EdenNotifierRefreshType.normal) {
      retry();
    }
  }

  _fetchData(bool refresh, int pageNum, {bool init = false}) async {
    if (_requesting) {
      return;
    }
    _requesting = true;
    try {
      EdenStateNotifierEntity<List<T>?> data = await loadData(pageNum: pageNum);
      if (data.isSuccess && data.data != null) {
        if (refresh) {
          if (data.data?.isEmpty ?? false) {
            _items.clear();
            refreshController?.refreshCompleted();
            setEmpty();
          } else {
            _items = data.data!;
            setReady(_items);
            refreshController?.refreshCompleted();
            if (_items.length < pageSize) {
              refreshController?.loadNoData();
            } else {
              //防止上次上拉加载更多失败,需要重置状态
              refreshController?.loadComplete();
            }
          }
        } else {
          if (data.data?.isEmpty ?? false) {
            _currentPageNum--;
            refreshController?.loadNoData();
          } else {
            _items.addAll(data.data ?? []);
            setReady(_items);
            if ((data.data?.length ?? 0) < pageSize) {
              refreshController?.loadNoData();
            } else {
              refreshController?.loadComplete();
            }
          }
        }
      } else {
        if (refresh) {
          if (init) {
            _items.clear();
            setError(error: data.message ?? '');
          } else {
            refreshController?.refreshFailed();
          }
        } else {
          _currentPageNum--;
          refreshController?.loadFailed();
        }

        bool isToast = true;
        if (!data.isFirstToast && init) {
          isToast = false;
        }

        /// 自动提示消息
        if (data.autoToast && data.isMessage && isToast) {
          EdenToast.failed(data.message ?? '');
        }
      }
    } catch (e) {
      if (refresh) {
        refreshController?.refreshFailed();
      } else {
        _currentPageNum--;
        refreshController?.loadFailed();
      }
      setError(error: e.toString());
    }
    _requesting = false;
  }

  @override
  void setReady(data) {
    _items = data.toSet().toList();
    super.setReady(_items);
  }

// 获取数据源
  Future<EdenStateNotifierEntity<List<T>?>> loadData({required int pageNum});
}
