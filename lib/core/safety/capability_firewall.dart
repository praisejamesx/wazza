import 'package:wazza/core/safety/action_hierarchy.dart';
import 'package:wazza/core/safety/policy_engine.dart';

enum FirewallResult {
  allowed,
  requiresConfirmation,
  denied,
}

class CapabilityFirewall {
  final PolicyEngine _policyEngine;
  final Set<UserPermission> _enabledPermissions;

  CapabilityFirewall({
    PolicyEngine? policyEngine,
    Set<UserPermission>? enabledPermissions,
  })  : _policyEngine = policyEngine ?? PolicyEngine(),
        _enabledPermissions = enabledPermissions ?? _defaultPermissions;

  static final Set<UserPermission> _defaultPermissions = {
    UserPermission.searchPhotos,
    UserPermission.searchMusic,
    UserPermission.analyzeFiles,
    UserPermission.createPlaylists,
    UserPermission.draftMessages,
  };

  FirewallResult evaluate(String actionId, {Map<String, dynamic>? params}) {
    final contract = ActionHierarchy.getContract(actionId);
    if (contract == null) return FirewallResult.denied;

    // Forbidden actions always denied
    if (contract.category == ActionCategory.forbidden) {
      return FirewallResult.denied;
    }

    // Check if user has permission for this category
    if (!_hasPermissionForCategory(contract.category)) {
      return FirewallResult.denied;
    }

    // Check policy engine rules
    final policyResult = _policyEngine.evaluate(actionId, params: params);
    if (policyResult == PolicyResult.denied) {
      return FirewallResult.denied;
    }

    // Check item count limits
    if (params != null && params.containsKey('count')) {
      final count = params['count'] as int? ?? 0;
      if (count > contract.maxItemsPerOperation) {
        return FirewallResult.denied;
      }
    }

    // Requires confirmation for destructive or explicitly marked actions
    if (contract.requiresConfirmation || contract.category == ActionCategory.destructive) {
      return FirewallResult.requiresConfirmation;
    }

    return FirewallResult.allowed;
  }

  bool _hasPermissionForCategory(ActionCategory category) {
    switch (category) {
      case ActionCategory.read:
        return true; // Read is always allowed
      case ActionCategory.write:
        return _enabledPermissions.contains(UserPermission.createPlaylists) ||
            _enabledPermissions.contains(UserPermission.draftMessages) ||
            _enabledPermissions.contains(UserPermission.modifyFiles);
      case ActionCategory.destructive:
        return _enabledPermissions.contains(UserPermission.trashMedia);
      case ActionCategory.forbidden:
        return false;
    }
  }

  void updatePermission(UserPermission permission, bool enabled) {
    if (enabled) {
      _enabledPermissions.add(permission);
    } else {
      _enabledPermissions.remove(permission);
    }
  }

  Set<UserPermission> get enabledPermissions => Set.from(_enabledPermissions);

  bool get isPanicMode => _enabledPermissions.isEmpty;
  
  void enablePanicMode() {
    _enabledPermissions.clear();
  }

  void disablePanicMode() {
    _enabledPermissions.addAll(_defaultPermissions);
  }
}
