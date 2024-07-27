// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'eden_routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
      $splashRoute,
      $loginRoute,
      $rootShellRoute,
      $playRoute,
    ];

RouteBase get $splashRoute => GoRouteData.$route(
      path: '/splash',
      factory: $SplashRouteExtension._fromState,
    );

extension $SplashRouteExtension on SplashRoute {
  static SplashRoute _fromState(GoRouterState state) => const SplashRoute();

  String get location => GoRouteData.$location(
        '/splash',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $loginRoute => GoRouteData.$route(
      path: '/login',
      factory: $LoginRouteExtension._fromState,
    );

extension $LoginRouteExtension on LoginRoute {
  static LoginRoute _fromState(GoRouterState state) => const LoginRoute();

  String get location => GoRouteData.$location(
        '/login',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $rootShellRoute => StatefulShellRouteData.$route(
      factory: $RootShellRouteExtension._fromState,
      branches: [
        StatefulShellBranchData.$branch(
          routes: [
            GoRouteData.$route(
              path: '/home',
              factory: $HomeRouteExtension._fromState,
            ),
          ],
        ),
        StatefulShellBranchData.$branch(
          routes: [
            GoRouteData.$route(
              path: '/ai',
              factory: $CommunityRouteExtension._fromState,
            ),
          ],
        ),
        StatefulShellBranchData.$branch(
          routes: [
            GoRouteData.$route(
              path: '/ai',
              factory: $AiRouteExtension._fromState,
            ),
          ],
        ),
        StatefulShellBranchData.$branch(
          routes: [
            GoRouteData.$route(
              path: '/personage',
              factory: $PersonageRouteExtension._fromState,
            ),
          ],
        ),
      ],
    );

extension $RootShellRouteExtension on RootShellRoute {
  static RootShellRoute _fromState(GoRouterState state) =>
      const RootShellRoute();
}

extension $HomeRouteExtension on HomeRoute {
  static HomeRoute _fromState(GoRouterState state) => const HomeRoute();

  String get location => GoRouteData.$location(
        '/home',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $CommunityRouteExtension on CommunityRoute {
  static CommunityRoute _fromState(GoRouterState state) =>
      const CommunityRoute();

  String get location => GoRouteData.$location(
        '/ai',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $AiRouteExtension on AiRoute {
  static AiRoute _fromState(GoRouterState state) => const AiRoute();

  String get location => GoRouteData.$location(
        '/ai',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $PersonageRouteExtension on PersonageRoute {
  static PersonageRoute _fromState(GoRouterState state) =>
      const PersonageRoute();

  String get location => GoRouteData.$location(
        '/personage',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $playRoute => GoRouteData.$route(
      path: '/play',
      factory: $PlayRouteExtension._fromState,
      routes: [
        GoRouteData.$route(
          path: 'touch',
          factory: $PlayTouchRouteExtension._fromState,
        ),
        GoRouteData.$route(
          path: 'auto',
          factory: $PlayAutoRouteExtension._fromState,
        ),
        GoRouteData.$route(
          path: 'sound',
          factory: $PlaySoundRouteExtension._fromState,
        ),
      ],
    );

extension $PlayRouteExtension on PlayRoute {
  static PlayRoute _fromState(GoRouterState state) => const PlayRoute();

  String get location => GoRouteData.$location(
        '/play',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $PlayTouchRouteExtension on PlayTouchRoute {
  static PlayTouchRoute _fromState(GoRouterState state) =>
      const PlayTouchRoute();

  String get location => GoRouteData.$location(
        '/play/touch',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $PlayAutoRouteExtension on PlayAutoRoute {
  static PlayAutoRoute _fromState(GoRouterState state) => const PlayAutoRoute();

  String get location => GoRouteData.$location(
        '/play/auto',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $PlaySoundRouteExtension on PlaySoundRoute {
  static PlaySoundRoute _fromState(GoRouterState state) =>
      const PlaySoundRoute();

  String get location => GoRouteData.$location(
        '/play/sound',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}
