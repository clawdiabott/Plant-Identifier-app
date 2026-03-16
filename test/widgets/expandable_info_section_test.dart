import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:plant_identifier_app/widgets/expandable_info_section.dart';

void main() {
  testWidgets('expands and shows child content', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ExpandableInfoSection(
            title: 'Care Guide',
            children: [Text('Water weekly')],
          ),
        ),
      ),
    );

    expect(find.text('Care Guide'), findsOneWidget);
    expect(find.text('Water weekly'), findsNothing);

    await tester.tap(find.text('Care Guide'));
    await tester.pumpAndSettle();

    expect(find.text('Water weekly'), findsOneWidget);
  });
}
