import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wazza/core/providers.dart';
import 'package:wazza/core/safety/capability_firewall.dart';
import 'package:wazza/core/safety/audit_log.dart';
import 'package:wazza/core/safety/policy_engine.dart';
import 'package:wazza/features/models/presentation/controllers/models_controller.dart';
import 'package:wazza/features/models/domain/ai_model.dart';
import 'package:wazza/features/models/data/model_catalog.dart';

class ModelsScreen extends ConsumerWidget {
  const ModelsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadedAsync = ref.watch(downloadedModelsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Models'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => ref.read(downloadedModelsProvider.notifier).refresh()),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(downloadedModelsProvider.notifier).refresh(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Downloaded models
            downloadedAsync.when(
              data: (downloaded) {
                if (downloaded.isNotEmpty) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Downloaded (${downloaded.length})', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[500])),
                      const SizedBox(height: 8),
                      ...downloaded.map((m) => _DownloadedCard(model: m)),
                      const SizedBox(height: 24),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            // Available models by category
            ...ModelSize.values.map((size) {
              final models = ModelCatalog.models.where((m) => m.sizeCategory == size).toList();
              if (models.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_sizeLabel(size), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[500])),
                  const SizedBox(height: 8),
                  ...models.map((m) => _AvailableCard(model: m)),
                  const SizedBox(height: 24),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  String _sizeLabel(ModelSize size) {
    switch (size) {
      case ModelSize.tiny: return 'Ultra-Light (under 500MB)';
      case ModelSize.small: return 'Light (500MB - 1.5GB)';
      case ModelSize.medium: return 'Medium (1.5GB - 3GB)';
      case ModelSize.large: return 'Heavy (3GB+)';
    }
  }
}

class _DownloadedCard extends ConsumerWidget {
  final AIModel model;
  const _DownloadedCard({required this.model});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.check_circle, color: Colors.green),
        title: Text(model.name, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text('${model.sizeMB}MB  ${model.quant}'),
        trailing: IconButton(
          icon: Icon(Icons.delete_outline, color: Colors.grey[500], size: 20),
          onPressed: () => _confirmDelete(context, ref),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final firewall = ref.read(capabilityFirewallProvider);
    final result = firewall.evaluate('delete.model', params: {'modelId': model.id});

    if (result == FirewallResult.denied) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Model deletion is not permitted')),
        );
      }
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Model'),
        content: Text('Permanently delete ${model.name} (${model.sizeMB}MB)?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    final auditLog = ref.read(auditLogProvider);
    if (confirmed != true) {
      await auditLog.record(AuditEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        userQuery: 'User-initiated model deletion',
        actionType: 'delete.model',
        actionParams: {'modelId': model.id, 'modelName': model.name},
        policyResult: PolicyResult.requiresConfirmation,
        userDecision: 'rejected',
      ));
      return;
    }

    await ref.read(downloadedModelsProvider.notifier).deleteModel(model);
    await auditLog.record(AuditEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      userQuery: 'User-initiated model deletion',
      actionType: 'delete.model',
      actionParams: {'modelId': model.id, 'modelName': model.name},
      policyResult: PolicyResult.requiresConfirmation,
      userDecision: 'approved',
      actionResult: 'success',
    ));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${model.name} deleted')),
      );
    }
  }
}

class _AvailableCard extends ConsumerWidget {
  final AIModel model;
  const _AvailableCard({required this.model});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadedAsync = ref.watch(downloadedModelsProvider);
    final isDownloaded = downloadedAsync.valueOrNull?.any((m) => m.id == model.id) ?? false;
    final progress = ref.watch(downloadProgressProvider(model.id));

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(model.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                      const SizedBox(height: 2),
                      Text('${model.sizeMB}MB  ${model.quant}  ${(model.contextWindow / 1024).round()}K ctx', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(model.description, style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 12),
            if (progress != null)
              Column(
                children: [
                  LinearProgressIndicator(value: progress.percent / 100),
                  const SizedBox(height: 4),
                  Text('${progress.percent}%  ${(progress.downloadedBytes / (1024*1024)).toStringAsFixed(1)}MB', style: const TextStyle(fontSize: 12)),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isDownloaded ? null : () async {
                    try {
                      await ref.read(modelActionsProvider).downloadModel(model);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${model.name} downloaded!'), backgroundColor: Colors.green),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed: $e')),
                        );
                      }
                    }
                  },
                  child: Text(isDownloaded ? 'Downloaded' : 'Download'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
