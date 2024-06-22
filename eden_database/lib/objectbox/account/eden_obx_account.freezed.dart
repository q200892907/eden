// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'eden_obx_account.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

EdenObxAccount _$EdenObxAccountFromJson(Map<String, dynamic> json) {
  return _EdenObxAccount.fromJson(json);
}

/// @nodoc
mixin _$EdenObxAccount {
  @Id()
  int get localId => throw _privateConstructorUsedError;
  @Id()
  set localId(int value) => throw _privateConstructorUsedError; //本地id
  String get id => throw _privateConstructorUsedError; //本地id
  set id(String value) => throw _privateConstructorUsedError; //服务器记录id
  String get accessToken => throw _privateConstructorUsedError; //服务器记录id
  set accessToken(String value) => throw _privateConstructorUsedError;
  String get refreshToken => throw _privateConstructorUsedError;
  set refreshToken(String value) => throw _privateConstructorUsedError;
  bool get isLogin => throw _privateConstructorUsedError;
  set isLogin(bool value) => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $EdenObxAccountCopyWith<EdenObxAccount> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EdenObxAccountCopyWith<$Res> {
  factory $EdenObxAccountCopyWith(
          EdenObxAccount value, $Res Function(EdenObxAccount) then) =
      _$EdenObxAccountCopyWithImpl<$Res, EdenObxAccount>;
  @useResult
  $Res call(
      {@Id() int localId,
      String id,
      String accessToken,
      String refreshToken,
      bool isLogin});
}

/// @nodoc
class _$EdenObxAccountCopyWithImpl<$Res, $Val extends EdenObxAccount>
    implements $EdenObxAccountCopyWith<$Res> {
  _$EdenObxAccountCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? localId = null,
    Object? id = null,
    Object? accessToken = null,
    Object? refreshToken = null,
    Object? isLogin = null,
  }) {
    return _then(_value.copyWith(
      localId: null == localId
          ? _value.localId
          : localId // ignore: cast_nullable_to_non_nullable
              as int,
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      accessToken: null == accessToken
          ? _value.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String,
      refreshToken: null == refreshToken
          ? _value.refreshToken
          : refreshToken // ignore: cast_nullable_to_non_nullable
              as String,
      isLogin: null == isLogin
          ? _value.isLogin
          : isLogin // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EdenObxAccountImplCopyWith<$Res>
    implements $EdenObxAccountCopyWith<$Res> {
  factory _$$EdenObxAccountImplCopyWith(_$EdenObxAccountImpl value,
          $Res Function(_$EdenObxAccountImpl) then) =
      __$$EdenObxAccountImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@Id() int localId,
      String id,
      String accessToken,
      String refreshToken,
      bool isLogin});
}

/// @nodoc
class __$$EdenObxAccountImplCopyWithImpl<$Res>
    extends _$EdenObxAccountCopyWithImpl<$Res, _$EdenObxAccountImpl>
    implements _$$EdenObxAccountImplCopyWith<$Res> {
  __$$EdenObxAccountImplCopyWithImpl(
      _$EdenObxAccountImpl _value, $Res Function(_$EdenObxAccountImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? localId = null,
    Object? id = null,
    Object? accessToken = null,
    Object? refreshToken = null,
    Object? isLogin = null,
  }) {
    return _then(_$EdenObxAccountImpl(
      localId: null == localId
          ? _value.localId
          : localId // ignore: cast_nullable_to_non_nullable
              as int,
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      accessToken: null == accessToken
          ? _value.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String,
      refreshToken: null == refreshToken
          ? _value.refreshToken
          : refreshToken // ignore: cast_nullable_to_non_nullable
              as String,
      isLogin: null == isLogin
          ? _value.isLogin
          : isLogin // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
@Entity(realClass: EdenObxAccount)
class _$EdenObxAccountImpl implements _EdenObxAccount {
  _$EdenObxAccountImpl(
      {@Id() this.localId = 0,
      required this.id,
      this.accessToken = '',
      this.refreshToken = '',
      this.isLogin = true});

  factory _$EdenObxAccountImpl.fromJson(Map<String, dynamic> json) =>
      _$$EdenObxAccountImplFromJson(json);

  @override
  @JsonKey()
  @Id()
  int localId;
//本地id
  @override
  String id;
//服务器记录id
  @override
  @JsonKey()
  String accessToken;
  @override
  @JsonKey()
  String refreshToken;
  @override
  @JsonKey()
  bool isLogin;

  @override
  String toString() {
    return 'EdenObxAccount(localId: $localId, id: $id, accessToken: $accessToken, refreshToken: $refreshToken, isLogin: $isLogin)';
  }

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$EdenObxAccountImplCopyWith<_$EdenObxAccountImpl> get copyWith =>
      __$$EdenObxAccountImplCopyWithImpl<_$EdenObxAccountImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EdenObxAccountImplToJson(
      this,
    );
  }
}

abstract class _EdenObxAccount implements EdenObxAccount {
  factory _EdenObxAccount(
      {@Id() int localId,
      required String id,
      String accessToken,
      String refreshToken,
      bool isLogin}) = _$EdenObxAccountImpl;

  factory _EdenObxAccount.fromJson(Map<String, dynamic> json) =
      _$EdenObxAccountImpl.fromJson;

  @override
  @Id()
  int get localId;
  @Id()
  set localId(int value);
  @override //本地id
  String get id; //本地id
  set id(String value);
  @override //服务器记录id
  String get accessToken; //服务器记录id
  set accessToken(String value);
  @override
  String get refreshToken;
  set refreshToken(String value);
  @override
  bool get isLogin;
  set isLogin(bool value);
  @override
  @JsonKey(ignore: true)
  _$$EdenObxAccountImplCopyWith<_$EdenObxAccountImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
