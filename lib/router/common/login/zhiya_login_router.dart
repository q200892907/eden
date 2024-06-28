import 'package:eden/router/eden_router.dart';
import 'package:eden/router/eden_routes.dart';

// 登录页
const TypedGoRoute loginRoute = TypedGoRoute<LoginRoute>(
  path: EdenRouter.login,
  routes: <TypedGoRoute<GoRouteData>>[],
);
