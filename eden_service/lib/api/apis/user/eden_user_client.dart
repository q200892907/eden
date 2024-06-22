import 'package:dio/dio.dart';
import 'package:eden_database/eden_database.dart';
import 'package:retrofit/retrofit.dart';

import '../../../eden_service.dart';

part 'eden_user_client.g.dart';

@RestApi()
abstract class EdenUserClient {
  factory EdenUserClient(Dio dio, {required String baseUrl}) = _EdenUserClient;

  /// 账号、密码登录接口 ✔️
  @POST('/v1/user/login')
  Future<EdenApiResponse<EdenObxAccount>> login(
      @Body() Map<String, dynamic> req);
}
