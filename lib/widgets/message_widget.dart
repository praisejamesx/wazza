// lib/widgets/message_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:wazza/models/message.dart';

class MessageWidget extends StatelessWidget {
  final Message message;
  const MessageWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    if (message.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 280),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 0.8),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SelectableText(
            message.text,
            style: const TextStyle(fontSize: 14, fontFamily: 'IBMPlexMono'),
          ),
        ),
      );
    } else {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 320),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: Colors.white,
          child: MarkdownBody(
            data: message.text,
            selectable: true,
            styleSheet: MarkdownStyleSheet(
              p: const TextStyle(fontSize: 14, fontFamily: 'IBMPlexMono'),
              code: const TextStyle(
                fontFamily: 'IBMPlexMono',
                backgroundColor: Color(0xfff0f0f0),
              ),
            ),
          ),
        ),
      );
    }
  }
}