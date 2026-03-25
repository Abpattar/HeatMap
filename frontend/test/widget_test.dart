// Widget test updated to match the actual app class HeatMapApp.
// The default Flutter template references MyApp which was renamed.

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';

void main() {
  testWidgets('HeatMapApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const HeatMapApp());
    // The app renders a HeatMapScreen; just verify it doesn't throw.
    expect(find.byType(HeatMapApp), findsOneWidget);
  });
}
