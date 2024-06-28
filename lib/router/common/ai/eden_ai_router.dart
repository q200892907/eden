import 'package:eden/pages/ai/ai_page.dart';
import 'package:eden/router/eden_router.dart';
import 'package:flutter/material.dart';

const TypedGoRoute aiRoute = TypedGoRoute<AiRoute>(
  path: EdenRouter.ai,
  routes: [],
);

// ai
class AiRoute extends EdenRouteData {
  const AiRoute();

  @override
  Widget buildBody(BuildContext context, GoRouterState state) => const AiPage();
}
