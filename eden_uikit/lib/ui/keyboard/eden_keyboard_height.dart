import 'dart:io';

import 'package:eden_uikit/eden_uikit.dart';
import 'package:flutter/material.dart';

export 'package:eden_utils/eden_utils.dart';

class EdenKeyboardHeight {
  factory EdenKeyboardHeight() => _getInstance();

  static EdenKeyboardHeight get instance => _getInstance();
  static EdenKeyboardHeight? _instance;

  static EdenKeyboardHeight _getInstance() {
    _instance ??= EdenKeyboardHeight._internal();
    return _instance!;
  }

  EdenKeyboardHeight._internal() {
    _keyboardHeight.addListener(() {
      for (var listener in _listeners) {
        listener.call(_keyboardHeight.value);
      }
    });
  }

  final Set<ValueChanged<double>> _listeners = {};
  final ValueNotifier<double> _keyboardHeight = ValueNotifier(0);

  String get _key => 'eden_keyboard_height';

  void addListener(ValueChanged<double> listener) {
    _listeners.add(listener);
  }

  void removeListener(ValueChanged<double> listener) {
    _listeners.remove(listener);
  }

  void _changeKeyboardHeight(double height) {
    if (_keyboardHeight.value != height && height > 10) {
      EdenDebounce.debounce(_key, const Duration(milliseconds: 0), () {
        _keyboardHeight.value = height;
      });
    } else {
      EdenDebounce.cancel(_key);
    }
  }
}

class EdenKeyboardHeightProvider extends StatefulWidget {
  const EdenKeyboardHeightProvider({super.key, required this.child});

  final Widget child;

  @override
  State<EdenKeyboardHeightProvider> createState() =>
      _EdenKeyboardHeightProviderState();
}

class _EdenKeyboardHeightProviderState extends State<EdenKeyboardHeightProvider>
    with WidgetsBindingMixin {
  late final KeyboardHeightPlugin _keyboardHeightPlugin;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid || Platform.isIOS) {
      _keyboardHeightPlugin = KeyboardHeightPlugin();
      _keyboardHeightPlugin.onKeyboardHeightChanged((double height) {
        if (height == 0) {
          return;
        }
        EdenKeyboardHeight.instance._changeKeyboardHeight(height);
      });
    }
  }

  @override
  void dispose() {
    if (Platform.isAndroid || Platform.isIOS) {
      _keyboardHeightPlugin.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
