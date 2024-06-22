import 'package:flutter/material.dart';

extension RouteContextExt on BuildContext {
  bool get isRoot {
    final route = ModalRoute.of(this);
    return route?.isFirst == true;
  }
}
