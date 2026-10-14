import 'package:wazza/features/models/domain/ai_model.dart';

class ModelCatalog {
  static const List<AIModel> models = [
    // Ultra-Light
    AIModel(
      id: 'smollm2_135m',
      name: 'SmolLM2 135M',
      sizeMB: 80,
      quant: 'Q4_K_M',
      templateType: TemplateType.chatml,
      description: 'Tiny but fast. Great for quick tasks and testing.',
      bestFor: 'Quick tasks, testing',
      hfUrl: 'https://huggingface.co/QuantFactory/SmolLM2-135M-GGUF/resolve/main/smollm2-135m-q4_k_m.gguf',
      contextWindow: 8192,
      sizeCategory: ModelSize.tiny,
      recommendedFor: ['quick', 'testing'],
    ),
    AIModel(
      id: 'smollm2_360m',
      name: 'SmolLM2 360M',
      sizeMB: 220,
      quant: 'Q4_K_M',
      templateType: TemplateType.chatml,
      description: 'Surprisingly capable for its size. Good for constrained devices.',
      bestFor: 'Light chat, simple tasks',
      hfUrl: 'https://huggingface.co/QuantFactory/SmolLM2-360M-GGUF/resolve/main/smollm2-360m-q4_k_m.gguf',
      contextWindow: 8192,
      sizeCategory: ModelSize.tiny,
      recommendedFor: ['light', 'efficient'],
    ),
    AIModel(
      id: 'qwen2.5_0.5b',
      name: 'Qwen2.5 0.5B',
      sizeMB: 350,
      quant: 'Q4_K_M',
      templateType: TemplateType.qwen,
      description: 'Multilingual powerhouse in a tiny package. 32K context.',
      bestFor: 'Multilingual, general chat',
      hfUrl: 'https://huggingface.co/Qwen/Qwen2.5-0.5B-Instruct-GGUF/resolve/main/qwen2.5-0.5b-instruct-q4_k_m.gguf',
      contextWindow: 32768,
      sizeCategory: ModelSize.tiny,
      recommendedFor: ['multilingual', 'general'],
    ),

    // Light
    AIModel(
      id: 'smollm2_1.7b',
      name: 'SmolLM2 1.7B',
      sizeMB: 1000,
      quant: 'Q4_K_M',
      templateType: TemplateType.chatml,
      description: 'Strong performance for everyday tasks. 11T tokens trained.',
      bestFor: 'General chat, writing',
      hfUrl: 'https://huggingface.co/bartowski/SmolLM2-1.7B-Instruct-GGUF/resolve/main/smollm2-1.7b-instruct-q4_k_m.gguf',
      contextWindow: 8192,
      sizeCategory: ModelSize.small,
      recommendedFor: ['general', 'writing'],
    ),
    AIModel(
      id: 'qwen2.5_1.5b',
      name: 'Qwen2.5 1.5B',
      sizeMB: 1000,
      quant: 'Q4_K_M',
      templateType: TemplateType.qwen,
      description: 'Excellent multilingual model with 32K context window.',
      bestFor: 'Multilingual, coding, analysis',
      hfUrl: 'https://huggingface.co/Qwen/Qwen2.5-1.5B-Instruct-GGUF/resolve/main/qwen2.5-1.5b-instruct-q4_k_m.gguf',
      contextWindow: 32768,
      sizeCategory: ModelSize.small,
      recommendedFor: ['multilingual', 'coding'],
    ),
    AIModel(
      id: 'gemma2_2b',
      name: 'Gemma 2 2B',
      sizeMB: 1500,
      quant: 'Q4_K_M',
      templateType: TemplateType.gemma,
      description: 'Google quality in a compact size. Well-rounded.',
      bestFor: 'General chat, creative writing',
      hfUrl: 'https://huggingface.co/bartowski/gemma-2-2b-it-GGUF/resolve/main/gemma-2-2b-it-Q4_K_M.gguf',
      contextWindow: 8192,
      sizeCategory: ModelSize.small,
      recommendedFor: ['general', 'creative'],
    ),

    // Medium
    AIModel(
      id: 'phi3.5_mini',
      name: 'Phi-3.5 Mini',
      sizeMB: 2200,
      quant: 'Q4_K_M',
      templateType: TemplateType.phi,
      description: 'Microsoft reasoning expert. 128K context. Exceptional logic.',
      bestFor: 'Reasoning, math, coding',
      hfUrl: 'https://huggingface.co/bartowski/Phi-3.5-mini-instruct-GGUF/resolve/main/Phi-3.5-mini-instruct-Q4_K_M.gguf',
      contextWindow: 131072,
      sizeCategory: ModelSize.medium,
      recommendedFor: ['reasoning', 'coding', 'math'],
    ),
    AIModel(
      id: 'qwen2.5_3b',
      name: 'Qwen2.5 3B',
      sizeMB: 1800,
      quant: 'Q4_K_M',
      templateType: TemplateType.qwen,
      description: 'Best-in-class at 3B parameters. 32K context, multilingual.',
      bestFor: 'Multilingual, coding, analysis',
      hfUrl: 'https://huggingface.co/Qwen/Qwen2.5-3B-Instruct-GGUF/resolve/main/qwen2.5-3b-instruct-q4_k_m.gguf',
      contextWindow: 32768,
      sizeCategory: ModelSize.medium,
      recommendedFor: ['multilingual', 'coding', 'analysis'],
    ),
    AIModel(
      id: 'llama3.2_3b',
      name: 'Llama 3.2 3B',
      sizeMB: 1800,
      quant: 'Q4_K_M',
      templateType: TemplateType.llama3,
      description: 'Meta latest. 128K context, excellent instruction following.',
      bestFor: 'General, instruction following',
      hfUrl: 'https://huggingface.co/bartowski/Llama-3.2-3B-Instruct-GGUF/resolve/main/Llama-3.2-3B-Instruct-Q4_K_M.gguf',
      contextWindow: 131072,
      sizeCategory: ModelSize.medium,
      recommendedFor: ['general', 'instructions'],
    ),
    AIModel(
      id: 'smollm3_3b',
      name: 'SmolLM3 3B',
      sizeMB: 1800,
      quant: 'Q4_K_M',
      templateType: TemplateType.chatml,
      description: 'HuggingFace latest. 128K context, built for efficiency.',
      bestFor: 'Efficient tasks, long context',
      hfUrl: 'https://huggingface.co/HuggingFaceTB/SmolLM3-3B-GGUF/resolve/main/SmolLM3-3B-Q4_K_M.gguf',
      contextWindow: 131072,
      sizeCategory: ModelSize.medium,
      recommendedFor: ['efficient', 'long-context'],
    ),

    // Heavy
    AIModel(
      id: 'phi4_mini',
      name: 'Phi-4 Mini',
      sizeMB: 2400,
      quant: 'Q4_K_M',
      templateType: TemplateType.phi,
      description: 'Microsoft latest reasoning model. 128K context.',
      bestFor: 'Advanced reasoning, math, science',
      hfUrl: 'https://huggingface.co/bartowski/Phi-4-mini-instruct-GGUF/resolve/main/Phi-4-mini-instruct-Q4_K_M.gguf',
      contextWindow: 131072,
      sizeCategory: ModelSize.large,
      recommendedFor: ['reasoning', 'math', 'science'],
    ),
    AIModel(
      id: 'qwen2.5_7b',
      name: 'Qwen2.5 7B',
      sizeMB: 4500,
      quant: 'Q4_K_M',
      templateType: TemplateType.qwen,
      description: 'The full Qwen experience. 128K context, top tier.',
      bestFor: 'Complex tasks, coding, analysis',
      hfUrl: 'https://huggingface.co/Qwen/Qwen2.5-7B-Instruct-GGUF/resolve/main/qwen2.5-7b-instruct-q4_k_m.gguf',
      contextWindow: 131072,
      sizeCategory: ModelSize.large,
      recommendedFor: ['complex', 'coding', 'analysis'],
    ),
  ];

  static AIModel? getById(String id) {
    try {
      return models.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<AIModel> getBySizeCategory(ModelSize size) {
    return models.where((m) => m.sizeCategory == size).toList();
  }

  static List<AIModel> search(String query) {
    final lower = query.toLowerCase();
    return models.where((m) =>
      m.name.toLowerCase().contains(lower) ||
      m.description.toLowerCase().contains(lower) ||
      m.bestFor.toLowerCase().contains(lower)
    ).toList();
  }
}
