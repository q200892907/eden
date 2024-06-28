import 'package:eden/develop/custom/dio/lib/network_logger.dart';
import 'package:flutter/material.dart';

export 'package:eden/develop/custom/dio/lib/network_logger.dart';

class EdenDioTool extends StatefulWidget {
  const EdenDioTool({super.key});

  @override
  EdenDioToolState createState() => EdenDioToolState();
}

class EdenDioToolState extends State<EdenDioTool> {
  @override
  Widget build(BuildContext context) {
    return NetworkLoggerScreen();
  }
}
