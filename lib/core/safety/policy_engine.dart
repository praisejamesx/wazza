enum PolicyResult {
  allowed,
  requiresConfirmation,
  denied,
}

class PolicyRule {
  final String name;
  final bool Function(String actionId, Map<String, dynamic>? params) evaluate;

  const PolicyRule({required this.name, required this.evaluate});
}

class PolicyEngine {
  final List<PolicyRule> _rules;

  PolicyEngine({List<PolicyRule>? rules}) : _rules = rules ?? _defaultRules();

  static List<PolicyRule> _defaultRules() {
    return [
      PolicyRule(
        name: 'max_items_check',
        evaluate: (actionId, params) {
          if (params == null) return true;
          final count = params['count'] as int? ?? 0;
          return count <= 100;
        },
      ),
      PolicyRule(
        name: 'no_protected_resources',
        evaluate: (actionId, params) {
          if (params == null) return true;
          final protected = params['protectedResource'] as bool? ?? false;
          return !protected;
        },
      ),
      PolicyRule(
        name: 'reversible_check',
        evaluate: (actionId, params) {
          if (actionId == 'delete.permanent') return false;
          return true;
        },
      ),
    ];
  }

  PolicyResult evaluate(String actionId, {Map<String, dynamic>? params}) {
    for (final rule in _rules) {
      if (!rule.evaluate(actionId, params)) {
        return PolicyResult.denied;
      }
    }
    return PolicyResult.allowed;
  }

  void addRule(PolicyRule rule) => _rules.add(rule);
}
