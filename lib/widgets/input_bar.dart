// lib/widgets/input_bar.dart
import 'package:flutter/material.dart';
import 'package:wazza/models/ai_model.dart';
import 'package:wazza/widgets/model_picker_sheet.dart';

class InputBar extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final AIModel selectedModel;
  final Function(AIModel) onModelSelected;
  final bool isGenerating;

  const InputBar({
    super.key,
    required this.controller,
    required this.onSend,
    required this.selectedModel,
    required this.onModelSelected,
    required this.isGenerating,
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Image picker will be implemented')),
                );
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.document_scanner),
              title: const Text('Document'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('File picker will be implemented')),
                );
              },
            ),
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
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasText = widget.controller.text.trim().isNotEmpty;
    final canSend = hasText || widget.isGenerating;
    
    return Material(
      child: Container(
        padding: EdgeInsets.only(
          left: 12,
          right: 12,
          top: 8,
          bottom: MediaQuery.of(context).viewInsets.bottom + 8,
        ),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey.shade300)),
          color: Colors.white,
        ),
        child: Row(
          children: [
            // Model selector
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
              child: MouseRegion(
                cursor: widget.isGenerating 
                    ? SystemMouseCursors.forbidden 
                    : SystemMouseCursors.click,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: widget.isGenerating ? Colors.grey : Colors.black,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                    child: Text(
                      widget.selectedModel.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            
            // Attachment button (disabled during generation)
            IconButton(
              icon: Icon(
                Icons.add_circle_outline, 
                size: 22,
                color: widget.isGenerating ? Colors.grey : Colors.black54,
              ),
              onPressed: widget.isGenerating 
                  ? null 
                  : () => _showAttachmentOptions(context),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 44,
                minHeight: 44,
              ),
            ),
            
            // Text field
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: TextField(
                  controller: widget.controller,
                  enabled: !widget.isGenerating,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  decoration: const InputDecoration(
                    hintText: 'Message Wazza...',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  onSubmitted: (_) {
                    if (hasText && !widget.isGenerating) {
                      widget.onSend();
                    }
                  },
                ),
              ),
            ),
            
            // Send/Stop button
            Container(
              margin: const EdgeInsets.only(left: 4),
              child: ElevatedButton(
                onPressed: canSend ? widget.onSend : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.isGenerating ? Colors.black : Colors.black,
                  foregroundColor: Colors.white,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(12),
                  minimumSize: const Size(48, 48),
                ),
                child: widget.isGenerating
                    ? const Icon(Icons.stop, size: 20)
                    : const Icon(Icons.send, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}