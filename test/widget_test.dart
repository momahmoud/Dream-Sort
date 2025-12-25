import 'package:dream_sort/app/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DreamSortApp());
    // Basic test
    expect(find.text('Level 1'), findsOneWidget);
  });
}
