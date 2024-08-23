import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class MessageBubble extends StatefulWidget {
  MessageBubble({
    required this.content,
    required this.isUserMessage,
    Key? key,
  }) : super(key: key);

  final String content;
  final bool isUserMessage;

  @override
  _MessageBubbleState createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  String writtenText = "";
  int currentIndex = 0;
  late Timer _timer;
  final FlutterTts flutterTts = FlutterTts();
  bool isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _startWriting();
  }

  void _startWriting() {
    const typingSpeed = Duration(milliseconds: 50); // Adjust typing speed
    _timer = Timer.periodic(typingSpeed, (timer) {
      if (currentIndex < widget.content.length) {
        setState(() {
          writtenText = widget.content.substring(0, currentIndex + 1);
          currentIndex++;
        });
      } else {
        timer.cancel();
        setState(() {
          isSpeaking = true;
        });
        _speakText(widget.content); // Start speaking when typing finishes
      }
    });
  }

  Future<void> _speakText(String text) async {
    await flutterTts.setLanguage("hi-IN"); // Set the language (adjust as needed)
    await flutterTts.setSpeechRate(0.4); // Set speech rate (adjust as needed)
    await flutterTts.setVolume(5.0); // Set volume (adjust as needed)
    await flutterTts.speak(text);

    if (!text.startsWith('AI')) {
      await flutterTts.speak(text);
    }

  }

  Future<void> _stopSpeaking() async {
    if (isSpeaking) {
      await flutterTts.stop();
      setState(() {
        isSpeaking = false;
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _stopSpeaking(); // Stop speaking when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: widget.isUserMessage
            ? themeData.colorScheme.primary.withOpacity(0.4)
            : themeData.colorScheme.secondary.withOpacity(0.4),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  widget.isUserMessage ? 'You' : 'AI',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (isSpeaking)
                  IconButton(
                    icon: Icon(Icons.stop, color: Colors.red), // Stop button
                    onPressed: _stopSpeaking,
                  ),
                if (!isSpeaking)
                  IconButton(
                    icon: Icon(Icons.volume_up, color: Colors.black), // Play button
                    onPressed: () {
                      _startWriting(); // Restart typing and speaking
                    },
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              writtenText,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
