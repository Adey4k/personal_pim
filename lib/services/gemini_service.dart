import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../utils/env.dart';

abstract class GeminiResponse {
  String? get text;
}

class GoogleGeminiResponse implements GeminiResponse {
  final GenerateContentResponse _response;
  GoogleGeminiResponse(this._response);

  @override
  String? get text => _response.text;
}

abstract class GeminiClient {
  Future<GeminiResponse> generateContent(Iterable<Content> content);
}

class GoogleGeminiClient implements GeminiClient {
  final GenerativeModel _model;

  GoogleGeminiClient()
      : _model = GenerativeModel(
          model: 'gemini-3.1-flash-lite',
          apiKey: Env.geminiApiKey,
          generationConfig: GenerationConfig(responseMimeType: 'application/json'),
        );

  @override
  Future<GeminiResponse> generateContent(Iterable<Content> content) async {
    final response = await _model.generateContent(content);
    return GoogleGeminiResponse(response);
  }
}

class GeminiService {
  final GeminiClient _client;

  GeminiService({GeminiClient? client}) : _client = client ?? GoogleGeminiClient();

  Future<Map<String, dynamic>> processInput(String text, {List<String> existingGroups = const []}) async {
    final prompt = '''
      Extract contact information from text and return JSON.
      
      JSON FORMAT:
      {
        "name": "Person Name Only",
        "groups": ["Group1", "Group2"],
        "fields": [
          {"key": "technical_key", "value": "value", "type": "number|date|boolean|text"}
        ]
      }

      STRICT RULES:
      1. NO REASONING. NO COMMENTS. NO ANALYSIS.
      2. "name" MUST BE ONLY A HUMAN NAME. EMPTY IF NOT FOUND.
      3. Use technical keys for "fields": "phone", "email", "birthday".
      4. "groups" should match existing: ${existingGroups.join(', ')}.
      5. CUSTOM FIELDS: If you find useful info that doesn't fit technical keys (e.g. Telegram, Address, Job), CREATE a new field with a descriptive key in the language of the input.

      EXAMPLE:
      Text: "John Doe, +123, john@me.com, lives in London, group Work"
      Output: {"name": "John Doe", "groups": ["Work"], "fields": [{"key": "phone", "value": "+123", "type": "number"}, {"key": "email", "value": "john@me.com", "type": "text"}, {"key": "Address", "value": "London", "type": "text"}]}

      TEXT TO ANALYZE:
      $text
      ''';

    final response = await _client.generateContent([Content.text(prompt)]);
    final jsonStr = response.text;

    if (jsonStr == null || jsonStr.isEmpty) {
      throw Exception("AI returned empty response");
    }

    final jsonRegex = RegExp(r'\{[\s\S]*\}');
    final match = jsonRegex.stringMatch(jsonStr);
    if (match == null) {
      throw Exception("Invalid AI response format");
    }

    return jsonDecode(match) as Map<String, dynamic>;
  }
}
