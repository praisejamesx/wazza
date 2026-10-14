import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wazza/core/providers.dart';
import 'package:wazza/features/models/data/model_repository.dart';
import 'package:wazza/features/models/data/model_downloader.dart';
import 'package:wazza/features/models/data/model_catalog.dart';
import 'package:wazza/features/models/domain/ai_model.dart';

final modelRepositoryProvider = Provider<ModelRepository>((ref) {
  return ModelRepository(ref.watch(databaseProvider));
});

final modelDownloaderProvider = Provider<ModelDownloader>((ref) {
  return ModelDownloader();
});

final downloadedModelsProvider = StreamNotifierProvider<DownloadedModelsController, List<AIModel>>(DownloadedModelsController.new);

class DownloadedModelsController extends StreamNotifier<List<AIModel>> {
  @override
  Stream<List<AIModel>> build() async* {
    // Always reconcile on first build
    await ref.read(modelRepositoryProvider).reconcileModels();
    final models = await ref.read(modelRepositoryProvider).getDownloadedModels();
    yield models;
  }

  Future<void> refresh() async {
    await ref.read(modelRepositoryProvider).reconcileModels();
    final models = await ref.read(modelRepositoryProvider).getDownloadedModels();
    state = AsyncData(models);
  }

  Future<void> deleteModel(AIModel model) async {
    await ref.read(modelRepositoryProvider).deleteModel(model.id);
    await refresh();
  }
}

// Remote catalog state
final remoteCatalogProvider = Provider<List<AIModel>>((ref) {
  return ModelCatalog.models;
});

// Download progress for a specific model
final downloadProgressProvider = StateProvider.family<DownloadProgress?, String>((ref, modelId) {
  return null;
});

// Active download cancellation tokens
final activeDownloadsProvider = Provider<Map<String, CancellationToken>>((ref) {
  return {};
});

class ModelActions {
  final Ref ref;
  ModelActions(this.ref);

  Future<void> downloadModel(AIModel model, {void Function(DownloadProgress)? onProgress}) async {
    final downloader = ref.read(modelDownloaderProvider);
    final cancelToken = CancellationToken();
    ref.read(activeDownloadsProvider)[model.id] = cancelToken;

    try {
      final filePath = await downloader.downloadModel(
        model: model,
        onProgress: (progress) {
          ref.read(downloadProgressProvider(model.id).notifier).state = progress;
          onProgress?.call(progress);
        },
        cancelToken: cancelToken,
      );

      final downloadedModel = model.copyWith(isDownloaded: true, localPath: filePath);
      await ref.read(modelRepositoryProvider).saveDownloadedModel(downloadedModel);
      ref.read(downloadProgressProvider(model.id).notifier).state = null;
      ref.read(activeDownloadsProvider).remove(model.id);
      await ref.read(downloadedModelsProvider.notifier).refresh();
    } catch (e) {
      ref.read(downloadProgressProvider(model.id).notifier).state = null;
      ref.read(activeDownloadsProvider).remove(model.id);
      rethrow;
    }
  }

  void cancelDownload(String modelId) {
    ref.read(activeDownloadsProvider)[modelId]?.cancel();
    ref.read(downloadProgressProvider(modelId).notifier).state = null;
    ref.read(activeDownloadsProvider).remove(modelId);
  }
}

final modelActionsProvider = Provider<ModelActions>((ref) {
  return ModelActions(ref);
});
