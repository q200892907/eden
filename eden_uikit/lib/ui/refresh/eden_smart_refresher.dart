import 'package:eden_uikit/eden_uikit.dart';
import 'package:flutter/material.dart';

export 'package:pull_to_refresh/pull_to_refresh.dart';

class EdenSmartRefresher extends StatelessWidget {
  const EdenSmartRefresher({
    super.key,
    this.onRefresh,
    this.onLoading,
    this.scrollController,
    required this.child,
    required this.controller,
    this.header,
    this.footer,
  }) : super();

  final VoidCallback? onRefresh;

  final VoidCallback? onLoading;

  final ScrollController? scrollController;

  final RefreshController controller;

  final Widget child;

  final Widget? header;

  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      scrollController: scrollController,
      controller: controller,
      header: header ?? const MaterialClassicHeader(),
      footer: footer,
      enablePullUp: onLoading != null,
      enablePullDown: onRefresh != null,
      onRefresh: onRefresh,
      onLoading: onLoading,
      physics: const AlwaysScrollableScrollPhysics(),
      child: child,
    );
  }
}
