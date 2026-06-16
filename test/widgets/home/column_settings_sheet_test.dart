import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_pim/l10n/app_localizations.dart';
import 'package:personal_pim/utils/constants.dart';
import 'package:personal_pim/widgets/home/column_settings_sheet.dart';

void main() {
  Widget buildTestApp({
    required Set<String> allKeys,
    required List<String> columns,
  }) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: ColumnSettingsSheet(
          allKeys: allKeys,
          columns: columns,
          onReorder: (oldIndex, newIndex) {
            final item = columns.removeAt(oldIndex);
            columns.insert(newIndex, item);
          },
          onRemove: (index) {
            columns.removeAt(index);
          },
          onAdd: (key) {
            columns.add(key);
          },
          onSave: () {},
        ),
      ),
    );
  }

  testWidgets('removed columns immediately move to available fields', (
    tester,
  ) async {
    final columns = [AppKeys.name, AppKeys.phone];

    await tester.pumpWidget(
      buildTestApp(
        allKeys: {AppKeys.name, AppKeys.phone, AppKeys.email},
        columns: columns,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Phone'), findsOneWidget);
    expect(find.text('+ Phone'), findsNothing);

    final phoneTile = find.ancestor(
      of: find.text('Phone'),
      matching: find.byType(ListTile),
    );

    await tester.tap(
      find.descendant(of: phoneTile, matching: find.byIcon(Icons.close)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Phone'), findsNothing);
    expect(find.text('+ Phone'), findsOneWidget);
    expect(columns, [AppKeys.name]);
  });
}
