import 'package:eden_service/eden_service.dart';
import 'package:eden_uikit/eden_uikit.dart';
import 'package:flutter/material.dart';

class EdenCustomServer extends EdenServer {
  final String uri;
  final bool https;

  EdenCustomServer(this.https, this.uri);

  @override
  String get apiUri => uri;

  @override
  bool get isHttps => https;

  @override
  String get objectbox => 'zhiya_objectbox_dev';
}

class EdenServerTool extends StatefulWidget {
  const EdenServerTool({super.key});

  @override
  EdenServerToolState createState() => EdenServerToolState();
}

class EdenServerToolState extends State<EdenServerTool> {
  final TextEditingController _controller = TextEditingController();
  String _http = 'https';

  @override
  Widget build(BuildContext context) {
    List<String> http = ['https', 'http'];
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Text('快速切换环境:'),
                12.hGap,
                OutlinedButton(
                  child: const Text('开发环境'),
                  onPressed: () {
                    EdenServerConfig.initServer(
                      envType: EdenEnvType.dev,
                      server: EdenDevServer(),
                    );
                    _completed(context);
                  },
                ),
                8.hGap,
                OutlinedButton(
                  child: const Text('测试环境'),
                  onPressed: () {
                    EdenServerConfig.initServer(
                      envType: EdenEnvType.stage,
                      server: EdenStageServer(),
                    );
                    _completed(context);
                  },
                ),
              ],
            ),
            16.vGap,
            TextField(
              controller: _controller,
              style: 18.spts.shade700(context).regular,
              decoration: const InputDecoration.collapsed(
                border:
                    UnderlineInputBorder(borderSide: BorderSide(width: 0.5)),
                hintText: '请输入服务器地址',
              ).copyWith(
                prefixIcon: IntrinsicWidth(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton2<String>(
                      isExpanded: true,
                      buttonStyleData: ButtonStyleData(
                        overlayColor: WidgetStateColor.resolveWith(
                          (states) => states.contains(WidgetState.hovered)
                              ? context.themeColor(const Color(0xfff5f5f5))
                              : context.theme.transparent,
                        ),
                      ),
                      iconStyleData: const IconStyleData(iconSize: 0),
                      dropdownStyleData: DropdownStyleData(
                        offset: Offset(0, 0.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2.w),
                          color: context.theme.background,
                          boxShadow: [
                            BoxShadow(
                              color: context.theme.background.invert
                                  .withOpacity(0.2),
                              offset: Offset(0, 9.w),
                              blurRadius: 28.w,
                            ),
                          ],
                        ),
                        elevation: 1,
                        scrollbarTheme: ScrollbarThemeData(
                          radius: Radius.circular(2.w),
                          thickness: WidgetStateProperty.all(6),
                          thumbVisibility: WidgetStateProperty.all(true),
                        ),
                      ),
                      menuItemStyleData: MenuItemStyleData(
                        height: 32.w,
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        overlayColor: WidgetStateColor.resolveWith(
                          (states) => states.contains(WidgetState.hovered)
                              ? context.themeColor(const Color(0xfff5f5f5))
                              : context.theme.transparent,
                        ),
                      ),
                      selectedItemBuilder: (_) {
                        return http
                            .map(
                              (e) => Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    e,
                                    style: 18.spts.shade700(context).medium,
                                  ),
                                  Text(
                                    '://',
                                    style: 18.spts.shade700(context).medium,
                                  ),
                                ],
                              ),
                            )
                            .toList();
                      },
                      items: http
                          .map(
                            (e) => DropdownMenuItem<String>(
                              value: e,
                              child: Text(e,
                                  style: 18.spts.shade700(context).regular),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          _http = value;
                          setState(() {});
                        }
                      },
                      value: _http,
                    ),
                  ),
                ),
                helperText: '192.168.0.1:8080(仅输入ip/域名+端口(存在的话))',
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            32.vGap,
            SizedBox(
              width: 1.sw,
              child: ElevatedButton(
                child: const Text('确定'),
                onPressed: () async {
                  EdenServerConfig.initServer(
                    envType: EdenEnvType.dev,
                    server:
                        EdenCustomServer(_http == 'https', _controller.text),
                  );
                  _completed(context);
                },
              ),
            ),
            32.vGap,
          ],
        ),
      ),
    );
  }

  void _completed(BuildContext context) {
    EdenService.resetService();
    EdenToast.show('设置完成');
    //todo
    // context
    //     .read(zhiyaUserNotifierProvider.notifier)
    //     .logout(context)
    //     .then((value) {
    //   Future.delayed(const Duration(milliseconds: 500), () {
    //     EdenDevelopTools.instance.removeTools();
    //   });
    // });
  }
}
