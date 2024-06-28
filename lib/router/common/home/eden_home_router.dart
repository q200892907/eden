import 'package:eden/pages/home/home_page.dart';
import 'package:eden/router/eden_router.dart';
import 'package:flutter/material.dart';

const TypedGoRoute homeRoute = TypedGoRoute<HomeRoute>(
  path: EdenRouter.home,
  routes: [],
);

// home
class HomeRoute extends EdenRouteData {
  const HomeRoute();

  @override
  Widget buildBody(BuildContext context, GoRouterState state) =>
      const HomePage();
}
