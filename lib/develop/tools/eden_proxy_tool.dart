import 'package:eden_uikit/eden_uikit.dart';
import 'package:flutter/material.dart';

import 'eden_fiddler_proxy.dart';

class EdenProxyTool extends StatefulWidget {
  const EdenProxyTool({super.key});

  @override
  EdenProxyToolState createState() => EdenProxyToolState();
}

class EdenProxyToolState extends State<EdenProxyTool> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration.collapsed(
                border:
                    UnderlineInputBorder(borderSide: BorderSide(width: 0.5)),
                hintText: '请输入IP地址+端口',
              ).copyWith(
                helperText: '例如127.0.0.1:8888',
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            32.vGap,
            SizedBox(
              width: 1.sw,
              child: ElevatedButton(
                child: const Text('确定'),
                onPressed: () {
                  EdenFiddlerProxy.setFiddlerProxy(_controller.text);
                  EdenToast.show('设置完成');
                  Navigator.of(context).maybePop();
                },
              ),
            ),
            32.vGap,
          ],
        ),
      ),
    );
  }
}
