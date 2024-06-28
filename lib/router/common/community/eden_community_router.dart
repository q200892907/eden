import 'package:eden/pages/community/community_page.dart';
import 'package:eden/router/eden_router.dart';
import 'package:flutter/material.dart';

const TypedGoRoute communityRoute = TypedGoRoute<CommunityRoute>(
  path: EdenRouter.ai,
  routes: [],
);

// community
class CommunityRoute extends EdenRouteData {
  const CommunityRoute();

  @override
  Widget buildBody(BuildContext context, GoRouterState state) =>
      const CommunityPage();
}
