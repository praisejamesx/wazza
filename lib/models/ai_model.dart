// lib/models/ai_model.dart - COMPLETE CORRECTED VERSION
enum TemplateType { chatml, llama2, phi, gemma, llama3 }

class AIModel {
  final String id;
  final String name;
  final int sizeMB;
  final String quant;
  bool isDownloaded; // Changed from final
  String? localPath; // Changed from final
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

  // Synchronize remoteModels with downloaded state on app startup
  static void syncWithDownloadedModels(List<AIModel> downloaded) {
    for (var downloadedModel in downloaded) {
      final remoteIndex = remoteModels.indexWhere((m) => m.id == downloadedModel.id);
      if (remoteIndex >= 0) {
        // Update the remote model's state to reflect it's downloaded
        remoteModels[remoteIndex].isDownloaded = true;
        remoteModels[remoteIndex].localPath = downloadedModel.localPath;
      }
    }
  }

  // When marking as downloaded, update BOTH lists
  static void markAsDownloaded(AIModel remoteModel, String localPath) {
    // Check if already in downloadedModels
    final existingIndex = downloadedModels.indexWhere((m) => m.id == remoteModel.id);
    
    if (existingIndex >= 0) {
      // Update existing
      downloadedModels[existingIndex].localPath = localPath;
      downloadedModels[existingIndex].isDownloaded = true;
    } else {
      // Add new
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
    
    // ALSO update the corresponding remote model
    final remoteIndex = remoteModels.indexWhere((m) => m.id == remoteModel.id);
    if (remoteIndex >= 0) {
      remoteModels[remoteIndex].isDownloaded = true;
      remoteModels[remoteIndex].localPath = localPath;
    }
  }

  // CRITICAL: When marking as NOT downloaded (after delete), update BOTH lists
  static void markAsNotDownloaded(String modelId) {
    // Remove from downloadedModels
    downloadedModels.removeWhere((m) => m.id == modelId);
    
    // Update the remote model
    final remoteIndex = remoteModels.indexWhere((m) => m.id == modelId);
    if (remoteIndex >= 0) {
      remoteModels[remoteIndex].isDownloaded = false;
      remoteModels[remoteIndex].localPath = null;
    }
  }

  static bool listDownloaded(String id) {
    // First check downloadedModels
    if (downloadedModels.any((m) => m.id == id)) return true;
    
    // Also check if any remote model with this ID is marked as downloaded
    final remoteIndex = remoteModels.indexWhere((m) => m.id == id);
    if (remoteIndex >= 0) {
      return remoteModels[remoteIndex].isDownloaded;
    }
    
    return false;
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
  ];

  static List<AIModel> downloadedModels = [];
}