import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../models/chat_message.dart';

class GroqApiService {
  GroqApiService({required this.apiKey});

  final String apiKey;
  static final _url =
      Uri.parse('https://api.groq.com/openai/v1/chat/completions');

  String systemPromptForMode(String mode) {
    switch (mode) {
      case 'Tech':
        return 'You are AI Chatbot, a senior software engineer. Give precise technical answers with code examples when needed.';
      case 'Hinglish':
        return 'Tum AI Chatbot ho. Saare jawab Hinglish (Hindi + English mix) mein do.';
      case 'Simple':
        return 'You are AI Chatbot. Explain everything simply for a beginner. Use analogies and real examples.';
      case 'Compare':
        return 'You are AI Chatbot. Give balanced comparisons with pros, cons, and clear recommendations.';
      default:
        return 'You are AI Chatbot, an intelligent, helpful AI assistant. Be concise, accurate, and friendly.';
    }
  }

  Future<String> textCompletion({
    required String mode,
    required List<ChatMessage> history,
    required String query,
  }) async {
    final msgs = <Map<String, String>>[
      {'role': 'system', 'content': systemPromptForMode(mode)},
    ];
    final start = history.length > 6 ? history.length - 6 : 0;
    for (var i = start; i < history.length; i++) {
      msgs.add({
        'role': history[i].isUser ? 'user' : 'assistant',
        'content': history[i].text,
      });
    }

    final res = await http.post(
      _url,
      headers: _headers,
      body: jsonEncode({
        'model': 'llama-3.3-70b-versatile',
        'messages': msgs,
        'temperature': 0.7,
        'max_tokens': 1024,
      }),
    );
    return _parseResponse(res);
  }

  Future<String> imageCompletion({
    required String mode,
    required File image,
    required String question,
  }) async {
    final bytes = await image.readAsBytes();
    final base64Image = base64Encode(bytes);
    final ext = image.path.split('.').last.toLowerCase();
    final mimeType = ext == 'png' ? 'image/png' : 'image/jpeg';
    final q = question.isNotEmpty
        ? question
        : 'Is image mein kya hai? Detail mein batao.';

    final res = await http.post(
      _url,
      headers: _headers,
      body: jsonEncode({
        'model': 'meta-llama/llama-4-scout-17b-16e-instruct',
        'messages': [
          {'role': 'system', 'content': systemPromptForMode(mode)},
          {
            'role': 'user',
            'content': [
              {
                'type': 'image_url',
                'image_url': {'url': 'data:$mimeType;base64,$base64Image'},
              },
              {'type': 'text', 'text': q},
            ],
          },
        ],
        'temperature': 0.7,
        'max_tokens': 1024,
      }),
    );
    return _parseResponse(res);
  }

  Future<String> documentCompletion({
    required String mode,
    required String fileContent,
    required String fileName,
    required String question,
  }) async {
    final q = question.isNotEmpty
        ? question
        : 'Is document ka summary do aur main points batao.';
    final truncated = fileContent.length > 6000
        ? fileContent.substring(0, 6000)
        : fileContent;

    final res = await http.post(
      _url,
      headers: _headers,
      body: jsonEncode({
        'model': 'llama-3.3-70b-versatile',
        'messages': [
          {
            'role': 'system',
            'content':
                '${systemPromptForMode(mode)} You are also a document analyst.',
          },
          {
            'role': 'user',
            'content':
                'File: "$fileName"\n\nContent: $truncated\n\nSawaal: $q',
          },
        ],
        'temperature': 0.7,
        'max_tokens': 2048,
      }),
    );
    return _parseResponse(res);
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      };

  String _parseResponse(http.Response res) {
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['choices'][0]['message']['content']
          as String;
    }
    throw Exception('API error ${res.statusCode}: ${res.body}');
  }
}
