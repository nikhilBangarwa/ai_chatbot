import 'package:flutter_test/flutter_test.dart';

import 'package:ai_chatbot/main.dart';

void main() {
  testWidgets('App shows splash then login', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.text('AI Chatbot'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 2700));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
  });
}
