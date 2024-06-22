import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:objectbox/objectbox.dart';

part 'eden_obx_account.freezed.dart';
part 'eden_obx_account.g.dart';

/// 数据库保存的信息
@unfreezed
class EdenObxAccount with _$EdenObxAccount {
  @Entity(realClass: EdenObxAccount)
  factory EdenObxAccount({
    @Id() @Default(0) int localId, //本地id
    required String id, //服务器记录id
    @Default('') String accessToken,
    @Default('') String refreshToken,
    @Default(true) bool isLogin,
  }) = _EdenObxAccount;

  factory EdenObxAccount.fromJson(Map<String, dynamic> json) =>
      _$EdenObxAccountFromJson(json);
}
