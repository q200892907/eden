import 'dart:async';
import 'dart:math';

import 'package:eden/entities/toy_command_entity.dart';
import 'package:eden/utils/vibration_utils.dart';
import 'package:eden_uikit/eden_uikit.dart';
import 'package:flutter/material.dart';

class EdenPlayGestureLinesNotifier
    extends ValueNotifier<List<List<ToyRoomCommandOffsetEntity>>> {
  EdenPlayGestureLinesNotifier() : super([]);

  void update(List<List<ToyRoomCommandOffsetEntity>> lines) {
    value = lines;
  }

  void reset() {
    value = [];
  }
}

typedef OnEdenPlayGestureChanged = void Function(
    List<int> vibrate, List<List<ToyRoomCommandOffsetEntity>> lines);

class EdenPlayGestureDetector extends StatefulWidget {
  const EdenPlayGestureDetector({
    super.key,
    required this.onChanged,
    required this.onStart,
    required this.onEnd,
    required this.linesNotifier,
  });

  final OnEdenPlayGestureChanged onChanged; //List长度为2
  final EdenPlayGestureLinesNotifier linesNotifier;
  final VoidCallback onStart;
  final VoidCallback onEnd;

  @override
  EdenPlayGestureDetectorState createState() => EdenPlayGestureDetectorState();
}

class EdenPlayGestureDetectorState extends State<EdenPlayGestureDetector> {
  Timer? _timer;
  final _LineNotifier _lineNotifier = _LineNotifier();

  Map<int, List<PointerEvent>> get _points => _lineNotifier.value;

  /// 200毫秒回调一次，减少刷新时间
  DateTime? _callbackTime;
  final int _callbackInterval = 50;
  late Size _size;

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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      _size = constraints.biggest;
      return Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
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
        ],
      );
    });
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
    widget.onStart.call();
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
      widget.onEnd.call();
    } else {
      int vibrate = _points.values.last.last.vibrate(_size.height);
      int mobileVibrate = 255 * vibrate ~/ 100;
      if (_points.length == 1) {
        widget.onChanged([vibrate, vibrate], _lineNotifier.lines);
      } else {
        widget.onChanged([
          vibrate,
          _points.values
              .toList()[_points.values.length - 2]
              .last
              .vibrate(_size.height)
        ], _lineNotifier.lines);
      }
      VibrationUtils.vibrate(
        amplitude: mobileVibrate,
        duration: _callbackInterval,
      );
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
  final endColor = EdenThemeBuilder.theme.primary.withOpacity(0.2);

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

extension on PointerEvent {
  int vibrate(double height) {
    num d = 1 - localPosition.dy / height;
    return ((max(0.0, min(1.0, d))) * 100).toInt();
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
