import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:graduation_research_management/screens/dean_dashboard.dart';

void main() {
  testWidgets('DeanDashboard renders without errors',
      (WidgetTester tester) async {
    // wrap in MaterialApp to provide required inherited widgets
    await tester.pumpWidget(
      const MaterialApp(
        home: DeanDashboard(),
      ),
    );

    // verify some of the static text from the dashboard
    expect(find.text('لوحة تحكم العميد'), findsOneWidget);
    expect(find.text('مرحباً، د. عبد الرحمن السعدي'), findsOneWidget);

    // tapping the notification icon should not crash
    await tester.tap(find.byIcon(Icons.notifications_none));
    await tester.pump(); // process the empty onPressed
  });
}
