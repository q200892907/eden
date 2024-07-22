import 'package:eden/main.dart';
import 'package:eden/providers/eden_user_provider.dart';
import 'package:eden/router/eden_routes.dart';
import 'package:eden_uikit/eden_uikit.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

export 'package:go_router/go_router.dart';

export 'eden_route_data.dart';
export 'eden_routes.dart';

class EdenRouter {
  static const String splash = '/splash'; //闪屏路由
  static const String login = '/login'; //登录路由
  static const String web = '/web'; //网页路由
  static const String home = '/home'; // 首页
  static const String community = '/community';
  static const String ai = '/ai';
  static const String personage = '/personage';

  static const String play = '/play'; //玩模式
  static const String touch = 'touch'; //手势
  static const String auto = 'auto'; //自动模式

  static final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();

  /// 用于移动端与桌面端的判断，主要用于跳转的问题
  static GlobalKey<NavigatorState> get navKey => _navKey;

  static GoRouter config = GoRouter(
    debugLogDiagnostics: true,
    initialLocation: splash,
    observers: [
      routeObserver,
    ],
    navigatorKey: _navKey,
    routes: $appRoutes,
    errorBuilder: (_, state) {
      return ErrorRouter(state.error!);
    },
    // redirect to the login page if the user is not logged in
    redirect: (BuildContext context, GoRouterState state) {
      // final bool loggedIn = loginInfo.loggedIn;
      //
      // // check just the matchedLocation in case there are query parameters
      // final String loginLoc = const LoginRoute().location;
      // final bool goingToLogin = state.matchedLocation == loginLoc;
      //
      // // the user is not logged in and not headed to /login, they need to login
      // if (!loggedIn && !goingToLogin) {
      //   return LoginRoute(fromPage: state.matchedLocation).location;
      // }
      //
      // // the user is logged in and headed to /login, no need to login again
      // if (loggedIn && goingToLogin) {
      //   return const HomeRoute().location;
      // }
      //
      // no need to redirect at all
      return null;
    },

    // changes on the listenable will cause the router to refresh it's route
    // refreshListenable: loginInfo,
  );

  /// 判断路由是否存在
  static bool isRouteExists(String location) {
    RouteMatchList routeMatchList = config.configuration.findMatch(location);
    return routeMatchList.isNotEmpty;
  }

  static void popAndPush(BuildContext context, String location,
      {VoidCallback? onPop}) {
    var matches =
        GoRouter.of(context).routerDelegate.currentConfiguration.matches;
    int index = matches.indexWhere(
        (element) => element.matchedLocation == location.split('?').first);
    if (index >= 0) {
      if (index >= matches.length - 1) {
        onPop?.call();
      } else {
        var routeMatch = matches[index + 1];
        RouteMatchList routeMatchList = GoRouter.of(context)
            .routerDelegate
            .currentConfiguration
            .remove(routeMatch);
        GoRouter.of(context).routerDelegate.setNewRoutePath(routeMatchList);
        onPop?.call();
      }
    } else {
      context.push(location);
    }
  }
}

class ErrorRouter extends StatelessWidget {
  const ErrorRouter(this.error, {super.key});

  final Exception error;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SelectableText(error.toString()),
              TextButton(
                onPressed: () {
                  if (context.read(edenUserNotifierProvider.notifier).isLogin) {
                    context.go(EdenRouter.home);
                  } else {
                    context.go(EdenRouter.login);
                  }
                },
                child: const Text('Back'),
              ),
            ],
          ),
        ),
      );
}
