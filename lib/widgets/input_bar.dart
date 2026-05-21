import 'package:flutter/material.dart';
import 'package:wazza/models/ai_model.dart';
import 'package:wazza/widgets/model_picker_sheet.dart';

class InputBar extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final AIModel selectedModel;
  final Function(AIModel) onModelSelected;
  final bool isGenerating;
  final bool isListening;
  final VoidCallback onToggleListening;
  final bool useSearch;
  final VoidCallback onToggleSearch;
  final VoidCallback onPickImage;

  const InputBar({
    super.key,
    required this.controller,
    required this.onSend,
    required this.selectedModel,
    required this.onModelSelected,
    required this.isGenerating,
    required this.isListening,
    required this.onToggleListening,
    required this.useSearch,
    required this.onToggleSearch,
    required this.onPickImage,
  });

  @override
  State<InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<InputBar> {
  void _showAttachmentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Photo from Gallery'),
              onTap: () {
                Navigator.pop(context);
                widget.onPickImage();
              },
            ),
            const Divider(height: 1),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final hasText = widget.controller.text.trim().isNotEmpty;
    final canSend = hasText || widget.isGenerating;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        left: 8,
        right: 8,
        top: 6,
        bottom: MediaQuery.of(context).viewInsets.bottom + 6,
      ),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey.shade300)),
        color: isDark ? Colors.grey[900] : Colors.white,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: widget.isGenerating
                ? null
                : () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => ModelPickerSheet(
                    onSelect: widget.onModelSelected,
                  ),
                ),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: widget.isGenerating ? Colors.grey : Colors.black,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  widget.selectedModel.name.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: Icon(
              Icons.add_circle_outline,
              size: 20,
              color: widget.isGenerating
                  ? (isDark ? Colors.grey[700] : Colors.grey)
                  : (isDark ? Colors.grey[400] : Colors.black54),
            ),
            onPressed: widget.isGenerating ? null : () => _showAttachmentOptions(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
          IconButton(
            icon: Icon(
              widget.useSearch ? Icons.language : Icons.language_outlined,
              size: 20,
              color: widget.useSearch
                  ? Colors.blue
                  : (widget.isGenerating
                      ? (isDark ? Colors.grey[700] : Colors.grey)
                      : (isDark ? Colors.grey[400] : Colors.black54)),
            ),
            onPressed: widget.isGenerating ? null : widget.onToggleSearch,
            tooltip: widget.useSearch ? 'Web search on' : 'Web search off',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: TextField(
                controller: widget.controller,
                enabled: !widget.isGenerating,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: widget.isListening ? 'Listening...' : 'Message Wazza...',
                  hintStyle: TextStyle(
                    color: widget.isListening ? Colors.blue : (isDark ? Colors.grey[600] : null),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
                onSubmitted: (_) {
                  if (hasText && !widget.isGenerating) {
                    widget.onSend();
                  }
                },
              ),
            ),
          ),
          if (widget.isListening)
            Container(
              margin: const EdgeInsets.only(left: 4),
              child: ElevatedButton(
                onPressed: widget.onToggleListening,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(10),
                  minimumSize: const Size(42, 42),
                ),
                child: const Icon(Icons.stop, size: 18),
              ),
            )
          else ...[
            IconButton(
              icon: Icon(
                Icons.mic,
                size: 20,
                color: widget.isGenerating
                    ? (isDark ? Colors.grey[700] : Colors.grey)
                    : (isDark ? Colors.grey[400] : Colors.black54),
              ),
              onPressed: widget.isGenerating ? null : widget.onToggleListening,
              tooltip: 'Voice input',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
            Container(
              margin: const EdgeInsets.only(left: 2),
              child: ElevatedButton(
                onPressed: canSend ? widget.onSend : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.isGenerating ? Colors.red : Colors.black,
                  foregroundColor: Colors.white,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(10),
                  minimumSize: const Size(42, 42),
                ),
                child: widget.isGenerating
                    ? const Icon(Icons.stop, size: 18)
                    : const Icon(Icons.send, size: 18),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
