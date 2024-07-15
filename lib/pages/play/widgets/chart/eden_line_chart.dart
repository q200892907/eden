import 'package:blur/blur.dart';
import 'package:eden/entities/toy_command_entity.dart';
import 'package:eden_uikit/eden_uikit.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class EdenLineChart extends StatefulWidget {
  const EdenLineChart({
    super.key,
    required this.chart,
    required this.onEnd,
    required this.isOnlyShow,
  });

  final bool isOnlyShow;
  final ToyChartEntity chart;
  final VoidCallback onEnd;

  @override
  State<EdenLineChart> createState() => _EdenLineChartState();
}

class _EdenLineChartState extends State<EdenLineChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: widget.chart.totalTime.toInt()));
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
    _init();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _reset() {
    _animationController.reset();
  }

  void _init() {
    if (!widget.isOnlyShow) {
      _reset();
      _animationController.forward().then((value) {
        widget.onEnd.call();
      });
    }
  }

  @override
  void didUpdateWidget(covariant EdenLineChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xff080709).withOpacity(0.5),
      height: 167.w,
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (c, child) {
                return Row(
                  children: [
                    Expanded(
                      flex: (_animation.value * 100).toInt(),
                      child: Container(
                        color: const Color(0xffb8a9a9).withOpacity(0.1),
                      ),
                    ),
                    Expanded(
                      flex: (100 - _animation.value * 100).toInt(),
                      child: EdenEmpty.ui,
                    )
                  ],
                );
              },
            ),
          ),
          Positioned.fill(
            top: 16.w,
            bottom: 56.w,
            child: LineChart(
              _buildLineChartData(
                const Color(0xffFF47B5),
                const Color(0xffFF47B5).withOpacity(0.3),
              ),
            ),
          ),
          Positioned.fill(
            top: 16.w,
            bottom: 56.w,
            child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        colors: const [
                          Colors.white,
                          Colors.white,
                          Colors.transparent,
                          Colors.transparent,
                        ],
                        stops: [0, _animation.value, _animation.value, 1],
                      ).createShader(bounds);
                    },
                    child: LineChart(
                      _buildLineChartData(
                        const Color(0xffb8a9a9),
                        const Color(0xff706a6a),
                      ),
                    ),
                  );
                }),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 20.w,
            child: Center(
              child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Text.rich(
                      TextSpan(
                        text: '',
                        children: [
                          TextSpan(
                              text:
                                  '${(_animation.value * widget.chart.totalTime / 1000).toStringAsFixed(1)}\' ',
                              style: 16
                                  .sp
                                  .ts
                                  .bold
                                  .copyWith(color: const Color(0xffFF47B5))),
                          TextSpan(
                              text:
                                  ' / ${(widget.chart.totalTime / 1000).toStringAsFixed(1)}\'',
                              style: 16
                                  .sp
                                  .ts
                                  .bold
                                  .copyWith(color: const Color(0xffb8a9a9))),
                        ],
                      ),
                    );
                  }),
            ),
          ),
        ],
      ),
    ).frosted();
  }

  LineChartData _buildLineChartData(Color color, Color belowBarColor,
      {Color backgroundColor = Colors.transparent}) {
    return LineChartData(
      minX: 0,
      maxX: widget.chart.totalTime.toDouble(),
      minY: -10,
      maxY: 110,
      lineBarsData: [
        LineChartBarData(
          spots: widget.chart.points
              .map((e) => FlSpot(e.x.toDouble(), e.y.toDouble()))
              .toList(),
          isCurved: true,
          curveSmoothness: 0.2,
          color: color,
          barWidth: 0.5.w,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                belowBarColor,
                belowBarColor.withOpacity(0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
      borderData: FlBorderData(show: false),
      gridData: const FlGridData(show: false),
      titlesData: const FlTitlesData(show: false),
      lineTouchData: const LineTouchData(enabled: false),
      backgroundColor: backgroundColor,
    );
  }
}
