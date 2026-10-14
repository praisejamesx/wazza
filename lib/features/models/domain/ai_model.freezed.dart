// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AIModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int get sizeMB => throw _privateConstructorUsedError;
  String get quant => throw _privateConstructorUsedError;
  bool get isDownloaded => throw _privateConstructorUsedError;
  String? get localPath => throw _privateConstructorUsedError;
  TemplateType get templateType => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get bestFor => throw _privateConstructorUsedError;
  String get hfUrl => throw _privateConstructorUsedError;
  int get contextWindow => throw _privateConstructorUsedError;
  ModelSize get sizeCategory => throw _privateConstructorUsedError;
  bool get isMultimodal => throw _privateConstructorUsedError;
  List<String> get recommendedFor => throw _privateConstructorUsedError;

  /// Create a copy of AIModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AIModelCopyWith<AIModel> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AIModelCopyWith<$Res> {
  factory $AIModelCopyWith(AIModel value, $Res Function(AIModel) then) =
      _$AIModelCopyWithImpl<$Res, AIModel>;
  @useResult
  $Res call(
      {String id,
      String name,
      int sizeMB,
      String quant,
      bool isDownloaded,
      String? localPath,
      TemplateType templateType,
      String description,
      String bestFor,
      String hfUrl,
      int contextWindow,
      ModelSize sizeCategory,
      bool isMultimodal,
      List<String> recommendedFor});
}

/// @nodoc
class _$AIModelCopyWithImpl<$Res, $Val extends AIModel>
    implements $AIModelCopyWith<$Res> {
  _$AIModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AIModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? sizeMB = null,
    Object? quant = null,
    Object? isDownloaded = null,
    Object? localPath = freezed,
    Object? templateType = null,
    Object? description = null,
    Object? bestFor = null,
    Object? hfUrl = null,
    Object? contextWindow = null,
    Object? sizeCategory = null,
    Object? isMultimodal = null,
    Object? recommendedFor = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      sizeMB: null == sizeMB
          ? _value.sizeMB
          : sizeMB // ignore: cast_nullable_to_non_nullable
              as int,
      quant: null == quant
          ? _value.quant
          : quant // ignore: cast_nullable_to_non_nullable
              as String,
      isDownloaded: null == isDownloaded
          ? _value.isDownloaded
          : isDownloaded // ignore: cast_nullable_to_non_nullable
              as bool,
      localPath: freezed == localPath
          ? _value.localPath
          : localPath // ignore: cast_nullable_to_non_nullable
              as String?,
      templateType: null == templateType
          ? _value.templateType
          : templateType // ignore: cast_nullable_to_non_nullable
              as TemplateType,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      bestFor: null == bestFor
          ? _value.bestFor
          : bestFor // ignore: cast_nullable_to_non_nullable
              as String,
      hfUrl: null == hfUrl
          ? _value.hfUrl
          : hfUrl // ignore: cast_nullable_to_non_nullable
              as String,
      contextWindow: null == contextWindow
          ? _value.contextWindow
          : contextWindow // ignore: cast_nullable_to_non_nullable
              as int,
      sizeCategory: null == sizeCategory
          ? _value.sizeCategory
          : sizeCategory // ignore: cast_nullable_to_non_nullable
              as ModelSize,
      isMultimodal: null == isMultimodal
          ? _value.isMultimodal
          : isMultimodal // ignore: cast_nullable_to_non_nullable
              as bool,
      recommendedFor: null == recommendedFor
          ? _value.recommendedFor
          : recommendedFor // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AIModelImplCopyWith<$Res> implements $AIModelCopyWith<$Res> {
  factory _$$AIModelImplCopyWith(
          _$AIModelImpl value, $Res Function(_$AIModelImpl) then) =
      __$$AIModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      int sizeMB,
      String quant,
      bool isDownloaded,
      String? localPath,
      TemplateType templateType,
      String description,
      String bestFor,
      String hfUrl,
      int contextWindow,
      ModelSize sizeCategory,
      bool isMultimodal,
      List<String> recommendedFor});
}

/// @nodoc
class __$$AIModelImplCopyWithImpl<$Res>
    extends _$AIModelCopyWithImpl<$Res, _$AIModelImpl>
    implements _$$AIModelImplCopyWith<$Res> {
  __$$AIModelImplCopyWithImpl(
      _$AIModelImpl _value, $Res Function(_$AIModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of AIModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? sizeMB = null,
    Object? quant = null,
    Object? isDownloaded = null,
    Object? localPath = freezed,
    Object? templateType = null,
    Object? description = null,
    Object? bestFor = null,
    Object? hfUrl = null,
    Object? contextWindow = null,
    Object? sizeCategory = null,
    Object? isMultimodal = null,
    Object? recommendedFor = null,
  }) {
    return _then(_$AIModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      sizeMB: null == sizeMB
          ? _value.sizeMB
          : sizeMB // ignore: cast_nullable_to_non_nullable
              as int,
      quant: null == quant
          ? _value.quant
          : quant // ignore: cast_nullable_to_non_nullable
              as String,
      isDownloaded: null == isDownloaded
          ? _value.isDownloaded
          : isDownloaded // ignore: cast_nullable_to_non_nullable
              as bool,
      localPath: freezed == localPath
          ? _value.localPath
          : localPath // ignore: cast_nullable_to_non_nullable
              as String?,
      templateType: null == templateType
          ? _value.templateType
          : templateType // ignore: cast_nullable_to_non_nullable
              as TemplateType,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      bestFor: null == bestFor
          ? _value.bestFor
          : bestFor // ignore: cast_nullable_to_non_nullable
              as String,
      hfUrl: null == hfUrl
          ? _value.hfUrl
          : hfUrl // ignore: cast_nullable_to_non_nullable
              as String,
      contextWindow: null == contextWindow
          ? _value.contextWindow
          : contextWindow // ignore: cast_nullable_to_non_nullable
              as int,
      sizeCategory: null == sizeCategory
          ? _value.sizeCategory
          : sizeCategory // ignore: cast_nullable_to_non_nullable
              as ModelSize,
      isMultimodal: null == isMultimodal
          ? _value.isMultimodal
          : isMultimodal // ignore: cast_nullable_to_non_nullable
              as bool,
      recommendedFor: null == recommendedFor
          ? _value._recommendedFor
          : recommendedFor // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc

class _$AIModelImpl implements _AIModel {
  const _$AIModelImpl(
      {required this.id,
      required this.name,
      required this.sizeMB,
      required this.quant,
      this.isDownloaded = false,
      this.localPath,
      required this.templateType,
      required this.description,
      required this.bestFor,
      this.hfUrl = '',
      this.contextWindow = 4096,
      this.sizeCategory = ModelSize.small,
      this.isMultimodal = false,
      final List<String> recommendedFor = const []})
      : _recommendedFor = recommendedFor;

  @override
  final String id;
  @override
  final String name;
  @override
  final int sizeMB;
  @override
  final String quant;
  @override
  @JsonKey()
  final bool isDownloaded;
  @override
  final String? localPath;
  @override
  final TemplateType templateType;
  @override
  final String description;
  @override
  final String bestFor;
  @override
  @JsonKey()
  final String hfUrl;
  @override
  @JsonKey()
  final int contextWindow;
  @override
  @JsonKey()
  final ModelSize sizeCategory;
  @override
  @JsonKey()
  final bool isMultimodal;
  final List<String> _recommendedFor;
  @override
  @JsonKey()
  List<String> get recommendedFor {
    if (_recommendedFor is EqualUnmodifiableListView) return _recommendedFor;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recommendedFor);
  }

  @override
  String toString() {
    return 'AIModel(id: $id, name: $name, sizeMB: $sizeMB, quant: $quant, isDownloaded: $isDownloaded, localPath: $localPath, templateType: $templateType, description: $description, bestFor: $bestFor, hfUrl: $hfUrl, contextWindow: $contextWindow, sizeCategory: $sizeCategory, isMultimodal: $isMultimodal, recommendedFor: $recommendedFor)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AIModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.sizeMB, sizeMB) || other.sizeMB == sizeMB) &&
            (identical(other.quant, quant) || other.quant == quant) &&
            (identical(other.isDownloaded, isDownloaded) ||
                other.isDownloaded == isDownloaded) &&
            (identical(other.localPath, localPath) ||
                other.localPath == localPath) &&
            (identical(other.templateType, templateType) ||
                other.templateType == templateType) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.bestFor, bestFor) || other.bestFor == bestFor) &&
            (identical(other.hfUrl, hfUrl) || other.hfUrl == hfUrl) &&
            (identical(other.contextWindow, contextWindow) ||
                other.contextWindow == contextWindow) &&
            (identical(other.sizeCategory, sizeCategory) ||
                other.sizeCategory == sizeCategory) &&
            (identical(other.isMultimodal, isMultimodal) ||
                other.isMultimodal == isMultimodal) &&
            const DeepCollectionEquality()
                .equals(other._recommendedFor, _recommendedFor));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      sizeMB,
      quant,
      isDownloaded,
      localPath,
      templateType,
      description,
      bestFor,
      hfUrl,
      contextWindow,
      sizeCategory,
      isMultimodal,
      const DeepCollectionEquality().hash(_recommendedFor));

  /// Create a copy of AIModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AIModelImplCopyWith<_$AIModelImpl> get copyWith =>
      __$$AIModelImplCopyWithImpl<_$AIModelImpl>(this, _$identity);
}

abstract class _AIModel implements AIModel {
  const factory _AIModel(
      {required final String id,
      required final String name,
      required final int sizeMB,
      required final String quant,
      final bool isDownloaded,
      final String? localPath,
      required final TemplateType templateType,
      required final String description,
      required final String bestFor,
      final String hfUrl,
      final int contextWindow,
      final ModelSize sizeCategory,
      final bool isMultimodal,
      final List<String> recommendedFor}) = _$AIModelImpl;

  @override
  String get id;
  @override
  String get name;
  @override
  int get sizeMB;
  @override
  String get quant;
  @override
  bool get isDownloaded;
  @override
  String? get localPath;
  @override
  TemplateType get templateType;
  @override
  String get description;
  @override
  String get bestFor;
  @override
  String get hfUrl;
  @override
  int get contextWindow;
  @override
  ModelSize get sizeCategory;
  @override
  bool get isMultimodal;
  @override
  List<String> get recommendedFor;

  /// Create a copy of AIModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AIModelImplCopyWith<_$AIModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
