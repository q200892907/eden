import 'dart:async';
import 'dart:math';

import 'package:eden/entities/toy_command_entity.dart';
import 'package:eden/utils/vibration_utils.dart';
import 'package:eden_intl/eden_intl.dart';
import 'package:eden_uikit/eden_uikit.dart';
import 'package:flutter/material.dart';

const int _addTime = 2;

class EdenPlayGestureLinesNotifier
    extends ValueNotifier<List<List<ToyRoomCommandOffsetEntity>>> {
  EdenPlayGestureLinesNotifier() : super([]);

  void update(List<List<ToyRoomCommandOffsetEntity>> lines) {
    value = lines;
  }
}

class EdenPlayGestureNotifier extends ValueNotifier<bool> {
  EdenPlayGestureNotifier() : super(false);

  int _time = 0;
  Timer? _timer;

  int get time => _time;

  void start(int num) {
    if (_time != num) {
      _time = num + _addTime;
    }
    value = _time != 0;
    if (value) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer ??= Timer(
      Duration(seconds: _time),
      () {
        stop();
      },
    );
  }

  void stop() {
    _time = 0;
    value = false;
    _timer?.cancel();
    _timer = null;
  }
}

typedef OnEdenPlayGestureChanged = void Function(
    List<int> vibrate, List<List<ToyRoomCommandOffsetEntity>> lines);

class EdenPlayGestureDetector extends StatefulWidget {
  const EdenPlayGestureDetector({
    super.key,
    required this.onChanged,
    required this.notifier,
    required this.onEnd,
    required this.linesNotifier,
  });

  final OnEdenPlayGestureChanged onChanged; //List长度为2
  final EdenPlayGestureNotifier notifier;
  final EdenPlayGestureLinesNotifier linesNotifier;
  final VoidCallback onEnd;

  @override
  EdenPlayGestureDetectorState createState() => EdenPlayGestureDetectorState();
}

class EdenPlayGestureDetectorState extends State<EdenPlayGestureDetector> {
  Timer? _timer;
  Timer? _tipsTimer;
  final _LineNotifier _lineNotifier = _LineNotifier();
  final ValueNotifier<bool> _tips = ValueNotifier(false);

  Map<int, List<PointerEvent>> get _points => _lineNotifier.value;

  /// 200毫秒回调一次，减少刷新时间
  DateTime? _callbackTime;
  final int _callbackInterval = 50;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    super.dispose();
    _callbackTime = null;
    _stopTimer();
    _stopTipsTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      _lineNotifier.auto();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _startTipsTimer() {
    _tips.value = true;
    _tipsTimer ??= Timer(const Duration(seconds: _addTime), () {
      _stopTipsTimer();
    });
  }

  void _stopTipsTimer() {
    _tips.value = false;
    _tipsTimer?.cancel();
    _tipsTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.notifier,
      builder: (_, value, child) {
        if (!value) {
          widget.onEnd.call();
        }
        if (value) {
          _startTipsTimer();
        }
        return Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: Offstage(
                offstage: !value,
                child: child,
              ),
            ),
            ValueListenableBuilder(
                valueListenable: widget.linesNotifier,
                builder: (context, value, child) {
                  return Visibility(
                    visible: value.isNotEmpty,
                    child: Positioned.fill(
                      child: CustomPaint(
                        painter: LinePainter(
                          pointsMap: value,
                        ),
                        size: Size.infinite,
                      ),
                    ),
                  );
                }),
            ValueListenableBuilder(
                valueListenable: _tips,
                builder: (context, value, child) {
                  return Visibility(
                    visible: value,
                    child: Positioned.fill(
                      child: Center(
                        child: DefaultTextStyle(
                          style: 40.spts,
                          child: FadeIn(
                            child: Text(context.strings.play), //todo
                          ),
                        ),
                      ),
                    ),
                  );
                }),
          ],
        );
      },
      child: Listener(
        onPointerDown: (event) {
          _start(event);
        },
        onPointerMove: (event) {
          _move(event);
        },
        onPointerUp: (event) {
          _end(event);
        },
        onPointerCancel: (event) {
          _end(event);
        },
        child: ValueListenableBuilder<Map<int, List<PointerEvent>>>(
          valueListenable: _lineNotifier,
          builder: (context, value, child) {
            return CustomPaint(
              painter: LinePainter(
                pointsMap: _lineNotifier.lines,
              ),
              size: Size.infinite,
            );
          },
        ),
      ),
    );
  }

  void _end(PointerEvent event) {
    _lineNotifier.end(event);
    _callback(true);
  }

  void _move(PointerEvent event) {
    _lineNotifier.move(event);
    _callback();
  }

  void _start(PointerEvent event) {
    _lineNotifier.start(event);
    _callback();
  }

  void _callback([bool end = false]) {
    if (!end &&
        _callbackTime != null &&
        (_callbackTime?.difference(DateTime.now()).inMilliseconds.abs() ?? 0) <
            _callbackInterval) {
      return;
    }
    _callbackTime = DateTime.now();
    VibrationUtils.cancel();
    if (end || _points.isEmpty) {
      widget.onChanged([0, 0], []);
    } else {
      Offset? offset;
      _points.forEach((key, value) {
        if (value.isNotEmpty) {
          if (offset != null) {
            if (value.last.delta.distance > offset!.distance) {
              offset = value.last.delta;
            }
          } else {
            offset = value.last.delta;
          }
        }
      });
      int vibrate = _points.values.last.last.delta.vibrate;
      int mobileVibrate = 255 * vibrate ~/ 100;
      if (_points.length == 1) {
        widget.onChanged([vibrate, vibrate], _lineNotifier.lines);
      } else {
        widget.onChanged([
          vibrate,
          _points.values.toList()[_points.values.length - 2].last.delta.vibrate
        ], _lineNotifier.lines);
      }
      VibrationUtils.vibrate(
          amplitude: mobileVibrate, duration: _callbackInterval);
    }
  }
}

class _LineNotifier extends ValueNotifier<Map<int, List<PointerEvent>>> {
  _LineNotifier() : super({});

  List<List<ToyRoomCommandOffsetEntity>> get lines {
    return value.values
        .map((e) => e.map((e1) => e1.localPosition.commandOffset).toList())
        .toList();
  }

  void start(PointerEvent event) {
    value[event.pointer] = [event];
    notifyListeners();
  }

  void move(PointerEvent event) {
    List<PointerEvent>? temp = value[event.pointer];
    if (temp != null) {
      temp.add(event);
      if (temp.length > 30) {
        temp = temp.sublist(temp.length - 30);
      }
      value[event.pointer] = temp;
      notifyListeners();
    }
  }

  void end(PointerEvent event) {
    Timer.periodic(const Duration(milliseconds: 10), (timer) {
      value[event.pointer]?.removeAt(0);
      notifyListeners();
      if (value[event.pointer]?.isEmpty ?? false) {
        timer.cancel();
        value.remove(event.pointer);
      }
    });
  }

  void auto() {
    value.forEach((key, value1) {
      if (value1.length > 1) {
        value1.removeAt(0);
        notifyListeners();
      }
    });
  }
}

class LinePainter extends CustomPainter {
  final List<List<ToyRoomCommandOffsetEntity>> pointsMap;
  final double radius;
  final startColor = EdenThemeBuilder.theme.primary;
  final endColor = const Color(0xffFF47B5);

  LinePainter({
    required this.pointsMap,
    this.radius = 10,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = EdenThemeBuilder.theme.primary
      ..strokeWidth = radius * 2
      ..strokeCap = StrokeCap.round;

    for (var value in pointsMap) {
      double width = radius * 2;
      for (int i = 0; i < value.length - 1; i++) {
        double lineWidth = i / (value.length - 1) * width;
        double percent = 1 - min(1, i / (value.length - 1));
        final transitionColor = Color.lerp(startColor, endColor, percent);

        canvas.drawLine(
          value[i].offset,
          value[i + 1].offset,
          paint
            ..strokeWidth = lineWidth
            ..color = transitionColor ?? startColor,
        );
      }
      canvas.drawCircle(value.last.offset, radius, paint..color = startColor);
    }
  }

  @override
  bool shouldRepaint(LinePainter oldDelegate) => true;
}

extension OffsetDragTrailExtension on Offset {
  static const double _max = 15;

  int get vibrate {
    double d = min(distance, _max);
    return (d / _max * 100).toInt();
  }
}

class FadeIn extends StatefulWidget {
  const FadeIn({super.key, required this.child});

  final Widget child;

  @override
  State<FadeIn> createState() => _FadeInState();
}

class _FadeInState extends State<FadeIn> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation =
        Tween<double>(begin: 1, end: 0.3).animate(_animationController);
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _animationController.forward();
      }
    });
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (BuildContext context, Widget? child) {
        return Opacity(
          opacity: _animation.value,
          child: widget.child,
        );
      },
      child: widget.child,
    );
  }
}
