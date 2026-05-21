import 'package:flutter_test/flutter_test.dart';
import 'package:wazza/main.dart';

void main() {
  testWidgets('App loads without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const WazzaApp(initialDarkMode: false));
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.byType(WazzaApp), findsOneWidget);
  });
}
