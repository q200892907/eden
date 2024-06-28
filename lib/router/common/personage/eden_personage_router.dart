import 'package:eden/pages/personage/personage_page.dart';
import 'package:eden/router/eden_router.dart';
import 'package:flutter/material.dart';

const TypedGoRoute personageRoute = TypedGoRoute<PersonageRoute>(
  path: EdenRouter.personage,
  routes: [],
);

// personage
class PersonageRoute extends EdenRouteData {
  const PersonageRoute();

  @override
  Widget buildBody(BuildContext context, GoRouterState state) =>
      const PersonagePage();
}
