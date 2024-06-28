import 'package:collection/collection.dart';
import 'package:eden/develop/eden_develop_tools.dart';
import 'package:eden/eden_app.dart';
import 'package:eden/providers/eden_user_provider.dart';
import 'package:eden/router/eden_router.dart';
import 'package:eden_internet_connection_checker/eden_internet_connection_checker.dart';
import 'package:eden_intl/eden_intl.dart';
import 'package:eden_service/eden_service.dart';
import 'package:eden_uikit/eden_uikit.dart';
import 'package:flutter/material.dart';

class RootTabItem {
  final String? name; //提示文本
  final IconData icon;
  final String path;

  RootTabItem({
    this.name,
    required this.icon,
    required this.path,
  });
}

class RootPage extends ConsumerStatefulWidget {
  const RootPage({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<RootPage> createState() => _RootPageState();
}

class _RootPageState extends ConsumerState<RootPage>
    with
        EdenDevelopMixin,
        EdenInternetConnectMixin,
        WidgetsBindingObserver,
        TickerProviderStateMixin {
  late List<RootTabItem> _mobileTabs;
  final int _mobileCreateIndex = 2;
  final ValueNotifier<bool> _mobileNavNotifier = ValueNotifier(true);

  @override
  void initState() {
    super.initState();
    EdenApi.addListener(EdenApiEventType.tokenError, _onTokenError);
  }

  @override
  void dispose() {
    EdenApi.removeListener(EdenApiEventType.tokenError);
    super.dispose();
  }

  void _getCurrentIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    bool navStatus = _mobileTabs.any((element) => location == element.path);
    _mobileNavNotifier.value = navStatus;
  }

  @override
  Widget build(BuildContext context) {
    appContext = context;
    _mobileTabs = [
      RootTabItem(
        name: context.strings.home,
        icon: Icons.home_outlined,
        path: EdenRouter.home,
      ),
      RootTabItem(
        name: context.strings.community,
        icon: Icons.people_outline,
        path: EdenRouter.community,
      ),
      RootTabItem(icon: Icons.add, path: ''),
      RootTabItem(
        name: context.strings.aiChat,
        icon: Icons.smart_toy_outlined,
        path: EdenRouter.ai,
      ),
      RootTabItem(
        name: context.strings.personage,
        icon: Icons.person_outline,
        path: EdenRouter.personage,
      ),
    ];
    _getCurrentIndex(context);
    return Scaffold(
      backgroundColor: context.theme.background,
      body: widget.navigationShell,
      bottomNavigationBar: ValueListenableBuilder(
        valueListenable: _mobileNavNotifier,
        builder: (context, visible, child) {
          return _buildMobileBottomBar(
            visible,
            context,
            create: true,
          );
        },
      ),
    );
  }

  Visibility _buildMobileBottomBar(
    bool visible,
    BuildContext context, {
    bool create = false,
  }) {
    return Visibility(
      visible: visible,
      child: StyleProvider(
        style: EdenBottomBarStyle(),
        child: ConvexAppBar.badge(
          const {
            //todo 添加提醒
          },
          badgeMargin: const EdgeInsets.only(bottom: 36, left: 24),
          disableDefaultTabController: true,
          initialActiveIndex: 0,
          height: 56.w,
          top: -16.w,
          curveSize: 80.w,
          color: context.theme.text.shade700,
          activeColor: context.theme.primary,
          shadowColor: context.theme.line,
          style: TabStyle.fixedCircle,
          items: _mobileTabs.mapIndexed(
            (index, e) {
              if (index == _mobileCreateIndex) {
                return TabItem(
                  icon: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.theme.primary,
                    ),
                    child: Icon(
                      e.icon,
                      color: Colors.white,
                      size: 40.w,
                    ),
                  ),
                );
              }
              return TabItem(icon: e.icon, title: e.name);
            },
          ).toList(),
          backgroundColor: context.theme.background,
          cornerRadius: 0,
          onTabNotify: (i) {
            var intercept = i == _mobileCreateIndex;
            if (intercept) {
              if (create) {
                //todo 中间的加号
              }
            }
            return !intercept;
          },
          onTap: (index) {
            if (index >= _mobileCreateIndex) {
              index = index - 1;
            }
            widget.navigationShell.goBranch(
              index,
              initialLocation: index == widget.navigationShell.currentIndex,
            );
          },
        ),
      ),
    );
  }

  void _logout() {
    context.read(edenUserNotifierProvider.notifier).logout(context);
  }

  void _onTokenError(dynamic data) {
    EdenApi.removeListener(EdenApiEventType.tokenError);
    _logout();
  }

  @override
  void onInternetConnectionChanged(InternetStatus status) {
    // 网络变化
  }
}

class EdenBottomBarStyle extends StyleHook {
  @override
  double get activeIconSize => 40.w;

  @override
  double get activeIconMargin => 10.w;

  @override
  double get iconSize => 22.w;

  @override
  TextStyle textStyle(Color color, String? fontFamily) {
    return TextStyle(fontSize: 10.sp, color: color, fontFamily: fontFamily);
  }
}
