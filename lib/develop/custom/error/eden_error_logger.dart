import 'dart:async';

import 'package:eden_logger/eden_logger.dart';
import 'package:flutter/material.dart';

class EdenErrorEventList {
  final _controller = StreamController<EdenErrorUpdateEvent>.broadcast();

  /// Logged network events
  final events = <FlutterErrorDetails>[];

  /// A source of asynchronous network events.
  Stream<EdenErrorUpdateEvent> get stream => _controller.stream;

  /// Add [event] to [events] list and notify dependents.
  void add(FlutterErrorDetails event) {
    events.insert(0, event);
    _controller.add(EdenErrorUpdateEvent(event));
    EdenLogFile.write(info: event.toString(), type: EdenLogType.error);
  }

  /// Clear [events] and notify dependents.
  void clear() {
    events.clear();
    _controller.add(const EdenErrorUpdateEvent.clear());
  }

  /// Dispose resources.
  void dispose() {
    _controller.close();
  }
}

class EdenErrorUpdateEvent {
  const EdenErrorUpdateEvent(this.event);

  const EdenErrorUpdateEvent.clear() : event = null;

  final FlutterErrorDetails? event;
}

class EdenErrorLogger extends EdenErrorEventList {
  static final EdenErrorLogger instance = EdenErrorLogger();
}
