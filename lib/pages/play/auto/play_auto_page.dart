import 'package:collection/collection.dart';
import 'package:eden/uikit/appbar/eden_gradient_app_bar.dart';
import 'package:eden/uikit/background/eden_background.dart';
import 'package:eden/utils/ble/ble_manager_provider.dart';
import 'package:eden/utils/function_proxy.dart';
import 'package:eden_intl/eden_intl.dart';
import 'package:eden_uikit/eden_uikit.dart';
import 'package:flutter/material.dart';

import '../widgets/items/play_auto_item.dart';

///
/// 自动模式
///
/// Created by Jack Zhang on 2024/7/20 .
///
class PlayAutoPage extends ConsumerStatefulWidget {
  const PlayAutoPage({super.key});

  @override
  ConsumerState<PlayAutoPage> createState() => _PlayAutoPageState();
}

class _PlayAutoPageState extends ConsumerState<PlayAutoPage> {
  late final List<PlayAutoItemEntity> _suckItems;
  late final List<PlayAutoItemEntity> _vibrationItems;
  late final ValueNotifier<int> _suckIndexNotifier = ValueNotifier(0);
  late final ValueNotifier<int> _vibrationIndexNotifier = ValueNotifier(0);
  late final ValueNotifier<bool> _suckPlayingNotifier = ValueNotifier(false);
  late final ValueNotifier<bool> _vibrationPlayingNotifier = ValueNotifier(false);
  int _lastSuckIndex = 1;
  int _lastVibrationIndex = 1;
  late final ValueNotifier<double> _sliderValueNotifier = ValueNotifier(5);
  bool _vibrating = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initData();
  }

  void _initData() {
    _suckItems = [
      PlayAutoItemEntity(icon: '', title: context.strings.mode1),
      PlayAutoItemEntity(icon: '', title: context.strings.mode2),
      PlayAutoItemEntity(icon: '', title: context.strings.mode3),
      PlayAutoItemEntity(icon: '', title: context.strings.mode4),
      PlayAutoItemEntity(icon: '', title: context.strings.mode5),
    ];
    _vibrationItems = [
      PlayAutoItemEntity(icon: '', title: context.strings.mode1),
      PlayAutoItemEntity(icon: '', title: context.strings.mode2),
      PlayAutoItemEntity(icon: '', title: context.strings.mode3),
      PlayAutoItemEntity(icon: '', title: context.strings.mode4),
      PlayAutoItemEntity(icon: '', title: context.strings.mode5),
      PlayAutoItemEntity(icon: '', title: context.strings.mode6),
      PlayAutoItemEntity(icon: '', title: context.strings.mode7),
      PlayAutoItemEntity(icon: '', title: context.strings.mode8),
      PlayAutoItemEntity(icon: '', title: context.strings.mode9),
      PlayAutoItemEntity(icon: '', title: context.strings.mode10),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // state = ref.read(bleDeviceStateProvider);
    return EdenBackground(
      child: Scaffold(
        appBar: EdenGradientAppBar(
          title: context.strings.automatic,
        ),
        body: Column(
          children: [
            Container(
              width: 1.sw,
              height: 137.w,
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(16.w))),
              child: const Placeholder(),
            ),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  ..._buildSuckMode(),
                  ..._buildVibrationMode(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 吮吸模式
  List<Widget> _buildSuckMode() {
    return [
      SliverToBoxAdapter(
        child: ValueListenableBuilder(
            valueListenable: _suckPlayingNotifier,
            builder: (context, value, child) {
              return _buildTitleTile(
                text: context.strings.suckingMode,
                playing: value,
                onTap: () {
                  if (value) {
                    _suckIndexNotifier.value = 0;
                    _stopSuck();
                  } else {
                    _suckIndexNotifier.value = _lastSuckIndex;
                    _startSuck();
                  }
                  _suckPlayingNotifier.value = !value;
                },
              );
            }),
      ),
      SliverPadding(
        padding: EdgeInsets.all(8.w),
        sliver: SliverGrid.count(
          crossAxisCount: 4,
          mainAxisSpacing: 4.w,
          crossAxisSpacing: 4.w,
          childAspectRatio: 1.24,
          children: _suckItems.mapIndexed((index, item) {
            return ValueListenableBuilder(
              valueListenable: _suckIndexNotifier,
              builder: (context, value, child) {
                return PlayAutoItem(
                  icon: item.icon,
                  title: item.title,
                  checked: value == index + 1,
                  onTap: () {
                    if (value == index + 1) {
                      _suckIndexNotifier.value = 0;
                      _suckPlayingNotifier.value = false;
                      _stopSuck();
                    } else {
                      _suckIndexNotifier.value = index + 1;
                      _lastSuckIndex = index + 1;
                      _suckPlayingNotifier.value = true;
                      _startSuck();
                    }
                  },
                );
              },
            );
          }).toList(),
        ),
      ),
    ];
  }

  /// 震动模式
  List<Widget> _buildVibrationMode() {
    return [
      SliverToBoxAdapter(
        child: ValueListenableBuilder(
            valueListenable: _vibrationPlayingNotifier,
            builder: (context, value, child) {
              return _buildTitleTile(
                text: context.strings.vibrationMode,
                playing: value,
                onTap: () {
                  if (value) {
                    _vibrationIndexNotifier.value = 0;
                    stopVibrate();
                  } else {
                    _vibrationIndexNotifier.value = _lastVibrationIndex;
                    startVibrate();
                  }
                  _vibrationPlayingNotifier.value = !value;
                },
              );
            }),
      ),
      SliverToBoxAdapter(
        child: ValueListenableBuilder(
            valueListenable: _sliderValueNotifier,
            builder: (context, value, child) {
              return Slider(
                min: 1,
                max: 10,
                value: value,
                onChanged: (newValue) {
                  _sliderValueNotifier.value = newValue;
                  if (_vibrating) {
                    FunctionProxy(startVibrate, timeout: 120).throttleWithTimeout();
                  }
                },
              );
            }),
      ),
      SliverPadding(
        padding: EdgeInsets.all(8.w),
        sliver: SliverGrid.count(
          crossAxisCount: 4,
          mainAxisSpacing: 4.w,
          crossAxisSpacing: 4.w,
          childAspectRatio: 1.24,
          children: _vibrationItems.mapIndexed((index, item) {
            return ValueListenableBuilder(
              valueListenable: _vibrationIndexNotifier,
              builder: (context, value, child) {
                return PlayAutoItem(
                  icon: item.icon,
                  title: item.title,
                  checked: value == index + 1,
                  onTap: () {
                    if (value == index + 1) {
                      _vibrationIndexNotifier.value = 0;
                      _vibrationPlayingNotifier.value = false;
                      stopVibrate();
                    } else {
                      _vibrationIndexNotifier.value = index + 1;
                      _lastVibrationIndex = index + 1;
                      _vibrationPlayingNotifier.value = true;
                      startVibrate();
                    }
                  },
                );
              },
            );
          }).toList(),
        ),
      ),
    ];
  }

  /// 模式标题
  ///
  /// [index] 标题位置，0：吮吸模式；1.震动模式
  /// [playing] 是否正在播放
  Widget _buildTitleTile({required String text, required bool playing, required VoidCallback onTap}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.w),
      color: Colors.blueGrey,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            text,
            style: 16.sp.ts,
          ),
          GestureDetector(
            onTap: onTap,
            child: Icon(
              playing ? Icons.pause_circle : Icons.play_circle,
              size: 24.w,
            ),
          ),
        ],
      ),
    );
  }

  void _startSuck() {
    ref.read(bleDeviceStateProvider)?.suckMotor(_suckIndexNotifier.value);
  }

  void _stopSuck() {
    ref.read(bleDeviceStateProvider)?.stopSuckMotor();
  }

  void startVibrate() {
    _vibrating = true;
    ref.read(bleDeviceStateProvider)?.modeMotor(_vibrationIndexNotifier.value, _sliderValueNotifier.value.round());
  }

  void stopVibrate() {
    _vibrating = false;
    ref.read(bleDeviceStateProvider)?.stopModeMotor();
  }
}

class PlayAutoItemEntity {
  final String icon;
  final String title;

  PlayAutoItemEntity({required this.icon, required this.title});
}
