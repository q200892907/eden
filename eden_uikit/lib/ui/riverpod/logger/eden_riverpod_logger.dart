// Package imports:
import 'package:eden_logger/eden_logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EdenRiverpodLogger extends ProviderObserver {
  final bool isDebug;

  EdenRiverpodLogger({this.isDebug = false});

  @override
  void providerDidFail(
    ProviderBase provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    final errorMap = <String, String>{
      'error': error.toString(),
      'stackTrace': stackTrace.toString(),
    };

    EdenLogger.e(
        '${provider.runtimeType}@${provider.hashCode}:${errorMap.toString()}');
  }

  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    if (isDebug) {
      EdenLogger.d(
          '${provider.runtimeType}@${provider.hashCode}:$previousValue->$newValue');
    }
  }
}
