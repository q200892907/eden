import 'package:eden_uikit/eden_uikit.dart';
import 'package:flutter/material.dart';

import 'base/eden_develop_page.dart';
import 'custom/dio/eden_dio_tool.dart';
import 'custom/error/eden_error_tool.dart';
import 'custom/log/eden_log_tool.dart';
import 'custom/theme/eden_theme_tool.dart';
import 'tools/eden_main_tool.dart';
import 'tools/eden_proxy_tool.dart';
import 'tools/eden_server_tool.dart';

class EdenDevelopTool {
  final String title;
  final String routeName;
  final Widget? child;
  final Icon? icon;
  final ValueChanged<BuildContext>? onTap;
  final bool isAppBar;

  EdenDevelopTool({
    required this.title,
    required this.routeName,
    this.child,
    this.icon,
    this.onTap,
    this.isAppBar = true,
  });
}

mixin EdenDevelopMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      EdenDevelopTools.instance.bindContext(context);
    });
  }
}

class EdenDevelopTools {
  factory EdenDevelopTools() => _getInstance();

  static EdenDevelopTools get instance => _getInstance();
  static EdenDevelopTools? _instance;

  EdenDevelopTools._internal();

  static EdenDevelopTools _getInstance() {
    _instance ??= EdenDevelopTools._internal();
    return _instance!;
  }

  OverlayEntry? _holder;
  OverlayEntry? _toolsHolder;
  late BuildContext _context;
  List<EdenDevelopTool>? _externalTools;

  List<EdenDevelopTool> get _allTools {
    List<EdenDevelopTool> temp = [
      EdenDevelopTool(
        title: '',
        routeName: '/',
        child: EdenMainTool(
          icon: _icon,
        ),
      ),
      EdenDevelopTool(
        title: '代理设置',
        routeName: '/proxy',
        child: const EdenProxyTool(),
        icon: const Icon(Icons.wifi_rounded),
      ),
      EdenDevelopTool(
        title: '自定义服务',
        routeName: '/server',
        child: const EdenServerTool(),
        icon: const Icon(Icons.design_services_rounded),
      ),
      EdenDevelopTool(
        title: '网络日志',
        routeName: '/dio',
        child: const EdenDioTool(),
        icon: const Icon(Icons.http_rounded),
        isAppBar: false,
      ),
      EdenDevelopTool(
        title: '错误日志',
        routeName: '/error',
        child: const EdenErrorTool(),
        icon: const Icon(Icons.error_outline_rounded),
      ),
      EdenDevelopTool(
        title: '开发日志',
        routeName: '/log',
        child: const EdenLogTool(),
        icon: const Icon(Icons.local_printshop_outlined),
      ),
      EdenDevelopTool(
        title: '主题',
        routeName: '/theme',
        child: const EdenThemeTool(),
        icon: const Icon(Icons.sunny),
      ),
    ];
    temp.addAll(_externalTools ?? []);
    return temp;
  }

  List<EdenDevelopTool> get mainTools =>
      _allTools.toList()..removeWhere((element) => element.routeName == '/');

  bool _isDebug = false;

  Widget? _icon;

  void bindContext(BuildContext context) {
    _context = context;
  }

  void init({
    bool isDebug = false,
    List<EdenDevelopTool>? tools,
    Widget? icon,
  }) {
    _externalTools = tools;
    _icon = icon;
    _isDebug = isDebug;
  }

  /// 移除开发工具
  void _remove() {
    if (_holder != null) {
      _holder!.remove();
      _holder = null;
    }
    removeTools();
  }

  void removeTools() {
    if (_toolsHolder != null) {
      _toolsHolder!.remove();
      _toolsHolder = null;
    }
  }

  /// 是否显示开发工具
  bool _isOverlay() {
    return _holder != null;
  }

  /// 显示开发工具
  void show() {
    if (!_isDebug) return;
    if (_isOverlay()) return;
    _remove();
    //创建一个OverlayEntry对象
    OverlayEntry overlayEntry = OverlayEntry(builder: (context) {
      return Positioned(bottom: 120, left: 10, child: _buildDraggable(context));
    });

    //往Overlay中插入插入OverlayEntry
    Overlay.of(_context).insert(overlayEntry);

    _holder = overlayEntry;
  }

  Widget _buildDraggable(context) {
    return Draggable(
      feedback: _EdenDevelopIcon(
        icon: _icon,
      ),
      onDragStarted: () {
        // debugPrint('onDragStarted:');
      },
      onDragEnd: (detail) {
        // debugPrint('onDragEnd:${detail.offset}');
        _createDragTarget(offset: detail.offset, context: context);
      },
      childWhenDragging: Container(),
      ignoringFeedbackSemantics: false,
      child: _EdenDevelopIcon(
        icon: _icon,
      ),
    );
  }

  void _createDragTarget(
      {required Offset offset, required BuildContext context}) {
    if (_holder != null) {
      _holder?.remove();
    }

    _holder = OverlayEntry(builder: (context) {
      bool isLeft = true;
      if (offset.dx + 50 > MediaQuery.of(context).size.width / 2) {
        isLeft = false;
      }

      double maxY = MediaQuery.of(context).size.height - 200;

      return Positioned(
          top: offset.dy < 30
              ? 30
              : offset.dy < maxY
                  ? offset.dy
                  : maxY,
          left: isLeft ? 10 : null,
          right: isLeft ? null : 10,
          child: DragTarget(
            onLeave: (data) {
              // debugPrint('onLeave');
            },
            builder: (BuildContext context, List incoming, List rejected) {
              return _buildDraggable(context);
            },
          ));
    });
    Overlay.of(context).insert(_holder!);
  }

  void _showTools() {
    if (!_isDebug || _toolsHolder != null) return;
    //创建一个OverlayEntry对象
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) {
        return const _EdenDevelopView();
      },
      maintainState: true,
    );

    //往Overlay中插入插入OverlayEntry
    Overlay.of(_context).insert(overlayEntry, below: _holder);

    _toolsHolder = overlayEntry;
  }
}

class _EdenDevelopView extends StatelessWidget {
  const _EdenDevelopView();

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        onTap: () {
          EdenDevelopTools.instance.removeTools();
        },
        child: Stack(
          children: [
            Positioned.fill(
                child: Container(
              color: Colors.black26,
              constraints: const BoxConstraints.expand(),
            )),
            Positioned.fill(
              top: ScreenUtil().screenHeight * 0.3,
              left: 0,
              child: Navigator(
                initialRoute: '/',
                onGenerateRoute: (settings) {
                  EdenDevelopTool tool = EdenDevelopTools.instance._allTools
                      .firstWhere(
                          (element) => element.routeName == settings.name);
                  // WidgetBuilder builder = (context) => RikiDevelopPage(tool: tool);
                  return EdenDevelopRoute(page: EdenDevelopPage(tool: tool));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EdenDevelopIcon extends StatelessWidget {
  const _EdenDevelopIcon({this.icon});

  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        onTap: () {
          EdenDevelopTools.instance._showTools();
        },
        onLongPress: () {
          EdenDevelopTools.instance._remove();
        },
        child: FloatingActionButton(
          backgroundColor: context.theme.text.shade100,
          onPressed: () {
            EdenDevelopTools.instance._showTools();
          },
          elevation: 10.w,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100.w),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10000),
            child: icon ?? FlutterLogo(size: 32.w),
          ),
        ),
      ),
    );
  }
}

class EdenDevelopRoute extends PageRouteBuilder {
  final Widget page;

  EdenDevelopRoute({required this.page})
      : super(
          transitionDuration: const Duration(milliseconds: 200),
          pageBuilder: (
            BuildContext context,
            Animation<double> animation1,
            Animation<double> animation2,
          ) {
            return page;
          },
          transitionsBuilder: (BuildContext context,
              Animation<double> animation1,
              Animation<double> animation2,
              Widget child) {
            //左右滑动路由动画
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: const Offset(0.0, 0.0),
              ).animate(CurvedAnimation(
                  parent: animation1, curve: Curves.fastOutSlowIn)),
              child: child,
            );
          },
        );
}
