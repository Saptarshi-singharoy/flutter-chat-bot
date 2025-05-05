import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HuggingFaceService {
  static final String? _apiKey = dotenv.env['HUGGING_FACE_TOKEN'];
  static const String _apiUrl = 'https://api-inference.huggingface.co/models';
  final String modelName = 'facebook/blenderbot-400M-distill';

  // Store conversation history
  final List<Map<String, String>> _conversationHistory = [];
  final Map<String, List<Map<String, String>>> _conversations = {};

  Future<String> getResponse(
    String message, {
    required String conversationId,
  }) async {
    final convId = conversationId;
    _conversations.putIfAbsent(convId, () => []);
    _conversations[convId]!.add({'role': 'user', 'content': message});

    try {
      // Build context-aware input
      final conversation = _conversations[convId]!;
      final combinedContext = conversation
          .map(
            (msg) =>
                msg['role'] == 'user'
                    ? "User: ${msg['content']}"
                    : "Bot: ${msg['content']}",
          )
          .join('\n');

      final response = await http.post(
        Uri.parse('$_apiUrl/$modelName'),
        headers: {'Authorization': 'Bearer $_apiKey'},
        body: jsonEncode({'inputs': combinedContext}),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final botReply =
            decoded[0]['generated_text']
                .split('Bot:')
                .last
                .trim(); // Ensures we only get the reply part

        _conversations[convId]!.add({'role': 'assistant', 'content': botReply});

        return botReply;
      } else {
        return "Error: ${response.statusCode}";
      }
    } catch (e) {
      return "Error: ${e.toString()}";
    }
  }

  void clearConversation({String? conversationId}) {
    final convId = conversationId ?? 'default';
    _conversations[convId]?.clear();
  }
}
