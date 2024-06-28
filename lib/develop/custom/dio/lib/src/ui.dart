import 'dart:async';
import 'dart:convert';

import 'package:eden/develop/tools/eden_develop_clipboard_util.dart';
import 'package:eden_uikit/eden_uikit.dart';
import 'package:flutter/material.dart';

import 'enumerate_items.dart';
import 'network_event.dart';
import 'network_logger.dart';

/// Screen that displays log entries list.
class NetworkLoggerScreen extends StatelessWidget {
  NetworkLoggerScreen({super.key, NetworkEventList? eventList})
      : eventList = eventList ?? NetworkLogger.instance;

  /// Event list to listen for event changes.
  final NetworkEventList eventList;

  /// Opens screen.
  static Future<void> open(
    BuildContext context, {
    NetworkEventList? eventList,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NetworkLoggerScreen(eventList: eventList),
      ),
    );
  }

  final TextEditingController searchController =
      TextEditingController(text: null);

  /// filte events with search keyword
  List<NetworkEvent> getEvents() {
    if (searchController.text.isEmpty) return eventList.events;

    final query = searchController.text.toLowerCase();
    return eventList.events
        .where((it) => it.request?.uri.toLowerCase().contains(query) ?? false)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('网络日志'),
        elevation: 1.w,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () => eventList.clear(),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: eventList.stream,
        builder: (context, snapshot) {
          // filter events with search keyword
          final events = getEvents();

          return Column(
            children: [
              TextField(
                controller: searchController,
                onChanged: (text) {
                  eventList.updated(NetworkEvent());
                },
                autocorrect: false,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration.collapsed(
                  filled: true,
                  fillColor: context.theme.background,
                  hintText: "输入关键字搜索",
                  border: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: context.theme.border, width: 1.w),
                  ),
                ).copyWith(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
                  suffix: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: searchController,
                    builder: (context, value, child) => value.text.isNotEmpty
                        ? Text('${getEvents().length}个')
                        : const SizedBox(),
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(vertical: 12.w),
                  separatorBuilder: (_, index) {
                    return 1.hLine();
                  },
                  itemCount: events.length,
                  itemBuilder: enumerateItems<NetworkEvent>(
                    events,
                    (context, item) => ListTile(
                      key: ValueKey(item.request),
                      title: Text(
                        item.request!.method,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        item.request!.uri.toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      leading: Icon(
                        item.error == null
                            ? (item.response == null
                                ? Icons.hourglass_empty
                                : Icons.done)
                            : Icons.error,
                        color: item.error == null
                            ? (item.response == null
                                ? Colors.orange
                                : Colors.green)
                            : Colors.red,
                      ),
                      trailing: _AutoUpdate(
                        duration: const Duration(seconds: 1),
                        builder: (context) =>
                            Text(_timeDifference(item.timestamp!)),
                      ),
                      onTap: () => NetworkLoggerEventScreen.open(
                        context,
                        item,
                        eventList,
                      ),
                    ),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}

String _timeDifference(DateTime time, [DateTime? origin]) {
  origin ??= DateTime.now();
  var delta = origin.difference(time);
  if (delta.inSeconds < 90) {
    return '${delta.inSeconds} s';
  } else if (delta.inMinutes < 90) {
    return '${delta.inMinutes} m';
  } else {
    return '${delta.inHours} h';
  }
}

const _jsonEncoder = JsonEncoder.withIndent('  ');

class NetworkLoggerItemEntity {
  final String key;
  final dynamic value;
  final Color? fontColor;
  final double fontSize;

  String get valueString {
    dynamic body = value;
    String text;
    if (body == null) {
      text = '';
    } else if (body is String || body is List || body is Map) {
      if (body is String) {
        try {
          body = jsonDecode(body);
          text = _jsonEncoder.convert(body);
        } catch (e) {
          text = body.toString();
        }
      } else {
        text = _jsonEncoder.convert(body);
      }
    } else {
      try {
        body = body.toJson();
        text = _jsonEncoder.convert(body);
      } catch (_) {
        text = body.toString();
      }
    }
    return text;
  }

  @override
  String toString() {
    if (key.isEmpty) {
      return valueString;
    }
    return '$key: $valueString';
  }

  NetworkLoggerItemEntity({
    required this.key,
    required this.value,
    this.fontColor,
    this.fontSize = 14,
  });

  factory NetworkLoggerItemEntity.error(String key, dynamic value) {
    return NetworkLoggerItemEntity(
      key: key,
      value: value,
      fontColor: Colors.red,
    );
  }
}

/// Screen that displays log entry details.
class NetworkLoggerEventScreen extends StatelessWidget {
  const NetworkLoggerEventScreen({super.key, required this.event});

  static Route<void> route({
    required NetworkEvent event,
    required NetworkEventList eventList,
  }) {
    return MaterialPageRoute(
      builder: (context) => StreamBuilder(
        stream: eventList.stream.where((item) => item.event == event),
        builder: (context, snapshot) => NetworkLoggerEventScreen(event: event),
      ),
    );
  }

  /// Opens screen.
  static Future<void> open(
    BuildContext context,
    NetworkEvent event,
    NetworkEventList eventList,
  ) {
    return Navigator.of(context).push(route(
      event: event,
      eventList: eventList,
    ));
  }

  /// Which event to display details for.
  final NetworkEvent event;

  Widget buildContentViewer(
      BuildContext context, NetworkLoggerItemEntity item) {
    return Text(
      item.valueString,
      style: TextStyle(fontSize: item.fontSize, color: item.fontColor),
    );
  }

  Widget buildTitleAndContent(
    BuildContext context,
    String title,
    List<NetworkLoggerItemEntity> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        ...children.map(
          (e) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (e.key.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Text(
                      e.key,
                      style: TextStyle(
                        fontSize: e.fontSize,
                        color: e.fontColor,
                      ),
                    ),
                  ),
                Expanded(
                  child: buildContentViewer(context, e),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getString(Map<String, List<NetworkLoggerItemEntity>> values) {
    String text = '';
    values.forEach((key, value) {
      text += '$key\n';
      for (var e in value) {
        text += '${e.toString()}\n';
      }
      text += '\n';
    });
    return text;
  }

  Widget buildRequestView(BuildContext context) {
    Map<String, List<NetworkLoggerItemEntity>> values = _request();
    return GestureDetector(
      onLongPress: () {
        _copy();
      },
      child: ListView(
        padding: const EdgeInsets.all(15),
        children: values.entries
            .map((value) => buildTitleAndContent(
                  context,
                  value.key,
                  value.value,
                ))
            .toList(),
      ),
    );
  }

  Map<String, List<NetworkLoggerItemEntity>> _request() {
    Map<String, List<NetworkLoggerItemEntity>> values = {
      '请求地址': [
        NetworkLoggerItemEntity(
            key: event.request!.method, value: event.request!.uri.toString()),
      ],
      "请求时间": [
        NetworkLoggerItemEntity(key: '', value: event.timestamp.toString()),
      ],
      "请求头": event.request!.headers.entries.map((value) {
        return NetworkLoggerItemEntity(key: value.key, value: value.value);
      }).toList(),
      "请求内容": [
        NetworkLoggerItemEntity(key: '', value: event.request!.data),
      ],
      if (event.error != null)
        "错误信息": [
          NetworkLoggerItemEntity.error('', event.error),
        ]
    };
    return values;
  }

  Widget buildResponseView(BuildContext context) {
    Map<String, List<NetworkLoggerItemEntity>> values = _response();
    return GestureDetector(
      onLongPress: () {
        _copy();
      },
      child: ListView(
        padding: const EdgeInsets.all(15),
        children: values.entries
            .map((value) => buildTitleAndContent(
                  context,
                  value.key,
                  value.value,
                ))
            .toList(),
      ),
    );
  }

  void _copy() {
    Map<String, List<NetworkLoggerItemEntity>> values = _request();
    _response().forEach((key, value) {
      if (!values.containsKey(key)) {
        values[key] = value;
      }
    });
    EdenDevelopClipboardUtil.copy(_getString(values));
  }

  Map<String, List<NetworkLoggerItemEntity>> _response() {
    if (event.response == null) {
      return {};
    }
    Map<String, List<NetworkLoggerItemEntity>> values = {
      '请求地址': [
        NetworkLoggerItemEntity(
            key: event.request!.method, value: event.request!.uri.toString()),
      ],
      '请求结果': [
        NetworkLoggerItemEntity(
            key: event.response!.statusCode.toString(),
            value: event.response!.statusMessage),
      ],
      "完成时间": [
        NetworkLoggerItemEntity(
            key: '', value: event.completedTimestamp?.toString()),
      ],
      if (event.response?.headers.isNotEmpty ?? false)
        "回调头": event.response!.headers.entries.map((value) {
          return NetworkLoggerItemEntity(key: value.key, value: value.value);
        }).toList(),
      "回调内容": [
        NetworkLoggerItemEntity(key: '', value: event.response!.data),
      ],
    };
    return values;
  }

  @override
  Widget build(BuildContext context) {
    final showResponse = event.response != null;

    Widget? bottom;
    if (showResponse) {
      bottom = const TabBar(tabs: [
        Tab(text: 'Request'),
        Tab(text: 'Response'),
      ]);
    }

    return GestureDetector(
      onTap: () {},
      child: DefaultTabController(
        initialIndex: 0,
        length: showResponse ? 2 : 1,
        child: SafeArea(
          child: Scaffold(
            appBar: AppBar(
              title: const Text('网络日志详情'),
              bottom: (bottom as PreferredSizeWidget?),
            ),
            floatingActionButton: FloatingActionButton(
              mini: true,
              shape: const CircleBorder(),
              child: const Icon(
                Icons.copy_outlined,
                size: 16,
              ),
              onPressed: () {
                _copy();
              },
            ),
            body: Builder(
              builder: (context) => TabBarView(
                children: <Widget>[
                  buildRequestView(context),
                  if (showResponse) buildResponseView(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget builder that re-builds widget repeatedly with [duration] interval.
class _AutoUpdate extends StatefulWidget {
  const _AutoUpdate({required this.duration, required this.builder});

  /// Re-build interval.
  final Duration duration;

  /// Widget builder to build widget.
  final WidgetBuilder builder;

  @override
  _AutoUpdateState createState() => _AutoUpdateState();
}

class _AutoUpdateState extends State<_AutoUpdate> {
  Timer? _timer;

  void _setTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(widget.duration, (timer) {
      setState(() {});
    });
  }

  @override
  void didUpdateWidget(_AutoUpdate old) {
    if (old.duration != widget.duration) {
      _setTimer();
    }
    super.didUpdateWidget(old);
  }

  @override
  void initState() {
    _setTimer();
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }
}
