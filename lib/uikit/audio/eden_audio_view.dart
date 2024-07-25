import 'dart:math';

import 'package:eden/utils/music_player.dart';
import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';

class EdenAudioView extends StatelessWidget {
  const EdenAudioView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialDesktopVideoControlsTheme(
      normal: const MaterialDesktopVideoControlsThemeData(
        bottomButtonBar: [
          MaterialDesktopSkipPreviousButton(),
          MaterialDesktopPlayOrPauseButton(),
          MaterialDesktopSkipNextButton(),
          MaterialDesktopVolumeButton(),
          MaterialDesktopPositionIndicator(),
        ],
      ),
      fullscreen: const MaterialDesktopVideoControlsThemeData(
        bottomButtonBar: [
          MaterialDesktopSkipPreviousButton(),
          MaterialDesktopPlayOrPauseButton(),
          MaterialDesktopSkipNextButton(),
          MaterialDesktopVolumeButton(),
          MaterialDesktopPositionIndicator(),
        ],
      ),
      child: MaterialVideoControlsTheme(
        normal: const MaterialVideoControlsThemeData(
          bottomButtonBar: [
            MaterialPositionIndicator(),
          ],
        ),
        fullscreen: const MaterialVideoControlsThemeData(
          bottomButtonBar: [
            MaterialPositionIndicator(),
          ],
        ),
        child: Center(
          child: LayoutBuilder(builder: (context, data) {
            double width = min(375, data.maxWidth);
            double height = width * 9 / 21;
            return Container(
              constraints: BoxConstraints(
                maxWidth: width,
                maxHeight: height,
              ),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  12,
                ),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      color: Colors.black,
                      child: Icon(
                        Icons.music_note_rounded,
                        size: height / 3,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Video(
                      controller: MusicPlayer.instance.controller,
                      fill: Colors.transparent,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
