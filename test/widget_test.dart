import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_jarr/features/jar/presentation/screens/jar_screen.dart';

void main() {
  testWidgets('Quran Jarr app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: JarScreen(),
        ),
      ),
    );

    // Verify that the app title is present
    expect(find.text('Quran Jarr'), findsOneWidget);

    // Verify that jar widget exists
    expect(find.byType(JarScreen), findsOneWidget);
  });
}
