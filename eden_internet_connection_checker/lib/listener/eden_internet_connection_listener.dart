import 'package:eden_internet_connection_checker/eden_internet_connection_checker.dart';
import 'package:flutter/material.dart';

abstract class EdenInternetConnectionListener {
  void onInternetConnectionChanged(InternetStatus status);
}

mixin EdenInternetConnectMixin<T extends StatefulWidget> on State<T>
    implements EdenInternetConnectionListener {
  @override
  void initState() {
    super.initState();
    EdenInternetConnection.instance.addListener(this);
  }

  @override
  void dispose() {
    EdenInternetConnection.instance.removeListener(this);
    super.dispose();
  }
}
