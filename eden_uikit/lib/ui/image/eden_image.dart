import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eden_uikit/eden_uikit.dart';
import 'package:flutter/material.dart';

import 'img_holder.dart';

export 'eden_svg.dart';

/// 缩放方式
/// * 目前来看，使用比例缩放
enum ScaleType {
  /// 按宽度，小于原图则使用原图
  scaleByWidth,

  /// 按比例缩放
  scaleByRatio,
}

class EdenImage {
  static const BlendMode colorBlendMode = BlendMode.srcIn;

  static const String key = 'cachedImageData';

  /// 图片缓存管理器
  static CacheManager? cacheManager;

  /// 初始化一个图片缓存管理器
  /// * 可以考虑根据机器配置增加多种配置
  static void initCacheManager(CacheManager cm) {
    assert(cacheManager == null, 'Cache manager can only init once !');
    cacheManager = cm;
  }

  /// 将图片转为webp格式，并保持原图比例进行缩放
  /// * [scaleRatio] < 100 为缩小， >100 为放大
  static String formatAndKeepRatioScaleImg2Webp(String imgUrl,
      {int scaleRatio = 100}) {
    return imgUrl;
  }

  /// 缩小目标比原图大，将使用原图
  static String formatAndKeepRatioScaleByWidth2Webp(String imgUrl,
      {int? targetWidth = 2000}) {
    return imgUrl;
  }

  /// 格式化图片URL
  static String formatImgURL(String imgUrl, ScaleType scaleType,
      {int scaleRatio = 100, int? targetWidth = 1440}) {
    switch (scaleType) {
      case ScaleType.scaleByWidth:
        return formatAndKeepRatioScaleByWidth2Webp(imgUrl,
            targetWidth: targetWidth);
      case ScaleType.scaleByRatio:
        return formatAndKeepRatioScaleImg2Webp(imgUrl, scaleRatio: scaleRatio);
      default:
        return imgUrl;
    }
  }

  static Widget loadLocalImage(
    String path, {
    Key? key,
    double? width,
    double? height,
    BoxFit? fit,
    Color? color,
    String? package,
    AlignmentGeometry alignment = Alignment.center,
    BlendMode colorBlendMode = colorBlendMode,
  }) {
    return Image.file(
      File(path),
      key: key,
      height: height,
      width: width,
      fit: fit,
      color: color,
      colorBlendMode: colorBlendMode,
      alignment: alignment,
    );
  }

  /// 加载本地资源图片(支持svg)
  static Widget loadAssetImage(
    String name, {
    Key? key,
    double? width,
    double? height,
    BoxFit? fit,
    Color? color,
    String? package,
    AlignmentGeometry alignment = Alignment.center,
    BlendMode colorBlendMode = colorBlendMode,
  }) {
    if (name.endsWith('.svg')) {
      return ZhiyaSvg(
        path: name,
        size: width != null && height != null
            ? Size(width, height)
            : width != null
                ? Size.fromWidth(width)
                : height != null
                    ? Size.fromHeight(height)
                    : null,
        color: color,
        package: package,
      );
    }
    return Image.asset(
      name,
      key: key,
      height: height,
      width: width,
      fit: fit,
      color: color,
      colorBlendMode: colorBlendMode,
      package: package,
      alignment: alignment,
    );
  }

  /// 通用图片加载中占位图
  static Widget retrieveCommonPlaceholder() {
    return const ImageLoadingWidget();
  }

  /// 通用图片加载错误占位图
  static Widget retrieveCommonImgErrorWidget({
    Key? key,
    double? width,
    double? height,
  }) {
    return LayoutBuilder(builder: (ctx, data) {
      double widthSize = width ?? data.maxWidth;
      double heightSize = height ??
          (data.maxHeight == double.infinity
              ? widthSize / 16 * 9
              : data.maxHeight);
      return Container(
        width: widthSize,
        height: heightSize,
        decoration: BoxDecoration(
          color: ctx.theme.background,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Center(
            child: Text(
              '404',
              style: 14.spts.shade400(ctx),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    });
  }

  /// 加载网络图片
  /// * 建议，使用[ScaleType.scaleByWidth] 可以最大限度的保证缩放质量
  /// * [ScaleType.scaleByWidth] 标准：一屏宽度的targetWidth 为1440（实际使用时可以灵活配置，但最大为1440）。
  ///  eg. 设计图上一个图片占1/2屏幕宽度，那么它的[targetWidth] 就是720.
  ///  [useOriginImg] 应为 false, [scaleType] 应为 [ScaleType.scaleByWidth]
  /// * [useOriginImg] 为true 将直接加载链接原图
  /// * [scaleRatio] < 100 为缩小， > 100 为放大
  /// * [useOriginImg] 转换是要花钱的，先关了，特殊页面按需求再开。
  /// * [ScaleType] 缩放方式：按系数还是按宽度进行等比缩放. 默认[ScaleType.scaleByRatio]
  /// * [targetWidth] 按指定宽度 等比缩小，大于原图，将使用原图
  /// * 注意，宽度、系数缩放只能二选一，同时宽度只有缩小，若大于原图，将使用原图
  /// * [customHolderWidget]、[customErrorWidget] 自定义占位、错误widget
  /// * [cacheKey] 缓存标识，为空则使用url
  static Widget loadNetworkImage(
    String imageUrl, {
    Key? key,
    double? width,
    double? height,
    String? cacheKey,
    BoxFit fit = BoxFit.cover,
    Widget? customHolderWidget,
    Widget? customErrorWidget,
    String? package,
    Color? color,
    BlendMode colorBlendMode = colorBlendMode,
    Duration duration = const Duration(milliseconds: 500),
    ScaleType scaleType = ScaleType.scaleByRatio,
    int? targetWidth,
    bool useOriginImg = true,
    int scaleRatio = 50,
    bool qrcode = false,
  }) {
    assert(cacheManager != null, 'Must init cache manager before use it.');
    if (imageUrl.trim() == '') {
      return customErrorWidget ??
          retrieveCommonImgErrorWidget(key: key, width: width, height: height);
    }
    // TODO 全局增加图片处理参数
    // 处理开始
    final String finalUrl;
    if (useOriginImg) {
      useOriginImg = false;
      if (width == null || width == double.infinity) {
        scaleType = ScaleType.scaleByRatio;
        scaleRatio = 50;
      } else {
        scaleType = ScaleType.scaleByWidth;
        targetWidth = 2360 * (width / ScreenUtil().scaleWidth) ~/ 600;
      }
    }
    finalUrl = formatImgURL(imageUrl, scaleType,
        scaleRatio: scaleRatio, targetWidth: targetWidth);
    imageUrl = useOriginImg || qrcode ? imageUrl : finalUrl;
    // 处理结束
    return CachedNetworkImage(
      key: key,
      cacheManager: cacheManager,
      imageUrl: imageUrl,
      placeholder: (BuildContext context, String url) =>
          customHolderWidget ?? retrieveCommonPlaceholder(),
      errorWidget: (BuildContext context, String url, dynamic error) =>
          customErrorWidget ??
          retrieveCommonImgErrorWidget(key: key, width: width, height: height),
      width: width,
      height: height,
      fadeInDuration: duration,
      fadeOutDuration: duration,
      cacheKey: cacheKey,
      fit: fit,
      color: color,
      colorBlendMode: colorBlendMode,
    );
  }

  /// 自定义占位图的加载图片
  /// * 建议，使用[ScaleType.scaleByWidth] 可以最大限度的保证缩放质量
  /// * [ScaleType.scaleByWidth] 标准：一屏宽度的targetWidth 为1440（实际使用时可以灵活配置，但最大为1440）。
  ///  eg. 设计图上一个图片占1/2屏幕宽度，那么它的[targetWidth] 就是720.
  ///  [useOriginImg] 应为 false, [scaleType] 应为 [ScaleType.scaleByWidth]
  /// [useOriginImg] 为true 将直接加载链接原图
  /// [scaleRatio] < 100 为缩小， > 100 为放大
  /// * [ScaleType] 缩放方式：按系数还是按宽度进行等比缩放. 默认[ScaleType.scaleByRatio]
  /// * [targetWidth] 按指定宽度 等比缩小，大于原图，将使用原图
  /// * 注意，宽度、系数缩放只能二选一，同时宽度只有缩小，若大于原图，将使用原图
  /// * [cacheKey] 缓存标识，为空则使用url
  static Widget loadImageCustomPlaceHolder(
    String imageUrl, {
    Key? key,
    double? width,
    double? height,
    Widget? placeHolderWidget,
    Widget? errorWidget,
    String? cacheKey,
    BoxFit fit = BoxFit.fill,
    Color? color,
    BlendMode colorBlendMode = colorBlendMode,
    String? package,
    Duration duration = const Duration(milliseconds: 500),
    ScaleType scaleType = ScaleType.scaleByRatio,
    int? targetWidth,
    bool useOriginImg = true,
    int scaleRatio = 50,
  }) {
    assert(cacheManager != null, 'Must init cache manager before use it.');
    if (imageUrl.trim() == '') {
      return placeHolderWidget ?? EdenEmpty.ui;
    }
    if (imageUrl.startsWith('http')) {
      imageUrl = useOriginImg
          ? imageUrl
          : formatImgURL(imageUrl, scaleType,
              scaleRatio: scaleRatio, targetWidth: targetWidth);
      return CachedNetworkImage(
        key: key,
        cacheManager: cacheManager,
        imageUrl: imageUrl,
        width: width,
        height: height,
        fadeInDuration: duration,
        fadeOutDuration: duration,
        cacheKey: cacheKey,
        placeholder: (BuildContext context, String url) =>
            placeHolderWidget ?? EdenEmpty.ui,
        errorWidget: (BuildContext context, String url, dynamic error) =>
            errorWidget ??
            retrieveCommonImgErrorWidget(
                key: key, width: width, height: height),
        fit: fit,
        color: color,
        colorBlendMode: colorBlendMode,
      );
    } else {
      return loadAssetImage(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        color: color,
        colorBlendMode: colorBlendMode,
        package: package,
      );
    }
  }

  /// 无占位图的加载网络图片
  /// * 建议，使用[ScaleType.scaleByWidth] 可以最大限度的保证缩放质量
  /// * [ScaleType.scaleByWidth] 标准：一屏宽度的targetWidth 为1440（实际使用时可以灵活配置，但最大为1440）。
  ///  eg. 设计图上一个图片占1/2屏幕宽度，那么它的[targetWidth] 就是720.
  ///  [useOriginImg] 应为 false, [scaleType] 应为 [ScaleType.scaleByWidth]
  /// [useOriginImg] 为true 将直接加载链接原图
  /// [scaleRatio] < 100 为缩小， > 100 为放大
  /// * [ScaleType] 缩放方式：按系数还是按宽度进行等比缩放. 默认[ScaleType.scaleByRatio]
  /// * [targetWidth] 按指定宽度 等比缩小，大于原图，将使用原图
  /// * 注意，宽度、系数缩放只能二选一，同时宽度只有缩小，若大于原图，将使用原图
  /// * [cacheKey] 缓存标识，为空则使用url
  static Widget loadImageNoHolder(
    String imageUrl, {
    Key? key,
    required double width,
    required double height,
    BoxFit fit = BoxFit.cover,
    required Color color,
    BlendMode colorBlendMode = colorBlendMode,
    Duration duration = const Duration(milliseconds: 500),
    ScaleType scaleType = ScaleType.scaleByRatio,
    int? targetWidth,
    bool useOriginImg = true,
    int scaleRatio = 50,
    String? cacheKey,
  }) {
    assert(cacheManager != null, 'Must init cache manager before use it.');
    imageUrl = useOriginImg
        ? imageUrl
        : formatImgURL(imageUrl, scaleType,
            scaleRatio: scaleRatio, targetWidth: targetWidth);
    return CachedNetworkImage(
      key: key,
      cacheManager: cacheManager,
      imageUrl: imageUrl,
      width: width,
      height: height,
      fadeInDuration: duration,
      fadeOutDuration: duration,
      cacheKey: cacheKey,
      fit: fit,
      color: color,
      colorBlendMode: colorBlendMode,
    );
  }

  ///获取ImageProvider对象
  static ImageProvider getImageProvider(String imageUrl, {String? cacheKey}) {
    return CachedNetworkImageProvider(imageUrl,
        cacheManager: cacheManager, cacheKey: cacheKey);
  }

  static ImageProvider getAssetImage(String name, {String? package}) {
    return AssetImage(name, package: package);
  }

  /// 图片写入File
  static Future<String> getImgFilePath(dynamic image, String filePath) async {
    final ByteData byteData =
        await image.toByteData(format: ImageByteFormat.png);
    final Uint8List pngBytes = byteData.buffer.asUint8List();
    final File file =
        File('$filePath/${DateTime.now().millisecondsSinceEpoch}.png');
    if (!file.existsSync()) {
      file.createSync();
    }
    file.writeAsBytesSync(pngBytes);
    return file.path;
  }
}
