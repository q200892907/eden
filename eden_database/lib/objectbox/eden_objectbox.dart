import 'dart:io';

import 'package:eden_database/objectbox.g.dart';
import 'package:eden_database/objectbox/account/eden_obx_account.dart';
import 'package:eden_database/objectbox/chart/eden_obx_chart.dart';
import 'package:eden_logger/eden_logger.dart';
import 'package:eden_service/eden_service.dart';
import 'package:eden_utils/eden_utils.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

export 'account/eden_obx_account.dart';
export 'account/eden_obx_account_extension.dart';
export 'chart/eden_obx_chart.dart';
export 'chart/eden_obx_chart_extension.dart';

/// objectbox用户相关信息的实现
class EdenObjectBox {
  // 工厂模式
  factory EdenObjectBox() => _getInstance();

  EdenObjectBox._internal();

  static EdenObjectBox get instance => _getInstance();
  static EdenObjectBox? _instance;

  static EdenObjectBox _getInstance() {
    _instance ??= EdenObjectBox._internal();
    return _instance!;
  }

  static final String _accountKey =
      '${EdenServerConfig.isRelease ? '' : '${EdenServerConfig.envType.name}_'}_account_id_key'; //最后一次登录的用户的key

  static late String _obxStore; //主数据的名称

  static const String macosApplicationGroup = '';

  bool _isInit = false;

  String? userId; //当前读取的用户

  Store? _store; // 主数据Store

  late Box<EdenObxAccount> accountBox; //用户信息box
  late Box<EdenObxChart> chartBox;
  late Box<EdenObxChartPoint> chartPointBox;

  void _log(Object object) {
    EdenLogger.d('$runtimeType@$hashCode - $object');
  }

  bool get isInit => _isInit;

  /// 初始化
  /// 自动读取最后一次登录用户，并初始化数据
  Future<bool> init(String databaseName, {String? userId}) async {
    _obxStore = databaseName;
    //读取最后一次登录的用户信息
    userId ??= _getLastUserId();
    if (userId.isNotEmpty) {
      _log('最后一次使用的用户id:$userId');
      return await create(userId);
    } else {
      _log('最后一次使用的用户id:无');
    }
    //没有信息告知初始化失败，用户不存在
    return false;
  }

  /// 移除最后一个用户
  Future<bool> deleteLastUserId() {
    return EdenSpUtil.remove(_accountKey) ?? Future.value(true);
  }

  /// 存储最后一个用户的id
  Future<bool> saveLastUserId(String userId) {
    this.userId = userId;
    return EdenSpUtil.putString(_accountKey, userId) ?? Future.value(false);
  }

  /// 获取最后一个用户的id
  String _getLastUserId() {
    return EdenSpUtil.getString(_accountKey);
  }

  /// 数据初始化
  Future<bool> create(String userId) async {
    if (_isInit) {
      await dispose();
    }

    String path = p.join(
      (await getApplicationSupportDirectory()).path,
    );
    Directory directory = Directory(path);
    bool isExists = await directory.exists();
    if (!isExists) {
      _log('创建文件路径:$path');
      await directory.create();
    }
    path = p.join(path, _obxStore);
    _log('数据库地址:$path');
    _log('正在打开数据库...');
    // 打开数据库
    final store = await openStore(
      directory: path,
      macosApplicationGroup: EdenObjectBox.macosApplicationGroup,
    );
    _store = store;
    // 数据库不存在，则返回失败
    if (_store == null) {
      _isInit = false;
      _log('数据库打开失败');
      return false;
    }
    _log('数据库打开成功');
    // 数据库存在，则初始化各box
    accountBox = Box<EdenObxAccount>(_store!);
    chartBox = Box<EdenObxChart>(_store!);
    chartPointBox = Box<EdenObxChartPoint>(_store!);
    _isInit = true;
    return true;
  }

  /// 数据销毁
  Future<bool> dispose() async {
    _store?.close();
    _store = null;
    _isInit = false;
    return true;
  }
}
