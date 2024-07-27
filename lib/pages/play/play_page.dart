import 'package:eden/pages/play/widgets/items/play_mode_item.dart';
import 'package:eden/router/common/play/eden_play_router.dart';
import 'package:eden/router/eden_router.dart';
import 'package:eden/uikit/appbar/eden_gradient_app_bar.dart';
import 'package:eden/uikit/background/eden_background.dart';
import 'package:eden_intl/eden_intl.dart';
import 'package:eden_uikit/eden_uikit.dart';
import 'package:flutter/material.dart';

class PlayPage extends StatefulWidget {
  const PlayPage({super.key});

  @override
  State<PlayPage> createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage> {
  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      PlayModeItem(
        title: context.strings.touch,
        onTap: () {
          const PlayTouchRoute().push(context);
        },
      ),
      PlayModeItem(
        title: context.strings.automatic,
        onTap: () {
          const PlayAutoRoute().push(context);
        },
      ),
      PlayModeItem(
        title: context.strings.sound,
        onTap: () {
          const PlaySoundRoute().push(context);
        },
      ),
      PlayModeItem(
        title: context.strings.music,
        onTap: () {},
      ),
      PlayModeItem(
        title: context.strings.remote,
        onTap: () {},
      )
    ];
    return EdenBackground(
      child: Scaffold(
        appBar: EdenGradientAppBar(
          title: context.strings.play,
        ),
        body: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 22.w),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (_, index) {
                    return children[index];
                  },
                  childCount: children.length,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20.w,
                  crossAxisSpacing: 12.w,
                  childAspectRatio: 166 / 140,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
