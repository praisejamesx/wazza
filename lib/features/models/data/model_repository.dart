import 'dart:io';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:wazza/core/database/app_database.dart';
import 'package:wazza/core/utils/file_utils.dart';
import 'package:wazza/features/models/domain/ai_model.dart';
import 'package:wazza/features/models/data/model_catalog.dart';
import 'dart:developer' as dev;

class ModelRepository {
  final AppDatabase _db;
  ModelRepository(this._db);

  Future<void> saveDownloadedModel(AIModel model) async {
    await _db.into(_db.downloadedModels).insertOnConflictUpdate(DownloadedModelsCompanion.insert(
      id: model.id,
      name: model.name,
      sizeMb: model.sizeMB,
      quant: model.quant,
      localPath: model.localPath ?? '',
      templateType: model.templateType.name,
      discoveredAt: DateTime.now().millisecondsSinceEpoch,
      description: Value(model.description),
      bestFor: Value(model.bestFor),
    ));
  }

  Future<List<AIModel>> getDownloadedModels() async {
    final rows = await _db.select(_db.downloadedModels).get();
    return rows.map((row) {
      final templateType = TemplateType.values.firstWhere(
        (t) => t.name == row.templateType,
        orElse: () => TemplateType.chatml,
      );
      return AIModel(
        id: row.id,
        name: row.name,
        sizeMB: row.sizeMb,
        quant: row.quant,
        isDownloaded: true,
        localPath: row.localPath,
        templateType: templateType,
        description: row.description ?? '',
        bestFor: row.bestFor ?? '',
      );
    }).toList();
  }

  Future<void> deleteModel(String modelId) async {
    final rows = await (_db.select(_db.downloadedModels)..where((t) => t.id.equals(modelId))).get();
    if (rows.isNotEmpty) {
      final localPath = rows.first.localPath;
      final modelsDir = await FileUtils.getModelsDirectory();
      final normalizedPath = File(localPath).resolveSymbolicLinksSync();
      final normalizedModelsDir = modelsDir.resolveSymbolicLinksSync();
      if (normalizedPath.startsWith(normalizedModelsDir)) {
        final file = File(localPath);
        if (await file.exists()) await file.delete();
      }
      await (_db.delete(_db.downloadedModels)..where((t) => t.id.equals(modelId))).go();
    }
  }

  Future<void> reconcileModels() async {
    dev.log('[ModelRepository] Starting reconciliation...');
    
    final modelsDir = await FileUtils.getModelsDirectory();
    final modelFiles = await FileUtils.scanForModelFiles(modelsDir);

    // Also scan shared_models directory (from Kotlin share handler)
    final appDir = await getApplicationDocumentsDirectory();
    final sharedModelsDir = Directory(p.join(appDir.path, 'shared_models'));
    if (await sharedModelsDir.exists()) {
      modelFiles.addAll(await FileUtils.scanForModelFiles(sharedModelsDir));
    }

    final existingModels = await getDownloadedModels();
    final existingPaths = existingModels.map((m) => m.localPath).whereType<String>().toSet();

    // Add new files not in DB
    for (final file in modelFiles) {
      if (!existingPaths.contains(file.path)) {
        final stat = await file.stat();
        final sizeMB = stat.size ~/ (1024 * 1024);
        final fileName = FileUtils.getFileNameWithoutExtension(file.path);
        final lowerName = fileName.toLowerCase();
        
        // Try to match against catalog
        final catalogMatch = ModelCatalog.models.cast<AIModel?>().firstWhere(
          (m) => m != null && lowerName.contains(m.id.toLowerCase()),
          orElse: () => null,
        );

        if (catalogMatch != null) {
          final model = catalogMatch.copyWith(
            isDownloaded: true,
            localPath: file.path,
            sizeMB: sizeMB,
          );
          await saveDownloadedModel(model);
          dev.log('[ModelRepository] Matched catalog model: ${catalogMatch.name}');
        } else {
          // Create custom model entry
          final templateType = _inferTemplate(lowerName);
          final model = AIModel(
            id: 'custom_${lowerName.replaceAll(RegExp(r'[^a-z0-9]'), '_')}',
            name: _formatName(fileName),
            sizeMB: sizeMB,
            quant: _inferQuant(lowerName),
            isDownloaded: true,
            localPath: file.path,
            templateType: templateType,
            description: 'Custom model',
            bestFor: 'General chat',
          );
          await saveDownloadedModel(model);
          dev.log('[ModelRepository] Added custom model: ${model.name}');
        }
      }
    }

    // Remove DB records for missing files
    for (final model in existingModels) {
      if (model.localPath != null && !await FileUtils.fileExists(model.localPath!)) {
        await (_db.delete(_db.downloadedModels)..where((t) => t.id.equals(model.id))).go();
        dev.log('[ModelRepository] Removed stale record: ${model.name}');
      }
    }

    dev.log('[ModelRepository] Reconciliation complete');
  }

  TemplateType _inferTemplate(String name) {
    if (name.contains('qwen')) return TemplateType.qwen;
    if (name.contains('gemma')) return TemplateType.gemma;
    if (name.contains('phi')) return TemplateType.phi;
    if (name.contains('llama3')) return TemplateType.llama3;
    if (name.contains('llama')) return TemplateType.llama2;
    if (name.contains('smol')) return TemplateType.chatml;
    return TemplateType.chatml;
  }

  String _inferQuant(String name) {
    if (name.contains('q2')) return 'Q2_K';
    if (name.contains('q3')) return 'Q3_K_M';
    if (name.contains('q4')) return 'Q4_K_M';
    if (name.contains('q5')) return 'Q5_K_M';
    if (name.contains('q6')) return 'Q6_K';
    if (name.contains('q8')) return 'Q8_0';
    return 'Q4_K_M';
  }

  String _formatName(String fileName) {
    return fileName.replaceAll(RegExp(r'[_-]'), ' ').split(' ').map((w) =>
      w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' ');
  }
}
