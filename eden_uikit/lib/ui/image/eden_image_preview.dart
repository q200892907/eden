import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:eden_uikit/eden_uikit.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ZhiyaImagePreviewEntity {
  final String name;
  final String url;

  ZhiyaImagePreviewEntity({
    required this.name,
    required this.url,
  });
}

class ZhiyaImagePreview {
  static Future show({
    required BuildContext context,
    required List<ZhiyaImagePreviewEntity> images,
    int index = 0,
    String? heroTag,
    bool download = true,
  }) {
    //todo
    return Future.value();
    // return showan(
    //     context: context,
    //     transitionType: TransitionType.fade,
    //     builder: (_) {
    //       return _ZhiyaImagePreviewPage(
    //         images: images,
    //         index: index,
    //         heroTag: heroTag,
    //         download: download,
    //       );
    //     });
  }
}

///
/// 图片预览页面
///
class _ZhiyaImagePreviewPage extends StatefulWidget {
  const _ZhiyaImagePreviewPage({
    required this.images,
    this.index = 0,
    this.heroTag,
    this.download = true,
  });

  final List<ZhiyaImagePreviewEntity> images;
  final int index;
  final String? heroTag;
  final bool download;

  @override
  State<_ZhiyaImagePreviewPage> createState() => _ZhiyaImagePreviewPageState();
}

class _ZhiyaImagePreviewPageState extends State<_ZhiyaImagePreviewPage> {
  late List<ZhiyaImagePreviewEntity> _images;
  late ValueNotifier<int> _currentIndexNotifier;
  late PageController _pageController;
  final FocusNode _focusNode = FocusNode();
  final PhotoViewController _photoViewController = PhotoViewController();
  late StreamSubscription<PhotoViewControllerValue> _subscription;
  final double _maxScale = 3;
  final double _minScale = 0.1;
  bool _isSaving = false;

  String? get heroTag => widget.heroTag;

  @override
  void initState() {
    super.initState();
    _images = widget.images;
    _focusNode.requestFocus();
    _currentIndexNotifier = ValueNotifier<int>(widget.index);
    _pageController = PageController(initialPage: _currentIndexNotifier.value);
    _subscription = _photoViewController.outputStateStream.listen((event) {});
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Colors.black.withOpacity(0.8);
    final SystemUiOverlayStyle overlayStyle =
        SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent);
    return Focus(
      focusNode: _focusNode,
      onKeyEvent: (node, key) {
        if (_isSaving) {
          return KeyEventResult.handled;
        }
        if (key is KeyDownEvent) {
          if (key.logicalKey == LogicalKeyboardKey.arrowLeft) {
            int index = _currentIndexNotifier.value - 1;
            if (index < 0) {
              index = 0;
            }
            _pageController.jumpToPage(index);
            return KeyEventResult.handled;
          } else if (key.logicalKey == LogicalKeyboardKey.arrowRight) {
            int index = _currentIndexNotifier.value + 1;
            if (index >= widget.images.length) {
              index = widget.images.length - 1;
            }
            _pageController.jumpToPage(index);
            return KeyEventResult.handled;
          } else if (key.logicalKey == LogicalKeyboardKey.escape) {
            Navigator.of(context).pop();
            return KeyEventResult.handled;
          } else if ((Platform.isMacOS
                  ? HardwareKeyboard.instance.isMetaPressed
                  : HardwareKeyboard.instance.isControlPressed) &&
              key.logicalKey.keyLabel == '=') {
            double scale = double.parse(
                (_photoViewController.scale ?? 1).toStringAsFixed(1));
            if (scale < _maxScale) {
              _photoViewController.scale = scale + 0.1;
            }
            return KeyEventResult.handled;
          } else if ((Platform.isMacOS
                  ? HardwareKeyboard.instance.isMetaPressed
                  : HardwareKeyboard.instance.isControlPressed) &&
              key.logicalKey.keyLabel == '-') {
            double scale = double.parse(
                (_photoViewController.scale ?? 1).toStringAsFixed(1));
            if (scale > _minScale) {
              _photoViewController.scale = scale - 0.1;
            }
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: overlayStyle,
        child: Container(
          decoration: BoxDecoration(color: backgroundColor),
          child: SafeArea(
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  top: 0,
                  child: PhotoViewGallery.builder(
                    scrollPhysics: const ClampingScrollPhysics(),
                    wantKeepAlive: true,
                    backgroundDecoration:
                        const BoxDecoration(color: Colors.transparent),
                    customSize: Platform.isMacOS ||
                            Platform.isWindows ||
                            Platform.isLinux
                        ? Size(MediaQuery.of(context).size.width - 240,
                            MediaQuery.of(context).size.height - 120)
                        : Size(MediaQuery.of(context).size.width - 16,
                            MediaQuery.of(context).size.height - 16),
                    builder: (BuildContext context, int index) {
                      final String originUrl = _images[index].url;
                      final bool isNetwork = originUrl.startsWith('http');
                      return PhotoViewGalleryPageOptions(
                        onTapUp: (context, details, controllerValue) {
                          Navigator.of(context).pop();
                        },
                        controller: _photoViewController,
                        imageProvider: _imageProvider(isNetwork, originUrl),
                        maxScale: _maxScale,
                        // initialScale: 1.0,
                        minScale: _minScale,
                        heroAttributes: (heroTag ?? '').isNotEmpty
                            ? PhotoViewHeroAttributes(tag: heroTag!)
                            : null,
                      );
                    },
                    itemCount: _images.length,
                    loadingBuilder: (context, event) => Center(
                      child: SizedBox(
                        width: 30.w,
                        height: 30.w,
                        child: CircularProgressIndicator(
                            value: event == null
                                ? 0
                                : event.cumulativeBytesLoaded /
                                    event.expectedTotalBytes!),
                      ),
                    ),
                    pageController: _pageController,
                    enableRotation: false,
                    onPageChanged: (index) {
                      _currentIndexNotifier.value = index;
                    },
                  ),
                ),
                Positioned(
                  right: 16.w,
                  top: 16.w,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        constraints:
                            BoxConstraints.expand(width: 40.w, height: 40.w),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(6.w),
                        ),
                        child: Icon(
                          Icons.close,
                          size: 20.w,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: ScreenUtil().bottomBarHeight + 24.w,
                  child: Center(
                    child: _buildTools(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ImageProvider<Object> _imageProvider(bool isNetwork, String originUrl) {
    if (isNetwork) {
      return ExtendedNetworkImageProvider(
        originUrl,
        cache: true,
      );
    }
    return ExtendedFileImageProvider(
      File(originUrl),
    );
  }

  Widget _buildTools(BuildContext context) {
    return StreamBuilder<PhotoViewControllerValue>(
        stream: _photoViewController.outputStateStream,
        builder: (context, snapshot) {
          double scale = snapshot.data?.scale ?? 1;
          double rotation = snapshot.data?.rotation ?? 0;
          return Container(
            height: 46.w,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(6.w),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildChangeIndex(),
                _buildLine(),
                _buildScale(scale),
                _buildLine(),
                _buildOther(rotation),
              ],
            ),
          );
        });
  }

  Widget _buildLine() {
    return 1.vLine(
      color: const Color(0xff3b3b3b),
      margin: EdgeInsets.symmetric(horizontal: 14.w),
      height: 16.w,
    );
  }

  Widget _buildOther(double rotation) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              _photoViewController.rotation = rotation - pi / 2;
            },
            behavior: HitTestBehavior.translucent,
            child: Icon(
              Icons.arrow_back_ios_rounded,
              size: 16.w,
              color: Colors.white,
            ),
          ),
        ),
        // 14.hGap,
        // MouseRegion(
        //   cursor: SystemMouseCursors.click,
        //   child: GestureDetector(
        //     onTap: () {
        //       _photoViewController.rotation = rotation + pi / 2;
        //     },
        //     behavior: HitTestBehavior.translucent,
        //     child: Icon(
        //       ZhiyaIcons.rotate_right,
        //       size: 16.w,
        //       color: Colors.white,
        //     ),
        //   ),
        // ),
        Visibility(
          visible: widget.download,
          child: Padding(
            padding: EdgeInsets.only(left: 14.w),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  _isSaving = true;
                  _EdenImagePreviewSaveUtil.save(
                    _images[_currentIndexNotifier.value],
                  ).then((value) {
                    _isSaving = false;
                  });
                },
                behavior: HitTestBehavior.translucent,
                child: Icon(
                  Icons.download,
                  size: 16.w,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScale(double scale) {
    scale = double.parse(scale.toStringAsFixed(1));
    bool isSub = scale > _minScale;
    bool isAdd = scale < _maxScale;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        MouseRegion(
          cursor: isSub ? SystemMouseCursors.click : MouseCursor.defer,
          child: GestureDetector(
            onTap: isSub
                ? () {
                    _photoViewController.scale = scale - 0.1;
                  }
                : null,
            behavior: HitTestBehavior.translucent,
            child: Opacity(
              opacity: isSub ? 1 : 0.4,
              child: Icon(
                Icons.refresh_rounded,
                size: 16.w,
                color: Colors.white,
              ),
            ),
          ),
        ),
        8.hGap,
        Text(
          '${(scale * 100).toInt()}%',
          style: 14.spts.textColor(Colors.white),
          maxLines: 1,
        ),
        8.hGap,
        MouseRegion(
          cursor: isAdd ? SystemMouseCursors.click : MouseCursor.defer,
          child: GestureDetector(
            onTap: isAdd
                ? () {
                    _photoViewController.scale = scale + 0.1;
                  }
                : null,
            behavior: HitTestBehavior.translucent,
            child: Opacity(
              opacity: isAdd ? 1 : 0.4,
              child: Icon(
                Icons.add,
                size: 16.w,
                color: Colors.white,
              ),
            ),
          ),
        ),
        14.hGap,
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              _photoViewController.scale = 1;
            },
            behavior: HitTestBehavior.translucent,
            child: Icon(
              Icons.refresh_outlined, //todo 还原
              size: 24.w,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChangeIndex() {
    return ValueListenableBuilder<int>(
      valueListenable: _currentIndexNotifier,
      builder: (BuildContext context, int activeStep, _) {
        bool isPrevious = activeStep > 0;
        bool isNext = activeStep < _images.length - 1;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            MouseRegion(
              cursor: isPrevious ? SystemMouseCursors.click : MouseCursor.defer,
              child: GestureDetector(
                onTap: isPrevious
                    ? () {
                        _pageController.previousPage(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.ease);
                      }
                    : null,
                behavior: HitTestBehavior.translucent,
                child: Opacity(
                  opacity: isPrevious ? 1 : 0.4,
                  child: Icon(
                    Icons.arrow_back_ios_rounded,
                    size: 16.w,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            14.hGap,
            Text(
              '${activeStep + 1}/${_images.length}',
              style: 14.spts.textColor(Colors.white),
              maxLines: 1,
            ),
            14.hGap,
            MouseRegion(
              cursor: isNext ? SystemMouseCursors.click : MouseCursor.defer,
              child: GestureDetector(
                onTap: isNext
                    ? () {
                        _pageController.nextPage(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.ease);
                      }
                    : null,
                behavior: HitTestBehavior.translucent,
                child: Opacity(
                  opacity: isNext ? 1 : 0.4,
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16.w,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _currentIndexNotifier.dispose();
    _pageController.dispose();
    _focusNode.dispose();
    _subscription.cancel();
    super.dispose();
  }
}

class _EdenImagePreviewSaveUtil {
  static Future save(ZhiyaImagePreviewEntity entity) async {
    var data = await getNetworkImageData(entity.url);
    if (data == null) {
      return null;
    }
    ImageGallerySaver.saveImage(data, name: entity.name);
  }
}
