import 'package:eden_intl/eden_intl.dart';
import 'package:eden_uikit/eden_uikit.dart';
import 'package:flutter/material.dart';

import '../widgets/items/play_auto_item.dart';

///
/// 自动模式
///
/// Created by Jack Zhang on 2024/7/20 .
///
class PlayAutoPage extends StatefulWidget {
  const PlayAutoPage({super.key});

  @override
  State<PlayAutoPage> createState() => _PlayAutoPageState();
}

class _PlayAutoPageState extends State<PlayAutoPage> {
  final List<PlayAutoItemEntity> suckItems = [
    PlayAutoItemEntity(icon: '', title: 'mode 1'),
    PlayAutoItemEntity(icon: '', title: 'mode 2'),
    PlayAutoItemEntity(icon: '', title: 'mode 3'),
    PlayAutoItemEntity(icon: '', title: 'mode 4'),
    PlayAutoItemEntity(icon: '', title: 'mode 5'),
    PlayAutoItemEntity(icon: '', title: 'mode 6'),
    PlayAutoItemEntity(icon: '', title: 'mode 7'),
    PlayAutoItemEntity(icon: '', title: 'mode 8'),
    PlayAutoItemEntity(icon: '', title: 'mode 9'),
    PlayAutoItemEntity(icon: '', title: 'mode 10')
  ];

  final List<PlayAutoItemEntity> vibrationItems = [
    PlayAutoItemEntity(icon: '', title: 'mode 1'),
    PlayAutoItemEntity(icon: '', title: 'mode 2'),
    PlayAutoItemEntity(icon: '', title: 'mode 3'),
    PlayAutoItemEntity(icon: '', title: 'mode 4'),
    PlayAutoItemEntity(icon: '', title: 'mode 5'),
    PlayAutoItemEntity(icon: '', title: 'mode 6'),
    PlayAutoItemEntity(icon: '', title: 'mode 7'),
    PlayAutoItemEntity(icon: '', title: 'mode 8'),
    PlayAutoItemEntity(icon: '', title: 'mode 9'),
    PlayAutoItemEntity(icon: '', title: 'mode 10')
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EdenAppBar(
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
    );
  }

  /// 吮吸模式
  List<Widget> _buildSuckMode() {
    return [
      _buildTitleTile(
        text: context.strings.suckingMode,
        playing: false,
        onTap: () {},
      ),
      SliverPadding(
        padding: EdgeInsets.all(8.w),
        sliver: SliverGrid.count(
          crossAxisCount: 4,
          mainAxisSpacing: 4.w,
          crossAxisSpacing: 4.w,
          childAspectRatio: 1.24,
          children: suckItems.map((item) {
            return PlayAutoItem(
              icon: item.icon,
              title: item.title,
              checked: false,
              onTap: () {},
            );
          }).toList(),
        ),
      ),
    ];
  }

  /// 震动模式
  List<Widget> _buildVibrationMode() {
    return [
      _buildTitleTile(
        text: context.strings.vibrationMode,
        playing: false,
        onTap: () {},
      ),
      SliverPadding(
        padding: EdgeInsets.all(8.w),
        sliver: SliverGrid.count(
          crossAxisCount: 4,
          mainAxisSpacing: 4.w,
          crossAxisSpacing: 4.w,
          childAspectRatio: 1.24,
          children: suckItems.map((item) {
            return PlayAutoItem(
              icon: item.icon,
              title: item.title,
              checked: false,
              onTap: () {},
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
    return SliverToBoxAdapter(
      child: Container(
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
          ],
        ),
      ),
    );
  }
}

class PlayAutoItemEntity {
  final String icon;
  final String title;

  PlayAutoItemEntity({required this.icon, required this.title});
}
