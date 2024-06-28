import 'package:eden/router/common/ai/eden_ai_router.dart';
import 'package:eden/router/common/community/eden_community_router.dart';
import 'package:eden/router/common/home/eden_home_router.dart';
import 'package:eden/router/common/personage/eden_personage_router.dart';
import 'package:eden/router/eden_router.dart';

export 'package:eden/router/common/ai/eden_ai_router.dart';
export 'package:eden/router/common/community/eden_community_router.dart';
export 'package:eden/router/common/home/eden_home_router.dart';
export 'package:eden/router/common/personage/eden_personage_router.dart';

const TypedStatefulShellRoute<RootShellRoute> rootShellRoute =
    TypedStatefulShellRoute<RootShellRoute>(
  branches: [
    TypedStatefulShellBranch(
      routes: [homeRoute],
    ),
    TypedStatefulShellBranch(
      routes: [communityRoute],
    ),
    TypedStatefulShellBranch(
      routes: [aiRoute],
    ),
    TypedStatefulShellBranch(
      routes: [personageRoute],
    ),
  ],
);
