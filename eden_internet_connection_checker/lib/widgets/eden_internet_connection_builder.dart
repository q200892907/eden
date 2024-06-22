import 'package:eden_internet_connection_checker/eden_internet_connection_checker.dart';
import 'package:flutter/material.dart';

/// 根据网络状态创建对应布局
class ZhiyaInternetConnectionBuilder extends StatelessWidget {
  const ZhiyaInternetConnectionBuilder(
      {super.key, required this.builder, this.child});

  final ValueWidgetBuilder<InternetStatus> builder;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: EdenInternetConnection.instance.connectionNotifier,
      builder: builder,
      child: child,
    );
  }
}
