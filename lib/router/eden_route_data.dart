import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

abstract class EdenRouteData extends GoRouteData {
  const EdenRouteData();

  Widget buildBody(BuildContext context, GoRouterState state);

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return CupertinoPage(
      key: state.pageKey,
      child: buildBody(context, state),
    );
  }
}

abstract class EdenShellRouteData extends ShellRouteData {
  const EdenShellRouteData();

  Widget buildBody(BuildContext context, GoRouterState state, Widget navigator);

  @override
  Page<void> pageBuilder(
      BuildContext context, GoRouterState state, Widget navigator) {
    return CupertinoPage(
      key: state.pageKey,
      child: buildBody(context, state, navigator),
    );
  }
}

abstract class EdenStatefulShellRouteData extends StatefulShellRouteData {
  const EdenStatefulShellRouteData();

  Widget buildBody(BuildContext context, GoRouterState state,
      StatefulNavigationShell navigationShell);

  @override
  Page<void> pageBuilder(BuildContext context, GoRouterState state,
      StatefulNavigationShell navigationShell) {
    return CupertinoPage(
      key: state.pageKey,
      child: buildBody(context, state, navigationShell),
    );
  }
}
