import 'package:eden_database/objectbox.g.dart';

import '../eden_objectbox.dart';

extension EdenObxAccountExtension on EdenObjectBox {
  /// 获取登录的全部账号
  List<EdenObxAccount> getAllAccount() {
    final query = accountBox.query().build();
    List<EdenObxAccount> accounts = query.find();
    query.close();
    return accounts;
  }

  /// 移除全部账号信息
  int deleteAllAccount() {
    return accountBox.removeAll();
  }

  /// 获取当前登录的账号信息
  EdenObxAccount? getCurrentAccount() {
    final query =
        accountBox.query(EdenObxAccount_.isLogin.equals(true)).build();
    EdenObxAccount? account = query.findFirst();
    query.close();
    return account;
  }

  /// 获取账号信息
  /// [id] 账号id
  EdenObxAccount? getAccountByUserId({required String id}) {
    final query = accountBox.query(EdenObxAccount_.id.equals(id)).build();
    EdenObxAccount? account = query.findFirst();
    query.close();
    return account;
  }

  /// 删除信息
  int deleteAccountByUserId({required String id}) {
    final query = accountBox.query(EdenObxAccount_.id.equals(id)).build();
    int index = accountBox.removeMany(query.findIds());
    query.close();
    return index;
  }

  /// 插入用户信息，根据账号类型更新
  /// [account] 账号信息
  int insertAccount(EdenObxAccount account) {
    deleteAccountByUserId(id: account.id);
    return accountBox.put(account);
  }

  /// 更新登录状态,[id]账号表示已登录
  /// [id] 用户信息
  List<int> updateLoginStatus({required String id, bool isLogin = true}) {
    //获取全部账号
    List<EdenObxAccount> accounts = getAllAccount();
    if (accounts.isEmpty) {
      return [];
    }
    //更新isLogin信息
    List<EdenObxAccount> tempAccounts = [];
    for (var element in accounts) {
      if (element.id == id) {
        EdenObxAccount account = element.copyWith(isLogin: isLogin);
        tempAccounts.add(account);
      } else {
        EdenObxAccount account = element.copyWith(isLogin: false);
        tempAccounts.add(account);
      }
    }
    // 更新数据库
    return accountBox.putMany(tempAccounts);
  }
}
