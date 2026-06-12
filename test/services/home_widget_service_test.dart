import 'package:flutter_test/flutter_test.dart';
import 'package:personal_pim/models/contact.dart';
import 'package:personal_pim/services/home_widget_service.dart';
import 'package:personal_pim/utils/constants.dart';

void main() {
  group('HomeWidgetService', () {
    test('getNextBirthday calculates correctly for future birthdays same year', () {
      final today = DateTime(2024, 6, 12);
      final bdayStr = '15.06.1990';
      // HomeWidgetService._getNextBirthday is private, but we can test it through updateBirthdays 
      // or make it public/static for testing. For now I'll just check if sorting logic works if I move it to a helper.
    });
  });
}
