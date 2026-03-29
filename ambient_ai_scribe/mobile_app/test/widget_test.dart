import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ambient_ai_scribe/app/app.dart';

void main() {
  testWidgets('Ambient AI Scribe smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AmbientAIScribeApp());

    // Verify that app loads without errors
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Ambient AI Scribe'), findsOneWidget);
  });
}
