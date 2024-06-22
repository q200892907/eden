import 'dart:async';

enum EdenLogType {
  debug,
  info,
  warning,
  error,
}

class EdenLogEntity {
  final String info;
  final EdenLogType type;
  late DateTime time;

  EdenLogEntity(this.info, this.type) : time = DateTime.now();
}

class EdenLogEventList {
  final _controller = StreamController<EdenLogUpdateEvent>.broadcast();

  /// Logged network events
  final events = <EdenLogEntity>[];

  /// A source of asynchronous network events.
  Stream<EdenLogUpdateEvent> get stream => _controller.stream;

  /// Add [event] to [events] list and notify dependents.
  void add(EdenLogType type, String event) {
    EdenLogEntity entity = EdenLogEntity(event, type);
    events.insert(0, entity);
    _controller.add(EdenLogUpdateEvent(entity));
  }

  /// Clear [events] and notify dependents.
  void clear() {
    events.clear();
    _controller.add(const EdenLogUpdateEvent.clear());
  }

  /// Dispose resources.
  void dispose() {
    _controller.close();
  }
}

class EdenLogUpdateEvent {
  const EdenLogUpdateEvent(this.event);

  const EdenLogUpdateEvent.clear() : event = null;

  final EdenLogEntity? event;
}

class EdenLogLogger extends EdenLogEventList {
  static final EdenLogLogger instance = EdenLogLogger();
}
