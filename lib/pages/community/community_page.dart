import 'package:eden/uikit/tips/unrealized_tips.dart';
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
            child: Text('开始扫描')),
      ],
    );
  }
}
