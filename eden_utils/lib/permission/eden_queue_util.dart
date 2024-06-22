import 'dart:async';

///
/// 自实现任务队列工具类
///
class EdenQueueUtil {
  EdenQueueUtil._();

  /// 用map key存储多个QueueUtil单例,目的是隔离多个类型队列任务互不干扰
  static final Map<String, EdenQueueUtil> _instance = <String, EdenQueueUtil>{};

  static EdenQueueUtil get(String key) {
    if (_instance[key] == null) {
      _instance[key] = EdenQueueUtil._();
    }
    return _instance[key]!;
  }

  List<ZhiyaQueueTaskInfo> _taskList = <ZhiyaQueueTaskInfo>[];
  bool _isTaskRunning = false;
  int _mId = 0;
  bool _isCancelQueue = false;

  Future<ZhiyaQueueTaskInfo> addTask(Function doSomething) {
    _isCancelQueue = false;
    _mId++;
    final ZhiyaQueueTaskInfo taskInfo = ZhiyaQueueTaskInfo(_mId, doSomething);

    /// 创建future
    final Completer<ZhiyaQueueTaskInfo> taskCompleter =
        Completer<ZhiyaQueueTaskInfo>();

    /// 创建当前任务stream
    final StreamController<ZhiyaQueueTaskInfo> streamController =
        StreamController<ZhiyaQueueTaskInfo>();
    taskInfo.controller = streamController;

    /// 添加到任务队列
    _taskList.add(taskInfo);

    /// 当前任务的stream添加监听
    streamController.stream.listen((ZhiyaQueueTaskInfo completeTaskInfo) {
      if (completeTaskInfo.id == taskInfo.id) {
        taskCompleter.complete(completeTaskInfo);
        streamController.close();
      }
    });

    /// 触发任务
    _doTask();

    return taskCompleter.future;
  }

  void cancelTask() {
    _taskList = <ZhiyaQueueTaskInfo>[];
    _isCancelQueue = true;
    _mId = 0;
    _isTaskRunning = false;
  }

  void _doTask() async {
    if (_isTaskRunning) {
      return;
    }
    if (_taskList.isEmpty) {
      return;
    }

    /// 取任务
    final ZhiyaQueueTaskInfo taskInfo = _taskList[0];
    _isTaskRunning = true;

    /// 模拟执行任务
    await taskInfo.doSomething?.call();

    taskInfo.controller?.sink.add(taskInfo);

    if (_isCancelQueue) {
      return;
    }

    /// 出队列
    _taskList.removeAt(0);
    _isTaskRunning = false;

    /// 递归执行任务
    _doTask();
  }
}

class ZhiyaQueueTaskInfo {
  ZhiyaQueueTaskInfo(this.id, this.doSomething);

  int id; // 任务唯一标识
  Function? doSomething;
  StreamController<ZhiyaQueueTaskInfo>? controller;
}
