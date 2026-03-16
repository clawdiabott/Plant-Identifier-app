import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:plant_identifier_app/models/disease_report.dart';
import 'package:plant_identifier_app/widgets/severity_chip.dart';

void main() {
  testWidgets('renders severity text', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SeverityChip(severity: SeverityLevel.critical),
        ),
      ),
    );

    expect(find.text('CRITICAL'), findsOneWidget);
  });
}
