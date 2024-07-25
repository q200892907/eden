library eden_uikit;

import 'package:eden_uikit/eden_uikit.dart';
import 'package:flutter/material.dart';

export 'package:auto_size_text/auto_size_text.dart';
export 'package:azlistview_plus/azlistview_plus.dart';
export 'package:card_swiper/card_swiper.dart';
export 'package:convex_bottom_bar/convex_bottom_bar.dart';
export 'package:device_info_plus/device_info_plus.dart';
export 'package:dropdown_button2/dropdown_button2.dart';
export 'package:eden_icons/eden_icons.dart';
export 'package:flutter_cache_manager/flutter_cache_manager.dart';
export 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
export 'package:flutter_screenutil/flutter_screenutil.dart';
export 'package:flutter_spinkit/flutter_spinkit.dart';
export 'package:keframe/keframe.dart';
export 'package:keyboard_height_plugin/keyboard_height_plugin.dart';
export 'package:oktoast/oktoast.dart';
export 'package:path_drawing/path_drawing.dart';
export 'package:pull_to_refresh/pull_to_refresh.dart';
export 'package:riverpod_context/riverpod_context.dart';
export 'package:visibility_detector/visibility_detector.dart';

export 'extensions/eden_ui_extension.dart';
export 'theme/eden_theme.dart';
export 'ui/appbar/eden_app_bar.dart';
export 'ui/device/eden_device.dart';
export 'ui/image/eden_image.dart';
export 'ui/image/eden_image_preview.dart';
export 'ui/keyboard/eden_keyboard_height.dart';
export 'ui/loading/eden_loading.dart';
export 'ui/refresh/eden_smart_refresher.dart';
export 'ui/riverpod/eden_riverpod.dart';
export 'ui/safe/eden_bottom_safe_area.dart';
export 'ui/scroll/eden_scroll_configuration.dart';
export 'ui/state/widgets_binding_mixin.dart';
export 'ui/text/eden_max_scale_text.dart';
export 'ui/toast/eden_toast.dart';

class EdenUikit extends StatefulWidget {
  static const String package = 'eden_uikit';

  const EdenUikit({
    super.key,
    required this.child,
    required this.handsetSize,
    this.headerBuilder,
    this.footerBuilder,
  });

  final Widget child;
  final Size handsetSize; //手机设计尺寸
  final IndicatorBuilder? headerBuilder;
  final IndicatorBuilder? footerBuilder;

  @override
  State<EdenUikit> createState() => _EdenUikitState();
}

class _EdenUikitState extends State<EdenUikit> with WidgetsBindingObserver {
  Size? designSize;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return EdenKeyboardHeightProvider(
      child: RefreshConfiguration(
        headerBuilder: widget.headerBuilder,
        footerBuilder: widget.footerBuilder,
        child: OKToast(
          child: ScreenUtilInit(
            builder: (_, child) {
              EdenLoading.initialize();
              return EdenScrollConfiguration(
                child: widget.child,
              );
            },
            designSize: widget.handsetSize,
            splitScreenMode: true,
          ),
        ),
      ),
    );
  }
}
