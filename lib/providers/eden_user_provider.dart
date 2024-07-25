import 'package:eden/utils/chart_util.dart';
import 'package:eden_database/eden_database.dart';
import 'package:eden_service/eden_service.dart';
import 'package:eden_uikit/eden_uikit.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'eden_user_provider.g.dart';

@Riverpod(keepAlive: true)
class EdenUserNotifier extends _$EdenUserNotifier {
  EdenUserNotifier() {
    // 监听更新
    EdenAccountService.instance.addChanged((user) {
      state = user;
      _handle();
    });
  }

  @override
  EdenObxAccount? build() {
    return null;
  }

  /// 是否是登录状态
  bool get isLogin => state != null;

  /// 在闪屏页调用，判断是否已登录等操作
  /// 返回true,则存在用户，返回false则不存在
  Future<bool> init() async {
    return EdenAccountService.instance.init().then((value) {
      if (value.isSuccess) {
        state = EdenAccountService.instance.account;
        _handle();
      }
      return value.isSuccess;
    });
  }

  /// 登录逻辑
  Future<EdenServiceState<EdenObxAccount>> login() async {
    return EdenAccountService.instance.login().then(
      (value) {
        if (value.isSuccess) {
          state = value.data;
          _handle();
        }
        return value;
      },
    );
  }

  /// 处理绑定操作、连接操作
  void _handle() {
    ChartUtil.instance.init(state?.id ?? '');
  }

  /// 退出逻辑
  Future<bool> logout(BuildContext context) async {
    EdenObxAccount? account =
        context.read(edenUserNotifierProvider.select((select) => select));
    return EdenAccountService.instance.logout().then((value) {
      if (value.isSuccess) {}
      return value.isSuccess;
    }).then((value) {
      if (value) {
        Future.delayed(const Duration(milliseconds: 100)).then(
          (value) {
            //todo 跳转登录
          },
        );
      }
      return value;
    });
  }

  /// 获取用户信息
  void getUserDetail() {}

  /// 更新信息，用于修改结束后的通知
  void updateAccount() {
    state = EdenAccountService.instance.account;
  }
}
