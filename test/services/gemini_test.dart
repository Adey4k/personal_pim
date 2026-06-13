import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:personal_pim/services/gemini_service.dart';
import 'package:personal_pim/models/contact.dart';

import 'gemini_test.mocks.dart';

@GenerateMocks([GeminiClient, GeminiResponse])
void main() {
  group('GeminiService Tests', () {
    late GeminiService geminiService;
    late MockGeminiClient mockClient;

    setUp(() {
      mockClient = MockGeminiClient();
      geminiService = GeminiService(client: mockClient);
    });

    test('processInput returns parsed JSON on successful AI response', () async {
      final mockResponse = MockGeminiResponse();
      const aiJson = '{"name": "John Doe", "groups": ["Work"], "fields": [{"key": "phone", "value": "123", "type": "number"}]}';
      
      when(mockResponse.text).thenReturn(aiJson);
      when(mockClient.generateContent(any)).thenAnswer((_) async => mockResponse);

      final result = await geminiService.processInput('some text');

      expect(result.name, 'John Doe');
      expect(result.groups, ['Work']);
      expect(result.fields[0].key, 'phone');
    });

    test('processInput parses boolean, date and phone types robustly', () async {
      final mockResponse = MockGeminiResponse();
      const aiJson = '''
      {
        "name": "Jane Smith",
        "groups": ["Family"],
        "fields": [
          {"key": "phone", "value": "0991234567", "type": "phone"},
          {"key": "birthday", "value": "20.10.1985", "type": "date"},
          {"key": "has_premium", "value": "true", "type": "bool"}
        ]
      }
      ''';
      
      when(mockResponse.text).thenReturn(aiJson);
      when(mockClient.generateContent(any)).thenAnswer((_) async => mockResponse);

      final result = await geminiService.processInput('Jane Smith info');

      expect(result.name, 'Jane Smith');
      expect(result.fields[0].type, FieldType.number); // phone -> number
      expect(result.fields[1].type, FieldType.date);
      expect(result.fields[2].type, FieldType.boolean); // bool -> boolean
      expect(result.fields[2].value, 'true');
    });

    test('processInput uses current date context in prompt', () async {
      final mockResponse = MockGeminiResponse();
      when(mockResponse.text).thenReturn('{"name": "Test", "groups": [], "fields": []}');
      when(mockClient.generateContent(any)).thenAnswer((_) async => mockResponse);

      await geminiService.processInput('test');

      final captured = verify(mockClient.generateContent(captureAny)).captured;
      final content = captured.first as Iterable<Content>;
      final promptText = content.first.parts.first as TextPart;
      
      final now = DateTime.now();
      final todayStr = "${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}";
      
      expect(promptText.text, contains('CURRENT DATE: $todayStr'));
      expect(promptText.text, contains('Use the CURRENT YEAR (${now.year}) if the year is missing'));
    });

    test('processInput prompt contains existing groups for matching', () async {
      final mockResponse = MockGeminiResponse();
      when(mockResponse.text).thenReturn('{"name": "Test", "groups": [], "fields": []}');
      when(mockClient.generateContent(any)).thenAnswer((_) async => mockResponse);

      await geminiService.processInput('test', existingGroups: ['Work', 'Family']);

      final captured = verify(mockClient.generateContent(captureAny)).captured;
      final content = captured.first as Iterable<Content>;
      final promptText = content.first.parts.first as TextPart;
      
      expect(promptText.text, contains('groups" MUST prefer existing: Work, Family'));
    });

    test('processInput throws exception on empty AI response', () async {
      final mockResponse = MockGeminiResponse();
      when(mockResponse.text).thenReturn('');
      when(mockClient.generateContent(any)).thenAnswer((_) async => mockResponse);

      expect(() => geminiService.processInput('text'), throwsA(isA<Exception>()));
    });

    test('processInput throws exception on invalid JSON format', () async {
      final mockResponse = MockGeminiResponse();
      when(mockResponse.text).thenReturn('not a json');
      when(mockClient.generateContent(any)).thenAnswer((_) async => mockResponse);

      expect(() => geminiService.processInput('text'), throwsA(isA<Exception>()));
    });
  });
}
