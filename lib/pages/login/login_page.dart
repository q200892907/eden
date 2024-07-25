import 'package:eden/providers/eden_user_provider.dart';
import 'package:eden/uikit/background/eden_background.dart';
import 'package:eden_uikit/eden_uikit.dart';
import 'package:flutter/material.dart';

import '../../router/eden_routes.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return EdenBackground(
      child: Scaffold(
        body: Center(
          child: OutlinedButton(
            onPressed: () {
              _login();
            },
            child: Text('登录'),
          ),
        ),
      ),
    );
  }

  void _login() {
    ref.read(edenUserNotifierProvider.notifier).login().then((value) {
      if (!value.isSuccess) {
        EdenToast.failed(value.message);
      } else {
        const HomeRoute().go(context);
      }
    });
  }
}
