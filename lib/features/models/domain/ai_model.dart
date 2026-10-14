import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_model.freezed.dart';

enum TemplateType { chatml, llama2, phi, gemma, llama3, qwen, smol }

enum ModelSize { tiny, small, medium, large }

@freezed
class AIModel with _$AIModel {
  const factory AIModel({
    required String id,
    required String name,
    required int sizeMB,
    required String quant,
    @Default(false) bool isDownloaded,
    String? localPath,
    required TemplateType templateType,
    required String description,
    required String bestFor,
    @Default('') String hfUrl,
    @Default(4096) int contextWindow,
    @Default(ModelSize.small) ModelSize sizeCategory,
    @Default(false) bool isMultimodal,
    @Default([]) List<String> recommendedFor,
  }) = _AIModel;
}
