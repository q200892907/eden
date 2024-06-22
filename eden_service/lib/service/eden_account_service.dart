import 'dart:async';

import 'package:eden_database/eden_database.dart';
import 'package:eden_service/api/eden_api.dart';
import 'package:eden_service/config/eden_server_config.dart';

import 'eden_base_service.dart';

/// 账号服务
class EdenAccountService extends EdenBaseService {
  factory EdenAccountService() => _getInstance();

  static EdenAccountService get instance => _getInstance();
  static EdenAccountService? _instance;

  late EdenUserClient _userClient;

  EdenAccountService._internal() {
    initService();
  }

  @override
  void initService() {
    super.initService();
    _userClient = EdenUserClient(
      EdenApi.dio,
      baseUrl: EdenServerConfig.server.apiUrl,
    );
  }

  static EdenAccountService _getInstance() {
    _instance ??= EdenAccountService._internal();
    return _instance!;
  }

  /// 当前账号
  EdenObxAccount? _account;

  bool _isLogging = false; //是否正在登录

  EdenObxAccount? get account => _account;

  /// 是否是登录状态
  bool get isLogin => _account != null;

  Completer<EdenServiceState<EdenObxAccount>>? _completer;

  /// 在闪屏页调用，判断是否已登录等操作，同步刷新token，刷新token时间3秒，未刷新成功则直接放回当前用户
  /// 返回true,则存在用户，返回false则不存在
  Future<EdenServiceState<EdenObxAccount>> init() async {
    bool isInit =
        await EdenObjectBox.instance.init(EdenServerConfig.server.objectbox);
    if (isInit) {
      EdenServiceState<EdenObxAccount> state = getCurrentAccount();
      if (state.isSuccess) {
        _account = state.data;
        if (_completer != null) {
          return _completer!.future;
        }
        _completer = Completer();
        Future.delayed(const Duration(seconds: 3), () {
          if (_completer != null && !_completer!.isCompleted) {
            _completer!.complete(state);
            _completer = null;
          }
        });
        return _completer!.future;
      }
      return state;
    }
    return EdenServiceState(isSuccess: false);
  }

  /// 获取当前用户
  EdenServiceState<EdenObxAccount> getCurrentAccount() {
    EdenObxAccount? temp = EdenObjectBox.instance.getCurrentAccount();
    return EdenServiceState(isSuccess: temp != null, data: temp);
  }

  /// 登录逻辑
  /// [params] 登录参数
  Future<EdenServiceState<EdenObxAccount>> login() async {
    if (_isLogging) {
      return EdenServiceState(isSuccess: false);
    }
    _isLogging = true;
    EdenServiceState<EdenObxAccount> res;
    //todo 调用接口
    res = await _userClient.login({}).convert();
    if (!res.isSuccess) {
      _isLogging = false;
      return EdenServiceState(isSuccess: false, message: res.message);
    }
    if (res.data == null) {
      _isLogging = false;
      return EdenServiceState(isSuccess: false, message: res.message);
    }
    EdenObxAccount account = res.data!;
    // 保存最后一次登录用户信息
    await EdenObjectBox.instance.saveLastUserId(account.id);
    // 初始化数据库
    bool create = await EdenObjectBox.instance.create(account.id);
    if (!create) {
      return EdenServiceState(isSuccess: false);
    }
    bool success = updateAccount(account);
    if (success) {
      _isLogging = false;
      return EdenServiceState(isSuccess: true, data: _account);
    }
    _isLogging = false;
    return EdenServiceState(isSuccess: false);
  }

  bool updateAccount(EdenObxAccount account) {
    // 录入数据
    int id = EdenObjectBox.instance.insertAccount(account);
    // 更新登录状态
    EdenObjectBox.instance.updateLoginStatus(id: account.id, isLogin: true);
    if (id > 0) {
      _isLogging = false;
      // 更新状态
      _account = account;
      return true;
    }
    return false;
  }

  /// 退出逻辑
  Future<EdenServiceState> logout() async {
    if (_account == null) {
      return EdenServiceState(isSuccess: true);
    }
    EdenObjectBox.instance.updateLoginStatus(id: _account!.id, isLogin: false);
    // 更新状态
    _account = null;
    return EdenServiceState(isSuccess: true);
  }

  /// 更新用户信息
  bool _updateAccount(EdenObxAccount account) {
    account = account.copyWith(isLogin: true);
    int id = EdenObjectBox.instance.insertAccount(account);
    if (id > 0) {
      _account = account;
      return true;
    }
    return false;
  }
}
