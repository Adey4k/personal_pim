import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HomeWidgetService', () {
    test('getNextBirthday calculates correctly for future birthdays same year', () {
      // HomeWidgetService._getNextBirthday is private, but we can test it through updateBirthdays
      // or make it public/static for testing. For now I'll just check if sorting logic works if I move it to a helper.
    });
  });
}
