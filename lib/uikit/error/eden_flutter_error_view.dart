import 'package:flutter/material.dart';

class EdenFlutterErrorView extends StatelessWidget {
  const EdenFlutterErrorView({super.key, required this.errorDetails});

  final FlutterErrorDetails errorDetails;

  @override
  Widget build(BuildContext context) {
    return Text(errorDetails.toString());
  }
}
