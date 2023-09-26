import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _inputController = TextEditingController();
  final List<ChatMessage> _messages = [];

  // Replace with your OpenAI API key
  final String apiKey = "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";
  final String apiUrl = "https://api.openai.com/v1/engines/davinci/completions";

  void _sendMessage(String message) async {
    _inputController.clear();
    _addMessage(message, true);

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $apiKey",
      },
      body: jsonEncode({
        "prompt": "Give ANTENATAL CARE RELATED FEEDBACK $message",
        "max_tokens": 50, // Adjust as needed
        "model": "davinci" // Specify the model
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final String botReply = data['choices'][0]['text'];
      _addMessage(botReply, false);
    } else {
      if (kDebugMode) {
        print("Error: ${response.statusCode}");
      }
    }
  }

  void _addMessage(String text, bool isUserMessage) {
    setState(() {
      _messages.add(ChatMessage(text, isUserMessage));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('private motherChat'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Align(
                  alignment: message.isUserMessage
                      ? Alignment.topLeft
                      : Alignment.topRight,
                  child: ChatBubble(message.text, message.isUserMessage),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _inputController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    final userMessage = _inputController.text;
                    if (userMessage.isNotEmpty) {
                      _sendMessage(userMessage);
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUserMessage;

  ChatMessage(this.text, this.isUserMessage);
}

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isUserMessage;

  const ChatBubble(this.text, this.isUserMessage, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: isUserMessage ? Colors.blue : Colors.green,
        borderRadius: isUserMessage
            ? const BorderRadius.only(
                topLeft: Radius.circular(15.0),
                topRight: Radius.circular(15.0),
                bottomRight: Radius.circular(15.0),
              )
            : const BorderRadius.only(
                topLeft: Radius.circular(15.0),
                topRight: Radius.circular(15.0),
                bottomLeft: Radius.circular(15.0),
              ),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16.0, color: Colors.white),
      ),
    );
  }
}
