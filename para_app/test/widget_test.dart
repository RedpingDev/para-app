import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:para_app/main.dart';

void main() {
  testWidgets('App launches without error', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: ParaApp()),
    );

    // Basic smoke test - verify app renders
    expect(find.text('대시보드'), findsOneWidget);
  });
}
