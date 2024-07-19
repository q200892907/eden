import 'package:eden/utils/ble/ble_manager_provider.dart';
import 'package:eden_uikit/eden_uikit.dart';
import 'package:flutter/material.dart';

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const BleTestPage();
    // return const UnrealizedTips(name: 'Community');
  }
}

class BleTestPage extends ConsumerStatefulWidget {
  const BleTestPage({super.key});

  @override
  ConsumerState createState() => _BleTestPageState();
}

class _BleTestPageState extends ConsumerState<BleTestPage> {
  String _scanState = '';

  @override
  void initState() {
    super.initState();
    ref.read(bleStateProvider.notifier).fetchState();
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    final BluetoothAdapterState bleState = ref.watch(bleStateProvider);
    if (bleState == BluetoothAdapterState.on) {
      child = const Text('开');
    } else {
      child = const Text('关');
    }
    return Column(
      children: [
        Center(
          child: child,
        ),
        Center(
          child: Text(_scanState),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _scanState = '扫描中';
            });
            ref.read(bleDeviceStateProvider.notifier).start().whenComplete(() {
              if (mounted) {
                setState(() {
                  _scanState = '未开始扫描';
                });
              }
            });
          },
          child: const Text('开始扫描'),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _scanState = '触控模式-震动';
            });
            ref.read(bleDeviceStateProvider)?.touchActionMotor(100, 375);
          },
          child: const Text('触控模式-震动'),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _scanState = '停止触控震动';
            });
            ref.read(bleDeviceStateProvider)?.stopActionMotor();
          },
          child: const Text('停止触控震动'),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _scanState = '震动模式-模式3、强度10';
            });
            ref.read(bleDeviceStateProvider)?.modeMotor(3, 10);
          },
          child: const Text('震动模式-模式3、强度10'),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _scanState = '停止震动模式';
            });
            ref.read(bleDeviceStateProvider)?.stopModeMotor();
          },
          child: const Text('停止震动模式'),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _scanState = '吮吸模式-模式2';
            });
            ref.read(bleDeviceStateProvider)?.suckMotor(2);
          },
          child: const Text('吮吸模式-模式2'),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _scanState = '停止吮吸模式';
            });
            ref.read(bleDeviceStateProvider)?.stopSuckMotor();
          },
          child: const Text('停止吮吸模式'),
        ),
      ],
    );
  }
}
