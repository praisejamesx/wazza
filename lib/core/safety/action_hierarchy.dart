enum ActionCategory {
  read,
  write,
  destructive,
  forbidden,
}

enum UserPermission {
  searchPhotos,
  searchMusic,
  analyzeFiles,
  createPlaylists,
  draftMessages,
  modifyFiles,
  trashMedia,
  sendMessages,
  externalCommunication,
  makePurchases,
  installSoftware,
}

class ActionContract {
  final String actionId;
  final String displayName;
  final ActionCategory category;
  final int maxItemsPerOperation;
  final bool requiresConfirmation;
  final bool isReversible;
  final List<String> protectedResources;

  const ActionContract({
    required this.actionId,
    required this.displayName,
    required this.category,
    this.maxItemsPerOperation = 50,
    this.requiresConfirmation = false,
    this.isReversible = true,
    this.protectedResources = const [],
  });
}

class ActionHierarchy {
  static const Map<String, ActionContract> contracts = {
    'search.photos': ActionContract(
      actionId: 'search.photos',
      displayName: 'Search Photos',
      category: ActionCategory.read,
    ),
    'search.music': ActionContract(
      actionId: 'search.music',
      displayName: 'Search Music',
      category: ActionCategory.read,
    ),
    'search.files': ActionContract(
      actionId: 'search.files',
      displayName: 'Search Files',
      category: ActionCategory.read,
    ),
    'preview.photo': ActionContract(
      actionId: 'preview.photo',
      displayName: 'Preview Photo',
      category: ActionCategory.read,
    ),
    'play.music': ActionContract(
      actionId: 'play.music',
      displayName: 'Play Music',
      category: ActionCategory.read,
    ),
    'create.playlist': ActionContract(
      actionId: 'create.playlist',
      displayName: 'Create Playlist',
      category: ActionCategory.write,
      requiresConfirmation: true,
    ),
    'draft.message': ActionContract(
      actionId: 'draft.message',
      displayName: 'Draft Message',
      category: ActionCategory.write,
      requiresConfirmation: true,
    ),
    'modify.file': ActionContract(
      actionId: 'modify.file',
      displayName: 'Modify File',
      category: ActionCategory.write,
      requiresConfirmation: true,
    ),
    'open.url': ActionContract(
      actionId: 'open.url',
      displayName: 'Open URL',
      category: ActionCategory.read,
    ),
    'send.notification': ActionContract(
      actionId: 'send.notification',
      displayName: 'Send Notification',
      category: ActionCategory.read,
    ),
    'trash.photos': ActionContract(
      actionId: 'trash.photos',
      displayName: 'Trash Photos',
      category: ActionCategory.destructive,
      maxItemsPerOperation: 50,
      requiresConfirmation: true,
      isReversible: true,
    ),
    'delete.photos': ActionContract(
      actionId: 'delete.photos',
      displayName: 'Delete Photos',
      category: ActionCategory.destructive,
      maxItemsPerOperation: 50,
      requiresConfirmation: true,
      isReversible: false,
      protectedResources: ['local_path'],
    ),
    'download.model': ActionContract(
      actionId: 'download.model',
      displayName: 'Download Model',
      category: ActionCategory.write,
      requiresConfirmation: false,
    ),
    'download.file': ActionContract(
      actionId: 'download.file',
      displayName: 'Download File',
      category: ActionCategory.write,
      requiresConfirmation: true,
    ),
    'delete.model': ActionContract(
      actionId: 'delete.model',
      displayName: 'Delete Model',
      category: ActionCategory.destructive,
      maxItemsPerOperation: 1,
      requiresConfirmation: true,
      isReversible: false,
      protectedResources: ['local_path'],
    ),
    'delete.permanent': ActionContract(
      actionId: 'delete.permanent',
      displayName: 'Permanent Delete',
      category: ActionCategory.forbidden,
    ),
    'send.message': ActionContract(
      actionId: 'send.message',
      displayName: 'Send Message',
      category: ActionCategory.forbidden,
    ),
    'make.purchase': ActionContract(
      actionId: 'make.purchase',
      displayName: 'Make Purchase',
      category: ActionCategory.forbidden,
    ),
    'install.software': ActionContract(
      actionId: 'install.software',
      displayName: 'Install Software',
      category: ActionCategory.forbidden,
    ),
    'external.communicate': ActionContract(
      actionId: 'external.communicate',
      displayName: 'External Communication',
      category: ActionCategory.forbidden,
    ),
  };

  static ActionContract? getContract(String actionId) => contracts[actionId];

  static List<ActionContract> getActionsByCategory(ActionCategory category) {
    return contracts.values.where((c) => c.category == category).toList();
  }
}
