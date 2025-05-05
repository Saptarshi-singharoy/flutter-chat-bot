import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'services/huggingface_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final HuggingFaceService _service = HuggingFaceService();
  final String _conversationId = const Uuid().v4(); // Unique ID for this chat

  // final HuggingFaceService _chatService = HuggingFaceService(); // Single persistent instance

  void _sendMessage() async {
    if (_controller.text.isEmpty) return;

    setState(() {
      _messages.add({'text': _controller.text, 'isUser': true});
      _messages.add({'text': '...', 'isUser': false}); // Loading indicator
    });

    final String botResponse = await _service.getResponse(
      _controller.text,
      conversationId: _conversationId,
    );
    _controller.clear();

    setState(() {
      _messages.removeLast(); // Remove loading
      _messages.add({'text': botResponse, 'isUser': false});
    });
  }

  @override
  Widget build(BuildContext context) {
    print("MESSAGIO::");
    print(_messages);
    return Scaffold(
      appBar: AppBar(title: Text('AI Assistant')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 4),
                  alignment:
                      _messages[index]['isUser']
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          _messages[index]['isUser']
                              ? Colors.blue[100]
                              : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(_messages[index]['text']),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(icon: Icon(Icons.send), onPressed: _sendMessage),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
