import 'package:eden_uikit/eden_uikit.dart';
import 'package:flutter/material.dart';

class SplashPrivacyAgreement {
  static const String _isAgreePrivacyAgreementKey =
      'is_agree_privacy_agreement';

  /// 进入是否同意隐私协议版本号
  static const String _isAgreePrivacyAgreementVersionKey =
      'is_agree_privacy_agreement_version';
  static const String _maxAgreePrivacyAgreementVersionKey =
      'max_agree_privacy_agreement_version';

  /// 当前最大版本协议
  static int get agreePrivacyAgreementVersion =>
      EdenSpUtil.getInt(_maxAgreePrivacyAgreementVersionKey, defValue: 1);

  /// 设置最大版本协议，后期用于接口
  static void setMaxAgreePrivacyAgreementVersion(int version) {
    EdenSpUtil.putInt(_maxAgreePrivacyAgreementVersionKey, version);
  }

  static bool _isAgreePrivacyAgreement() {
    return EdenSpUtil.getBool(_isAgreePrivacyAgreementKey);
  }

  /// 是否同意隐私协议
  static PrivacyAgreementStatus isAgreePrivacyAgreement() {
    final int version =
        EdenSpUtil.getInt(_isAgreePrivacyAgreementVersionKey, defValue: 0);
    if (version == 0) {
      return _isAgreePrivacyAgreement()
          ? PrivacyAgreementStatus.update
          : PrivacyAgreementStatus.newUser;
    }
    return version >= agreePrivacyAgreementVersion
        ? PrivacyAgreementStatus.none
        : PrivacyAgreementStatus.update;
  }

  static void clearAgreePrivacyAgreement() {
    EdenSpUtil.remove(_isAgreePrivacyAgreementVersionKey);
  }

  /// 设置是否同意隐私协议
  static void setAgreePrivacyAgreement(int version) {
    EdenSpUtil.putInt(_isAgreePrivacyAgreementVersionKey, version);
  }
}

enum PrivacyAgreementStatus {
  none, //无需弹出
  newUser, //新用户
  update, //更新了协议
}

/// 隐私协议弹窗
class PrivacyAgreementDialog {
  static show(
    BuildContext context,
    PrivacyAgreementStatus status,
    Function onAgreeTap,
  ) {
    //todo 待实现
  }
}
