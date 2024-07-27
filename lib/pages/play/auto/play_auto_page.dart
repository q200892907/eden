import 'package:collection/collection.dart';
import 'package:eden/r.dart';
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
  late final ValueNotifier<String> _suckGifNotifier = ValueNotifier('');
  late final ValueNotifier<String> _vibrationGifNotifier = ValueNotifier('');
  late final ValueNotifier<int> _suckIndexNotifier = ValueNotifier(0);
  late final ValueNotifier<int> _vibrationIndexNotifier = ValueNotifier(0);
  late final ValueNotifier<bool> _suckPlayingNotifier = ValueNotifier(false);
  late final ValueNotifier<bool> _vibrationPlayingNotifier = ValueNotifier(false);
  int _lastSuckIndex = 1;
  int _lastVibrationIndex = 1;
  late final ValueNotifier<double> _sliderValueNotifier = ValueNotifier(5);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initData();
  }

  void _initData() {
    _suckItems = [
      PlayAutoItemEntity(icon: R.assetsImagesSuckMode1, title: context.strings.mode1),
      PlayAutoItemEntity(icon: R.assetsImagesSuckMode2, title: context.strings.mode2),
      PlayAutoItemEntity(icon: R.assetsImagesSuckMode3, title: context.strings.mode3),
      PlayAutoItemEntity(icon: R.assetsImagesSuckMode4, title: context.strings.mode4),
      PlayAutoItemEntity(icon: R.assetsImagesSuckMode5, title: context.strings.mode5),
    ];
    _vibrationItems = [
      PlayAutoItemEntity(icon: R.assetsImagesVibrateMode1, title: context.strings.mode1),
      PlayAutoItemEntity(icon: R.assetsImagesVibrateMode2, title: context.strings.mode2),
      PlayAutoItemEntity(icon: R.assetsImagesVibrateMode3, title: context.strings.mode3),
      PlayAutoItemEntity(icon: R.assetsImagesVibrateMode4, title: context.strings.mode4),
      PlayAutoItemEntity(icon: R.assetsImagesVibrateMode5, title: context.strings.mode5),
      PlayAutoItemEntity(icon: R.assetsImagesVibrateMode6, title: context.strings.mode6),
      PlayAutoItemEntity(icon: R.assetsImagesVibrateMode7, title: context.strings.mode7),
      PlayAutoItemEntity(icon: R.assetsImagesVibrateMode8, title: context.strings.mode8),
      PlayAutoItemEntity(icon: R.assetsImagesVibrateMode9, title: context.strings.mode9),
      PlayAutoItemEntity(icon: R.assetsImagesVibrateMode10, title: context.strings.mode10),
    ];
  }

  @override
  Widget build(BuildContext context) {
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
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned.fill(
                    child: ValueListenableBuilder(
                      valueListenable: _suckGifNotifier,
                      builder: (context, value, child) {
                        return Visibility(
                          visible: value.isNotEmpty,
                          child: EdenImage.loadAssetImage(
                            value,
                            width: 343.w,
                            height: 137.w,
                            fit: BoxFit.fill,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned.fill(
                    child: ValueListenableBuilder(
                      valueListenable: _vibrationGifNotifier,
                      builder: (context, value, child) {
                        return Visibility(
                          visible: value.isNotEmpty,
                          child: EdenImage.loadAssetImage(
                            value,
                            width: 343.w,
                            height: 137.w,
                            fit: BoxFit.fill,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
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
                    _stopSuck();
                  } else {
                    _startSuck(_lastSuckIndex);
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
          children: _suckItems.mapIndexed((index, item) {
            return ValueListenableBuilder(
              valueListenable: _suckIndexNotifier,
              builder: (context, value, child) {
                return PlayAutoItem(
                  icon: item.icon,
                  iconSize: Size(31.w, 31.w),
                  title: item.title,
                  checked: value == index + 1,
                  onTap: () {
                    if (value == index + 1) {
                      _stopSuck();
                    } else {
                      _startSuck(index + 1);
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
                  stopVibrate();
                } else {
                  startVibrate(_lastVibrationIndex);
                }
                _vibrationPlayingNotifier.value = !value;
              },
            );
          },
        ),
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
                if (_vibrationPlayingNotifier.value) {
                  FunctionProxy(startVibrateWithoutMode, timeout: 120).throttleWithTimeout();
                }
              },
            );
          },
        ),
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
                  iconSize: Size(60.w, 20.w),
                  title: item.title,
                  checked: value == index + 1,
                  onTap: () {
                    if (value == index + 1) {
                      _vibrationIndexNotifier.value = 0;
                      stopVibrate();
                    } else {
                      startVibrate(index + 1);
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
      color: context.theme.primary,
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

  void _startSuck(int mode) {
    _suckIndexNotifier.value = mode;
    _lastSuckIndex = mode;
    _suckPlayingNotifier.value = true;
    switch (mode) {
      case 1:
        _suckGifNotifier.value = R.assetsGifSuckMode1;
        break;

      case 2:
        _suckGifNotifier.value = R.assetsGifSuckMode2;
        break;

      case 3:
        _suckGifNotifier.value = R.assetsGifSuckMode3;
        break;

      case 4:
        _suckGifNotifier.value = R.assetsGifSuckMode4;
        break;

      case 5:
        _suckGifNotifier.value = R.assetsGifSuckMode5;
        break;

      default:
        _suckGifNotifier.value = '';
    }
    ref.read(bleDeviceStateProvider)?.suckMotor(mode);
  }

  void _stopSuck() {
    _suckIndexNotifier.value = 0;
    _suckPlayingNotifier.value = false;
    _suckGifNotifier.value = '';
    ref.read(bleDeviceStateProvider)?.stopSuckMotor();
  }

  void startVibrate(int mode) {
    _vibrationIndexNotifier.value = mode;
    _lastVibrationIndex = mode;
    _vibrationPlayingNotifier.value = true;
    switch (mode) {
      case 1:
        _vibrationGifNotifier.value = R.assetsGifVibrateMode1;
        break;

      case 2:
        _vibrationGifNotifier.value = R.assetsGifVibrateMode2;
        break;

      case 3:
        _vibrationGifNotifier.value = R.assetsGifVibrateMode3;
        break;

      case 4:
        _vibrationGifNotifier.value = R.assetsGifVibrateMode4;
        break;

      case 5:
        _vibrationGifNotifier.value = R.assetsGifVibrateMode5;
        break;

      case 6:
        _vibrationGifNotifier.value = R.assetsGifVibrateMode6;
        break;

      case 7:
        _vibrationGifNotifier.value = R.assetsGifVibrateMode7;
        break;

      case 8:
        _vibrationGifNotifier.value = R.assetsGifVibrateMode8;
        break;

      case 9:
        _vibrationGifNotifier.value = R.assetsGifVibrateMode9;
        break;

      case 10:
        _vibrationGifNotifier.value = R.assetsGifVibrateMode10;
        break;

      default:
        _vibrationGifNotifier.value = '';
    }
    ref.read(bleDeviceStateProvider)?.modeMotor(mode, _sliderValueNotifier.value.round());
  }

  /// 仅供特定场景下调节强度时使用
  void startVibrateWithoutMode() {
    ref.read(bleDeviceStateProvider)?.modeMotor(_vibrationIndexNotifier.value, _sliderValueNotifier.value.round());
  }

  void stopVibrate() {
    _vibrationIndexNotifier.value = 0;
    _vibrationPlayingNotifier.value = false;
    _vibrationGifNotifier.value = '';
    ref.read(bleDeviceStateProvider)?.stopModeMotor();
  }
}

class PlayAutoItemEntity {
  final String icon;
  final String title;

  PlayAutoItemEntity({required this.icon, required this.title});
}
