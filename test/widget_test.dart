// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:moim_money_flutter/main.dart';

void main() {
  testWidgets('머니투게더 앱 기본 테스트', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MoimMoneyApp());

    // Verify that our app shows the correct title
    expect(find.text('머니투게더'), findsOneWidget);
  });
}
