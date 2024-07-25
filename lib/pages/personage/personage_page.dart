import 'package:eden/uikit/background/eden_background.dart';
import 'package:eden/uikit/tips/unrealized_tips.dart';
import 'package:flutter/material.dart';

class PersonagePage extends StatelessWidget {
  const PersonagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const EdenBackground(child: UnrealizedTips(name: 'Personage'));
  }
}
