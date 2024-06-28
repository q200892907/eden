import 'package:eden/pages/login/login_page.dart';
import 'package:eden/pages/root/root_page.dart';
import 'package:eden/pages/splash/splash_page.dart';
import 'package:eden/router/common/login/zhiya_login_router.dart';
import 'package:eden/router/common/splash/eden_splash_router.dart';
import 'package:eden/router/eden_router.dart';
import 'package:flutter/material.dart';

export 'common/root/eden_root_router.dart';

part 'eden_routes.g.dart';

// 闪屏页
@splashRoute
class SplashRoute extends EdenRouteData {
  const SplashRoute();

  @override
  Widget buildBody(BuildContext context, GoRouterState state) =>
      const SplashPage();
}

@loginRoute
class LoginRoute extends EdenRouteData {
  const LoginRoute();

  @override
  Widget buildBody(BuildContext context, GoRouterState state) =>
      const LoginPage();
}

@rootShellRoute
class RootShellRoute extends EdenStatefulShellRouteData {
  const RootShellRoute();

  @override
  Widget buildBody(BuildContext context, GoRouterState state,
          StatefulNavigationShell navigationShell) =>
      RootPage(
        navigationShell: navigationShell,
      );
}
