import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:eden/utils/file_util.dart';
import 'package:eden/utils/music_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:mime/mime.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:path_provider/path_provider.dart';

class LocalHttpService {
  factory LocalHttpService() => _getInstance();

  static LocalHttpService get instance => _getInstance();
  static LocalHttpService? _instance;

  LocalHttpService._internal();

  Future<void> init() async {
    _dir = await getApplicationDocumentsDirectory();
    _dir = Directory('${_dir.path}/music');
    await _dir.create(recursive: true);
  }

  static LocalHttpService _getInstance() {
    _instance ??= LocalHttpService._internal();
    return _instance!;
  }

  HttpServer? server;
  final ValueNotifier<String?> localServerUri = ValueNotifier(null);
  late Directory _dir;

  Directory get localMusicDir => _dir;

  Future<bool> start() async {
    await stop();
    server ??= await HttpServer.bind(InternetAddress.anyIPv4, 5454);
    List<ConnectivityResult> results = await Connectivity().checkConnectivity();
    if (results.every((e) => e != ConnectivityResult.wifi)) {
      return false;
    }
    String ip = (await NetworkInfo().getWifiIP()) ?? '127.0.0.1';
    localServerUri.value = "$ip:5454";
    server?.forEach((request) async {
      if (request.uri.path == '/') {
        // 入口文件
        request.response
          ..statusCode = HttpStatus.ok
          ..headers.contentType = ContentType.html
          ..write(await rootBundle.loadString('assets/www/index.html'))
          ..close();
      } else if (request.uri.path == '/upload' &&
          request.method.toUpperCase() == 'POST') {
        // 上传接口 这边定义跟后端写法差不多
        if (request.headers.contentType?.mimeType == 'multipart/form-data') {
          // 指定 multipart/form-data 传输二进制类型
          // 这里使用mime/mime.dart 的 MimeMultipartTransformer 解析二进制数据
          // 坑点 使用官方示例会报错，然后调整以下
          String boundary =
              request.headers.contentType!.parameters['boundary']!;
          // 然后处理HttpRequest流
          await for (var multipart
              in MimeMultipartTransformer(boundary).bind(request)) {
            // 然后在body里面的 filename和field 都在 multipart.headers里面 然后文件流就是multipart本身
            String? contentDisposition =
                multipart.headers['content-disposition'];
            String? filename = contentDisposition
                ?.split("; ")
                .where((item) => item.startsWith("filename="))
                .first
                .replaceFirst("filename=", "")
                .replaceAll('"', '');
            // 我这边指定txt文件，否则跳过，如果不需要就略过
            if (filename == null ||
                filename.isEmpty ||
                !(FileUtil.isAudio(filename))) {
              continue;
            }
            String path = FileUtil.filePath("${_dir.path}/$filename");
            File file = File.fromUri(Uri.file(path));
            IOSink sink = file.openWrite();
            await multipart.pipe(sink);
            await sink.close();
            // 可以做其他操作
          }
          MusicPlayer.instance.scan();
          // 这边我直接成功，可以做其他判断
          request.response
            ..statusCode = HttpStatus.ok
            ..headers.contentType = ContentType.json
            ..write({"code": 1, "msg": "upload success"})
            ..close();
        } else {
          // 如果不是就报502
          request.response
            ..statusCode = HttpStatus.badGateway
            ..writeln('Unsupported request')
            ..close();
        }
      } else {
        // 其他请求都是404
        request.response
          ..statusCode = HttpStatus.notFound
          ..close();
      }
    });
    return true;
  }

  Future<void> stop() async {
    await server?.close();
    server = null;
    localServerUri.value = null;
  }
}
