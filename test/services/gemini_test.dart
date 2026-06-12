import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:personal_pim/services/gemini_service.dart';

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
