import 'package:eden_intl/eden_intl.dart';
import 'package:eden_uikit/eden_uikit.dart';
import 'package:eden_uikit/ui/riverpod/state/eden_view_state.dart';
import 'package:flutter/material.dart';

class EdenDefaultPageStatusFactory {
  static Widget nil() {
    return EdenEmpty.ui;
  }

  /// 空闲布局
  static Widget idle({
    bool isAppbar = false,
    String? appbarTitle,
  }) {
    return _buildAppbar(
      appbarTitle: appbarTitle,
      isAppbar: isAppbar,
      child: const Center(child: EdenEmpty.ui),
    );
  }

  /// 空布局默认样式
  /// [emptyTips] 提示语
  /// [onTap] 点击事件，刷新使用
  static Widget empty({
    String? emptyTips,
    Widget? child,
    VoidCallback? onTap,
    bool isAppbar = false,
    String? appbarTitle,
  }) {
    return _buildAppbar(
      appbarTitle: appbarTitle,
      isAppbar: isAppbar,
      child: Builder(builder: (context) {
        return MouseRegion(
          cursor: onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
          child: GestureDetector(
            onTap: () {
              onTap?.call();
            },
            behavior: HitTestBehavior.translucent,
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Center(
                child: child ??
                    Text(
                      emptyTips ?? '',
                      style: 16.spts.shade400(context),
                    ),
              ),
            ),
          ),
        );
      }),
    );
  }

  /// 错误布局
  /// [errorType] 错误类型
  /// [errorTips] 提示语
  /// [onTap] 点击事件，刷新使用
  static Widget error({
    EdenViewStateErrorType errorType = EdenViewStateErrorType.normal,
    String? errorTips,
    Widget? child,
    VoidCallback? onTap,
    bool isAppbar = false,
    String? appbarTitle,
  }) {
    return _buildAppbar(
      appbarTitle: appbarTitle,
      isAppbar: isAppbar,
      child: Builder(builder: (context) {
        return MouseRegion(
          cursor: onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
          child: GestureDetector(
            onTap: () {
              onTap?.call();
            },
            behavior: HitTestBehavior.translucent,
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Center(
                child: child ??
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          errorTips ??
                              (errorType == EdenViewStateErrorType.network
                                  ? context.strings.httpTimeout
                                  : context.strings.httpTimeout),
                          style: 16.spts.shade400(context),
                        ),
                        if (onTap != null)
                          Padding(
                            padding: EdgeInsets.only(top: 4.w),
                            child: Text(
                              context.strings.clickToTryAgain,
                              style: 16.spts.shade400(context),
                            ),
                          ),
                      ],
                    ),
              ),
            ),
          ),
        );
      }),
    );
  }

  /// todo 加载布局
  static Widget loading({
    bool isAppbar = false,
    String? appbarTitle,
  }) {
    return _buildAppbar(
      appbarTitle: appbarTitle,
      isAppbar: isAppbar,
      child: Builder(builder: (context) {
        return Center(
          child: SpinKitCircle(
            color: context.theme.primary,
            size: 40.w,
          ),
        );
      }),
    );
  }

  static Widget _buildAppbar({
    required Widget child,
    bool isAppbar = false,
    String? appbarTitle,
  }) {
    if (isAppbar) {
      return Scaffold(
        appBar: EdenAppBar(
          title: appbarTitle,
        ),
        body: child,
      );
    }
    return child;
  }
}
