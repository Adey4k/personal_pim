import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
        ),
      );

  @override
  Future<GeminiResponse> generateContent(Iterable<Content> content) async {
    final response = await _model.generateContent(content);
    return GoogleGeminiResponse(response);
  }
}

class AiDailyLimitExceededException implements Exception {
  final int limit;
  final String dateKey;

  AiDailyLimitExceededException({required this.limit, required this.dateKey});

  @override
  String toString() => 'AI daily limit exceeded';
}

abstract class AiRequestQuotaStore {
  Future<void> reserveRequest({
    required DateTime date,
    required int dailyLimit,
  });
}

class FirestoreAiRequestQuotaStore implements AiRequestQuotaStore {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  FirestoreAiRequestQuotaStore({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> reserveRequest({
    required DateTime date,
    required int dailyLimit,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('userNotAuthenticated');

    final dateKey = _formatQuotaDate(date);
    final docRef = _firestore
        .collection(user.uid)
        .doc('--ai-usage--')
        .collection('daily')
        .doc(dateKey);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      final data = snapshot.data();
      final currentCount = (data?['count'] as num?)?.toInt() ?? 0;

      if (currentCount >= dailyLimit) {
        throw AiDailyLimitExceededException(
          limit: dailyLimit,
          dateKey: dateKey,
        );
      }

      transaction.set(docRef, {
        'count': currentCount + 1,
        'date': dateKey,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  static String _formatQuotaDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}

class GeminiService {
  static const int dailyRequestLimit = 10;

  final GeminiClient _client;
  final AiRequestQuotaStore _quotaStore;
  final DateTime Function() _clock;

  GeminiService({
    GeminiClient? client,
    AiRequestQuotaStore? quotaStore,
    DateTime Function()? clock,
  }) : _client = client ?? GoogleGeminiClient(),
       _quotaStore = quotaStore ?? FirestoreAiRequestQuotaStore(),
       _clock = clock ?? DateTime.now;

  Future<AiParsedContact> processInput(
    String text, {
    List<String> existingGroups = const [],
    List<String> existingFields = const [],
  }) async {
    final now = _clock();
    await _quotaStore.reserveRequest(date: now, dailyLimit: dailyRequestLimit);

    final todayStr =
        "${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}";
    final existingGroupsText = existingGroups.isEmpty
        ? '(none)'
        : existingGroups.join(', ');
    final existingFieldsText = existingFields.isEmpty
        ? '(none)'
        : existingFields.join(', ');

    final prompt =
        '''
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
      4. EXISTING FIELDS: $existingFieldsText. BEFORE creating any new field, compare the meaning with existing fields and technical keys. If the information is a synonym, translation, abbreviation, spelling/case variation, singular/plural form, or closely related label, USE THE EXISTING FIELD KEY EXACTLY AS WRITTEN. Create a new custom field ONLY when no existing or technical field fits at all.
      5. EXISTING GROUPS: $existingGroupsText. BEFORE creating any new group, compare the meaning with existing groups. If the group is a synonym, translation, abbreviation, spelling/case/spacing variation, or closely related label, USE THE EXISTING GROUP EXACTLY AS WRITTEN. Create a new group ONLY when no existing group fits at all.
      6. PHONE NUMBERS: Keep the '+' if present. Remove ALL spaces, dashes, parentheses. ONLY digits allowed (e.g., "+380671234567" or "0671234567").
      7. DATES: Use "DD.MM.YYYY" format.
         - Use the CURRENT YEAR (${now.year}) if the year is missing in text.
         - For "birthday", if year is unknown, use "0000" as year (e.g., "01.01.0000").
      8. BOOLEANS: Use "true" or "false" string values.
      9. CUSTOM FIELDS: If useful info does not fit technical keys or any existing field (e.g. Telegram, Address, Job, Has Kids), create one descriptive field key in the language of the input.
      10. DATA TYPES: Identify the most logical type for each field. Booleans for yes/no facts, dates for anniversaries, numbers for numeric IDs or phones.

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

    final Map<String, dynamic> rawJson =
        jsonDecode(match) as Map<String, dynamic>;
    return AiParsedContact.fromJson(rawJson);
  }
}
