import 'package:flutter/material.dart';
import 'package:flutter_chat_bot/chat_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load();
  print('Token loaded: ${dotenv.env['HUGGING_FACE_TOKEN']?.isNotEmpty}');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: SafeArea(child: ChatScreen()));
  }
}
