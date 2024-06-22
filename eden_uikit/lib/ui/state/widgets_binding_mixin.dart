import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

mixin WidgetsBindingMixin<T extends StatefulWidget> on State<T>
    implements WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAccessibilityFeatures() {}

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {}

  @override
  void didChangeLocales(List<Locale>? locales) {}

  @override
  void didChangeMetrics() {}

  @override
  void didChangePlatformBrightness() {}

  @override
  void didChangeTextScaleFactor() {}

  @override
  void didHaveMemoryPressure() {}

  @override
  Future<bool> didPopRoute() {
    return Future<bool>.value(false);
  }

  @override
  Future<bool> didPushRoute(String route) {
    return Future<bool>.value(false);
  }

  @override
  Future<bool> didPushRouteInformation(RouteInformation routeInformation) {
    return Future<bool>.value(false);
  }

  @override
  Future<AppExitResponse> didRequestAppExit() {
    return Future<AppExitResponse>.value(AppExitResponse.exit);
  }

  @override
  void handleCancelBackGesture() {}

  @override
  void handleCommitBackGesture() {}

  @override
  bool handleStartBackGesture(PredictiveBackEvent backEvent) {
    return false;
  }

  @override
  void handleUpdateBackGestureProgress(PredictiveBackEvent backEvent) {}
}
