import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HuggingFaceService {
  static final String? _apiKey = dotenv.env['HUGGING_FACE_TOKEN'];
  static const String _apiUrl = 'https://api-inference.huggingface.co/models';

  // Choose a model (updated list: https://huggingface.co/models?pipeline_tag=text-generation)
  final String modelName = 'facebook/blenderbot-400M-distill';

  Future<String> getResponse(String message) async {
    try {
      final response = await http.post(
        Uri.parse('$_apiUrl/$modelName'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'inputs': message}),
      );

      print(jsonDecode(response.body));
      print(response.statusCode);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        print("MEAW");
        return decoded[0]['generated_text'] ?? "I didn't understand that";
      } else if (response.statusCode == 503) {
        // Model loading cold start
        return "The AI is warming up... try again in 10 seconds";
      } else {
        return "Error: ${response.statusCode}";
      }
    } catch (e) {
      return "Connection failed: ${e.toString()}";
    }
  }
}
