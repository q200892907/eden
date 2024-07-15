// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'toy_command_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ToyVibrationCommandEntity _$ToyVibrationCommandEntityFromJson(
    Map<String, dynamic> json) {
  return _ToyVibrationCommandEntity.fromJson(json);
}

/// @nodoc
mixin _$ToyVibrationCommandEntity {
  num get duration => throw _privateConstructorUsedError;
  num get motor => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ToyVibrationCommandEntityCopyWith<ToyVibrationCommandEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ToyVibrationCommandEntityCopyWith<$Res> {
  factory $ToyVibrationCommandEntityCopyWith(ToyVibrationCommandEntity value,
          $Res Function(ToyVibrationCommandEntity) then) =
      _$ToyVibrationCommandEntityCopyWithImpl<$Res, ToyVibrationCommandEntity>;
  @useResult
  $Res call({num duration, num motor});
}

/// @nodoc
class _$ToyVibrationCommandEntityCopyWithImpl<$Res,
        $Val extends ToyVibrationCommandEntity>
    implements $ToyVibrationCommandEntityCopyWith<$Res> {
  _$ToyVibrationCommandEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? duration = null,
    Object? motor = null,
  }) {
    return _then(_value.copyWith(
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as num,
      motor: null == motor
          ? _value.motor
          : motor // ignore: cast_nullable_to_non_nullable
              as num,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ToyVibrationCommandEntityImplCopyWith<$Res>
    implements $ToyVibrationCommandEntityCopyWith<$Res> {
  factory _$$ToyVibrationCommandEntityImplCopyWith(
          _$ToyVibrationCommandEntityImpl value,
          $Res Function(_$ToyVibrationCommandEntityImpl) then) =
      __$$ToyVibrationCommandEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({num duration, num motor});
}

/// @nodoc
class __$$ToyVibrationCommandEntityImplCopyWithImpl<$Res>
    extends _$ToyVibrationCommandEntityCopyWithImpl<$Res,
        _$ToyVibrationCommandEntityImpl>
    implements _$$ToyVibrationCommandEntityImplCopyWith<$Res> {
  __$$ToyVibrationCommandEntityImplCopyWithImpl(
      _$ToyVibrationCommandEntityImpl _value,
      $Res Function(_$ToyVibrationCommandEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? duration = null,
    Object? motor = null,
  }) {
    return _then(_$ToyVibrationCommandEntityImpl(
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as num,
      motor: null == motor
          ? _value.motor
          : motor // ignore: cast_nullable_to_non_nullable
              as num,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ToyVibrationCommandEntityImpl
    with DiagnosticableTreeMixin
    implements _ToyVibrationCommandEntity {
  const _$ToyVibrationCommandEntityImpl(
      {required this.duration, required this.motor});

  factory _$ToyVibrationCommandEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$ToyVibrationCommandEntityImplFromJson(json);

  @override
  final num duration;
  @override
  final num motor;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ToyVibrationCommandEntity(duration: $duration, motor: $motor)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'ToyVibrationCommandEntity'))
      ..add(DiagnosticsProperty('duration', duration))
      ..add(DiagnosticsProperty('motor', motor));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ToyVibrationCommandEntityImpl &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.motor, motor) || other.motor == motor));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, duration, motor);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ToyVibrationCommandEntityImplCopyWith<_$ToyVibrationCommandEntityImpl>
      get copyWith => __$$ToyVibrationCommandEntityImplCopyWithImpl<
          _$ToyVibrationCommandEntityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ToyVibrationCommandEntityImplToJson(
      this,
    );
  }
}

abstract class _ToyVibrationCommandEntity implements ToyVibrationCommandEntity {
  const factory _ToyVibrationCommandEntity(
      {required final num duration,
      required final num motor}) = _$ToyVibrationCommandEntityImpl;

  factory _ToyVibrationCommandEntity.fromJson(Map<String, dynamic> json) =
      _$ToyVibrationCommandEntityImpl.fromJson;

  @override
  num get duration;
  @override
  num get motor;
  @override
  @JsonKey(ignore: true)
  _$$ToyVibrationCommandEntityImplCopyWith<_$ToyVibrationCommandEntityImpl>
      get copyWith => throw _privateConstructorUsedError;
}
