// lib/models/ai_model.dart
enum TemplateType { chatml, llama2, phi, gemma, llama3, qwen }

class AIModel {
  final String id;
  final String name;
  final int sizeMB;
  final String quant;
  bool isDownloaded;
  String? localPath;
  final TemplateType templateType;
  final String description;
  final String bestFor;

  AIModel({
    required this.id,
    required this.name,
    required this.sizeMB,
    required this.quant,
    this.isDownloaded = false,
    this.localPath,
    required this.templateType,
    required this.description,
    required this.bestFor,
  });

  static TemplateType inferTemplate(String id) {
    if (id.contains('qwen')) return TemplateType.qwen;
    if (id.contains('gemma')) return TemplateType.gemma;
    if (id.contains('phi')) return TemplateType.phi;
    if (id.contains('llama3')) return TemplateType.llama3;
    if (id.contains('llama') || id.contains('tinyllama')) return TemplateType.llama2;
    return TemplateType.chatml;
  }

  static void syncWithDownloadedModels(List<AIModel> downloaded) {
    for (var downloadedModel in downloaded) {
      final remoteIndex = remoteModels.indexWhere((m) => m.id == downloadedModel.id);
      if (remoteIndex >= 0) {
        remoteModels[remoteIndex].isDownloaded = true;
        remoteModels[remoteIndex].localPath = downloadedModel.localPath;
      }
    }
  }

  static void markAsDownloaded(AIModel remoteModel, String localPath) {
    final existingIndex = downloadedModels.indexWhere((m) => m.id == remoteModel.id);
    
    if (existingIndex >= 0) {
      downloadedModels[existingIndex].localPath = localPath;
      downloadedModels[existingIndex].isDownloaded = true;
    } else {
      final downloaded = AIModel(
        id: remoteModel.id,
        name: remoteModel.name,
        sizeMB: remoteModel.sizeMB,
        quant: remoteModel.quant,
        isDownloaded: true,
        localPath: localPath,
        templateType: remoteModel.templateType,
        description: remoteModel.description,
        bestFor: remoteModel.bestFor,
      );
      downloadedModels.add(downloaded);
    }
    
    final remoteIndex = remoteModels.indexWhere((m) => m.id == remoteModel.id);
    if (remoteIndex >= 0) {
      remoteModels[remoteIndex].isDownloaded = true;
      remoteModels[remoteIndex].localPath = localPath;
    }
  }

  static void markAsNotDownloaded(String modelId) {
    downloadedModels.removeWhere((m) => m.id == modelId);
    
    final remoteIndex = remoteModels.indexWhere((m) => m.id == modelId);
    if (remoteIndex >= 0) {
      remoteModels[remoteIndex].isDownloaded = false;
      remoteModels[remoteIndex].localPath = null;
    }
  }

  static bool listDownloaded(String id) {
    if (downloadedModels.any((m) => m.id == id)) return true;
    
    final remoteIndex = remoteModels.indexWhere((m) => m.id == id);
    if (remoteIndex >= 0) {
      return remoteModels[remoteIndex].isDownloaded;
    }
    
    return false;
  }

  // 🚀 PRODUCTION MODEL CATALOG - Curated for quality & variety
  static List<AIModel> remoteModels = [
    AIModel(
      id: 'qwen1_5_1_8b',
      name: 'Qwen1.5-1.8B',
      sizeMB: 1200,
      quant: 'Q4_K_M',
      templateType: TemplateType.qwen,
      description: 'Excellent multilingual model.',
      bestFor: 'Multilingual tasks, coding, general chat',
    ),
    AIModel(
      id: 'phi2',
      name: 'Phi-2',
      sizeMB: 1800,
      quant: 'Q4_K_M',
      templateType: TemplateType.phi,
      description: 'Microsoft\'s compact reasoning expert. Exceptional logic and math skills.',
      bestFor: 'Reasoning, math, coding, technical questions',
    ),
    AIModel(
      id: 'gemma1_5b',
      name: 'Gemma 1.5B',
      sizeMB: 1500,
      quant: 'Q4_K_M',
      templateType: TemplateType.gemma,
      description: 'Google\'s modern, efficient model. Well-rounded and reliable.',
      bestFor: 'General chat, creative writing, analysis',
    ),
    AIModel(
      id: 'tinyllama',
      name: 'TinyLlama 1.1B (Test Only)',
      sizeMB: 640,
      quant: 'Q4_K_M',
      templateType: TemplateType.llama2,
      description: '⚠️ FAST TEST MODEL - Limited capability. Download in 30 seconds for quick testing.',
      bestFor: 'Quick app testing only',
    ),
  ];

  static List<AIModel> downloadedModels = [];
}