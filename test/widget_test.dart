import 'package:flutter_test/flutter_test.dart';
import 'package:relycare/app/app.dart';

void main() {
  testWidgets('App smoke test initializes RelyCareApp', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const RelyCareApp());

    // Verify app launches successfully
    expect(find.byType(RelyCareApp), findsOneWidget);

    // Advance past the splash screen delay timer
    await tester.pumpAndSettle(const Duration(seconds: 3));
  });
}
