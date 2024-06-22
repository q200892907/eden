import 'package:eden_uikit/eden_uikit.dart';
import 'package:flutter/material.dart';

class EdenScrollConfiguration extends StatelessWidget {
  const EdenScrollConfiguration({
    super.key,
    required this.child,
    this.behavior,
  });

  final Widget child;
  final ScrollBehavior? behavior;

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: behavior ?? EdenScrollBehavior.system(),
      child: child,
    );
  }
}
