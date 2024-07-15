import 'package:eden/router/eden_router.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () {
          const PlayRoute().push(context);
        },
        child: const Text('Play'),
      ),
    );
  }
}
