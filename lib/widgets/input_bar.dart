// lib/widgets/input_bar.dart
import 'package:flutter/material.dart';
import 'package:wazza/models/ai_model.dart';
import 'package:wazza/widgets/model_picker_sheet.dart';

class InputBar extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final AIModel selectedModel;
  final Function(AIModel) onModelSelected;

  const InputBar({
    super.key,
    required this.controller,
    required this.onSend,
    required this.selectedModel,
    required this.onModelSelected,
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
                _pickImage(context);
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.document_scanner),
              title: const Text('Document'),
              onTap: () {
                Navigator.pop(context);
                _pickFile(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Image picker will be implemented')),
    );
  }

  Future<void> _pickFile(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('File picker will be implemented')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
        color: Colors.white,
      ),
      child: Row(
        children: [
          // Model selector
          GestureDetector(
            onTap: () => showModalBottomSheet(
              context: context,
              builder: (context) => ModelPickerSheet(
                onSelect: widget.onModelSelected,
              ),
            ),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  widget.selectedModel.name.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          
          // Attachment button
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 20),
            onPressed: () => _showAttachmentOptions(context),
          ),
          
          // Text field
          Expanded(
            child: TextField(
              controller: widget.controller,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              decoration: const InputDecoration(
                hintText: 'Message Wazza...',
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
              ),
              onSubmitted: (_) => widget.onSend(),
            ),
          ),
          
          // Send button
          IconButton(
            onPressed: widget.controller.text.trim().isEmpty ? null : widget.onSend,
            icon: Icon(
              Icons.send,
              color: widget.controller.text.trim().isEmpty 
                  ? Colors.grey 
                  : Colors.black,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}