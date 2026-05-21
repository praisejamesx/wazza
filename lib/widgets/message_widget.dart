import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:wazza/models/message.dart';
import 'package:flutter_tts/flutter_tts.dart';

class MessageWidget extends StatefulWidget {
  final Message message;
  final VoidCallback? onTap;

  const MessageWidget({super.key, required this.message, this.onTap});

  @override
  State<MessageWidget> createState() => _MessageWidgetState();
}

class _MessageWidgetState extends State<MessageWidget> {
  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _toggleTTS() async {
    if (_isSpeaking) {
      await _tts.stop();
      setState(() => _isSpeaking = false);
    } else {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.5);
      await _tts.setPitch(1.0);
      _tts.setCompletionHandler(() {
        if (mounted) setState(() => _isSpeaking = false);
      });
      await _tts.speak(widget.message.text);
      setState(() => _isSpeaking = true);
    }
  }

  Future<void> _copyText() async {
    await Clipboard.setData(ClipboardData(text: widget.message.text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Copied'), duration: Duration(seconds: 1)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.message.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 280),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: isDark ? Colors.grey[600]! : Colors.black, width: 0.8),
            borderRadius: BorderRadius.circular(8),
            color: isDark ? Colors.grey[850] : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SelectableText(
                widget.message.text,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'monospace',
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _IconButton(
                    icon: Icons.copy,
                    size: 14,
                    onPressed: _copyText,
                    color: isDark ? Colors.grey[500]! : Colors.grey,
                  ),
                ],
              ),
            ],
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
          color: isDark ? Colors.grey[900] : Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MarkdownBody(
                data: widget.message.text,
                selectable: true,
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(
                    fontSize: 14,
                    fontFamily: 'monospace',
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  code: TextStyle(
                    fontFamily: 'monospace',
                    backgroundColor: isDark ? Colors.grey[800] : const Color(0xfff0f0f0),
                    color: isDark ? Colors.green[300] : null,
                  ),
                  codeblockDecoration: BoxDecoration(
                    color: isDark ? Colors.grey[850] : const Color(0xfff5f5f5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  blockquoteDecoration: BoxDecoration(
                    border: Border(left: BorderSide(color: Colors.grey[400]!, width: 3)),
                    color: isDark ? Colors.grey[850] : Colors.grey[50],
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _IconButton(
                    icon: Icons.copy,
                    size: 14,
                    onPressed: _copyText,
                    color: isDark ? Colors.grey[500]! : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  _IconButton(
                    icon: _isSpeaking ? Icons.stop : Icons.volume_up,
                    size: 14,
                    onPressed: _toggleTTS,
                    color: _isSpeaking
                        ? Colors.blue
                        : (isDark ? Colors.grey[500]! : Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final VoidCallback onPressed;
  final Color color;

  const _IconButton({
    required this.icon,
    required this.size,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Icon(icon, size: size, color: color),
    );
  }
}
