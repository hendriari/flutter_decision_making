// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:example/main.dart';

void main() {
  testWidgets('Decision Making Page smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the title and algorithm options are displayed.
    expect(find.text('Flutter Decision Making'), findsOneWidget);
    expect(find.text('Choose algorithm:'), findsOneWidget);
    expect(find.text('Analytical Hierarchy Process'), findsOneWidget);
    expect(find.text('Sample Additive Weighting'), findsOneWidget);
    expect(find.text('TOPSIS'), findsOneWidget);
  });
}
