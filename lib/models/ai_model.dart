// lib/models/ai_model.dart
enum TemplateType { chatml, llama2, phi, gemma, llama3 }

class AIModel {
  final String id;
  final String name;
  final int sizeMB;
  final String quant;
  final bool isDownloaded;
  final String? localPath;
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

  // Helper to auto-assign template based on model ID
  static TemplateType inferTemplate(String id) {
    if (id.contains('qwen')) return TemplateType.chatml;
    if (id.contains('tinyllama') || id.contains('llama') && !id.contains('3')) return TemplateType.llama2;
    if (id.contains('phi')) return TemplateType.phi;
    if (id.contains('gemma')) return TemplateType.gemma;
    if (id.contains('llama3') || id.contains('mobilellama')) return TemplateType.llama3;
    return TemplateType.chatml; // default fallback
  }

  
  static List<AIModel> remoteModels = [
    AIModel(
      id: 'tinyllama',
      name: 'TinyLlama 1.1B',
      sizeMB: 640,
      quant: 'Q4_K_M',
      templateType: TemplateType.llama2,
      description: 'Ultra-lightweight model that runs fast even on 1GB RAM phones.',
      bestFor: 'General chat, simple Q&A, offline use.',
    ),
    AIModel(
      id: 'phi2',
      name: 'Phi-2',
      sizeMB: 1800,
      quant: 'Q5_K_M',
      templateType: TemplateType.phi,
      description: 'Compact reasoning model with strong logic and coding skills.',
      bestFor: 'Math, code, technical explanations.',
    ),
    // Add more models in future versions
  ];

  static List<AIModel> downloadedModels = [];

  static void markAsDownloaded(AIModel remoteModel, String localPath) {
    final downloaded = AIModel(
      id: remoteModel.id,
      name: remoteModel.name,
      sizeMB: remoteModel.sizeMB,
      quant: remoteModel.quant,
      isDownloaded: true,
      localPath: localPath,
      templateType: remoteModel.templateType, // ✅ Preserve templateType
      description: remoteModel.description,
      bestFor: remoteModel.bestFor
    );
    downloadedModels.add(downloaded);
  }

  static bool listDownloaded(String id) {
    return downloadedModels.any((m) => m.id == id);
  }
}