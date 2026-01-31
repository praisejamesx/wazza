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
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.shade300))),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => showModalBottomSheet(
              context: context,
              builder: (context) => ModelPickerSheet(onSelect: widget.onModelSelected),
            ),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.black,
              child: Text(widget.selectedModel.name.substring(0, 1).toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ),
          const SizedBox(width: 8),
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
              ),
              onSubmitted: (_) => widget.onSend(),
            ),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.image_outlined, size: 20)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.attach_file_outlined, size: 20)),
          IconButton(
            onPressed: widget.controller.text.trim().isEmpty ? null : widget.onSend,
            icon: const Icon(Icons.send_outlined, size: 20),
          ),
        ],
      ),
    );
  }
}