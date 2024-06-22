import 'package:freezed_annotation/freezed_annotation.dart';

part 'eden_view_state.freezed.dart';

/// 异常页面状态类型
enum EdenViewStateErrorType {
  normal,
  network,
}

/// 页面状态State
@freezed
class EdenViewState<T> with _$EdenViewState<T> {
  const factory EdenViewState.idle() = Idle; //空闲

  const factory EdenViewState.loading() = Loading; //加载

  const factory EdenViewState.empty() = Empty; //空布局

  const factory EdenViewState.ready(T data) = Ready<T>; //完成

  const factory EdenViewState.error({
    required EdenViewStateErrorType errorType,
    String? error,
  }) = Error; //错误
}
