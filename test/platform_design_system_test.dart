import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platform_design_system/platform_design_system.dart';

void main() {
  testWidgets('DsStatChip renders label and value', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: DsTheme.light(),
        home: const Scaffold(
          body: DsStatChip(label: 'Total', value: '10'),
        ),
      ),
    );

    expect(find.text('Total '), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
  });
}
