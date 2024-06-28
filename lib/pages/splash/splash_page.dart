import 'dart:io';

import 'package:eden/config/eden_config.dart';
import 'package:eden/develop/eden_develop_tools.dart';
import 'package:eden/eden_app.dart';
import 'package:eden/plugin/eden_plugin.dart';
import 'package:eden/providers/eden_user_provider.dart';
import 'package:eden/router/eden_routes.dart';
import 'package:eden_uikit/eden_uikit.dart';
import 'package:flutter/material.dart';

import 'splash_privacy_agreement.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> with EdenDevelopMixin {
  @override
  void initState() {
    super.initState();
    EdenPlugin.instance.initHttpMessage();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // 初始化开发工具
      EdenDevelopTools.instance.init(
        isDebug: EdenConfig.isDebug,
      );
      EdenDevelopTools.instance.show();
    });

    // todo 检查是否同意协议
    // final bool alreadyAgreed = _checkAgreement();
    // if (alreadyAgreed) {
    _push();
    // }
  }

  @override
  Widget build(BuildContext context) {
    appContext = context;
    return Scaffold(
      backgroundColor: Colors.white,
      body: _buildBody(),
    );
  }

  Widget _buildBody([bool bottom = false]) {
    if (bottom) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.only(bottom: 120 + ScreenUtil().bottomBarHeight),
          child: _buildIcon(),
        ),
      );
    }
    return Center(
      child: _buildIcon(),
    );
  }

  Widget _buildIcon() {
    return EdenImage.loadAssetImage(
      '',
      width: Platform.isAndroid || Platform.isIOS ? 104 : 125,
      height: Platform.isAndroid || Platform.isIOS ? 62 : 75,
    );
  }

  /// 检查协议是否同意 （初次安装弹框）
  bool _checkAgreement() {
    final PrivacyAgreementStatus status =
        SplashPrivacyAgreement.isAgreePrivacyAgreement();
    if (status != PrivacyAgreementStatus.none) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _showPrivacyAgreementDialog(status));
    }
    return status == PrivacyAgreementStatus.none;
  }

  /// 展示隐私协议弹框
  void _showPrivacyAgreementDialog(PrivacyAgreementStatus status) async {
    PrivacyAgreementDialog.show(
        context, status, _agreePrivacyAgreementCallback);
  }

  /// 同意隐私协议后回调
  _agreePrivacyAgreementCallback() {
    SplashPrivacyAgreement.setAgreePrivacyAgreement(
        SplashPrivacyAgreement.agreePrivacyAgreementVersion);
    Navigator.pop(context);
    _push();
  }

  // 跳轉
  void _push() {
    EdenPlugin.instance.initTripartitePlugin();

    /// 运行读取用户信息
    ref.read(edenUserNotifierProvider.notifier).init().then((value) {
      // 存在，则进入首页
      if (value) {
        // 自动登录进入主页
        const HomeRoute().go(context);
      } else {
        // 不存在，进入登录页面
        const LoginRoute().go(context);
      }
    });
  }
}
