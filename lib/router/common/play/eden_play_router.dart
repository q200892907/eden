import 'package:eden/pages/play/touch/play_touch_page.dart';
import 'package:eden/router/eden_router.dart';
import 'package:flutter/material.dart';

const TypedGoRoute playRoute = TypedGoRoute<PlayRoute>(
  path: EdenRouter.play,
  routes: [
    TypedGoRoute<PlayTouchRoute>(
      path: EdenRouter.touch,
    ),
  ],
);

class PlayTouchRoute extends EdenRouteData {
  const PlayTouchRoute();

  @override
  Widget buildBody(BuildContext context, GoRouterState state) =>
      const PlayTouchPage();
}
