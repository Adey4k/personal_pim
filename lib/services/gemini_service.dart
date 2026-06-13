import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../utils/env.dart';
import '../models/ai_parsed_contact.dart';

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

  Future<AiParsedContact> processInput(String text, {List<String> existingGroups = const []}) async {
    final now = DateTime.now();
    final todayStr = "${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}";
    
    final prompt = '''
      Extract contact information from text and return JSON.
      CURRENT DATE: $todayStr
      
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
      4. "groups" MUST prefer existing: ${existingGroups.join(', ')}. If user says a synonym or variation of an existing group, USE THE EXISTING ONE.
      5. PHONE NUMBERS: Keep the '+' if present. Remove ALL spaces, dashes, parentheses. ONLY digits allowed (e.g., "+380671234567" or "0671234567").
      6. DATES: Use "DD.MM.YYYY" format. 
         - Use the CURRENT YEAR (${now.year}) if the year is missing in text.
         - For "birthday", if year is unknown, use "0000" as year (e.g., "01.01.0000").
      7. BOOLEANS: Use "true" or "false" string values.
      8. CUSTOM FIELDS: If you find useful info that doesn't fit technical keys (e.g. Telegram, Address, Job, Has Kids), CREATE a new field with a descriptive key in the language of the input.
      9. DATA TYPES: Identify the most logical type for each field. Booleans for yes/no facts, dates for anniversaries, numbers for numeric IDs or phones.

      EXAMPLE:
      Current Date: 13.06.2024
      Text: "Іван Іванов, 067 123 45 67, народився 1 січня, має собаку, група Работа" (Existing groups: Робота)
      Output: {
        "name": "Іван Іванов", 
        "groups": ["Робота"], 
        "fields": [
          {"key": "phone", "value": "0671234567", "type": "number"}, 
          {"key": "birthday", "value": "01.01.0000", "type": "date"},
          {"key": "має собаку", "value": "true", "type": "boolean"}
        ]
      }

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

    final Map<String, dynamic> rawJson = jsonDecode(match) as Map<String, dynamic>;
    return AiParsedContact.fromJson(rawJson);
  }
}
