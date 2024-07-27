import 'package:eden/pages/play/auto/play_auto_page.dart';
import 'package:eden/pages/play/sound/play_sound_page.dart';
import 'package:eden/pages/play/touch/play_touch_page.dart';
import 'package:eden/router/eden_router.dart';
import 'package:flutter/material.dart';

const TypedGoRoute playRoute = TypedGoRoute<PlayRoute>(
  path: EdenRouter.play,
  routes: [
    TypedGoRoute<PlayTouchRoute>(
      path: EdenRouter.touch,
    ),
    TypedGoRoute<PlayAutoRoute>(
      path: EdenRouter.auto,
    ),
    TypedGoRoute<PlaySoundRoute>(
      path: EdenRouter.sound,
    ),
  ],
);

class PlayTouchRoute extends EdenRouteData {
  const PlayTouchRoute();

  @override
  Widget buildBody(BuildContext context, GoRouterState state) => const PlayTouchPage();
}

class PlayAutoRoute extends EdenRouteData {
  const PlayAutoRoute();

  @override
  Widget buildBody(BuildContext context, GoRouterState state) => const PlayAutoPage();
}

class PlaySoundRoute extends EdenRouteData {
  const PlaySoundRoute();

  @override
  Widget buildBody(BuildContext context, GoRouterState state) => const PlaySoundPage();
}
