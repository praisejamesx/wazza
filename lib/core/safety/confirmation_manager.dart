import 'package:flutter/material.dart';
import 'package:wazza/core/safety/action_hierarchy.dart';
import 'package:wazza/core/safety/audit_log.dart';
import 'package:wazza/core/safety/policy_engine.dart';

class ConfirmationResult {
  final bool approved;
  final Set<int> approvedIndices;
  ConfirmationResult({required this.approved, this.approvedIndices = const {}});
}

class ConfirmationManager {
  final AuditLog _auditLog;
  
  ConfirmationManager({AuditLog? auditLog}) : _auditLog = auditLog ?? AuditLog();

  Future<ConfirmationResult> requestConfirmation({
    required BuildContext context,
    required String actionId,
    required String description,
    required List<ConfirmationCandidate> candidates,
    String? userQuery,
  }) async {
    final contract = ActionHierarchy.getContract(actionId);
    if (contract == null) {
      return ConfirmationResult(approved: false);
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ConfirmationDialog(
        actionName: contract.displayName,
        description: description,
        candidates: candidates,
        isDestructive: contract.category == ActionCategory.destructive,
        isReversible: contract.isReversible,
      ),
    );

    final approved = result?['approved'] == true;
    final indices = (result?['indices'] as Set<int>?) ?? {};

    // Record in audit log
    await _auditLog.record(AuditEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      userQuery: userQuery ?? '',
      actionType: actionId,
      policyResult: PolicyResult.requiresConfirmation,
      userDecision: approved ? 'approved' : 'rejected',
      actionResult: approved ? 'success' : null,
    ));

    return ConfirmationResult(approved: approved, approvedIndices: indices);
  }
}

class ConfirmationCandidate {
  final String name;
  final String? subtitle;
  final String? preview;
  final bool? isSelected;

  const ConfirmationCandidate({
    required this.name,
    this.subtitle,
    this.preview,
    this.isSelected,
  });
}

class _ConfirmationDialog extends StatefulWidget {
  final String actionName;
  final String description;
  final List<ConfirmationCandidate> candidates;
  final bool isDestructive;
  final bool isReversible;

  const _ConfirmationDialog({
    required this.actionName,
    required this.description,
    required this.candidates,
    required this.isDestructive,
    required this.isReversible,
  });

  @override
  State<_ConfirmationDialog> createState() => _ConfirmationDialogState();
}

class _ConfirmationDialogState extends State<_ConfirmationDialog> {
  late Set<int> _selectedIndices;

  @override
  void initState() {
    super.initState();
    _selectedIndices = Set.from(
      List.generate(widget.candidates.length, (i) => i),
    );
  }

  void _toggle(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.actionName),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.description),
            const SizedBox(height: 12),
            if (widget.isDestructive && widget.isReversible)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.orange),
                    SizedBox(width: 8),
                    Expanded(child: Text('This action is reversible (trash)', style: TextStyle(fontSize: 12, color: Colors.orange))),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.candidates.length,
                itemBuilder: (context, index) {
                  final candidate = widget.candidates[index];
                  final isSelected = _selectedIndices.contains(index);
                  return CheckboxListTile(
                    value: isSelected,
                    onChanged: (_) => _toggle(index),
                    title: Text(candidate.name, style: const TextStyle(fontSize: 14)),
                    subtitle: candidate.subtitle != null
                        ? Text(candidate.subtitle!, style: const TextStyle(fontSize: 12))
                        : null,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_selectedIndices.length} of ${widget.candidates.length} selected',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, {'approved': false}),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selectedIndices.isEmpty
              ? null
              : () => Navigator.pop(context, {
                  'approved': true,
                  'indices': _selectedIndices,
                }),
          style: widget.isDestructive
              ? ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white)
              : null,
          child: Text(widget.isDestructive ? 'Confirm' : 'Approve'),
        ),
      ],
    );
  }
}
