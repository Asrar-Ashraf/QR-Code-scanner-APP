// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:qr_generator/screens/home_screen.dart';
import 'package:qr_generator/screens/final_card_screen.dart';
import 'package:qr_generator/screens/qr_generator_screen.dart';
import 'package:qr_generator/screens/splash_screen.dart';
import 'package:qr_generator/screens/text_link_screen.dart';

void main() {
  testWidgets('QR generator validates empty input and generates a code', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: QrGeneratorScreen()));

    expect(find.text('Text or URL'), findsOneWidget);
    await tester.tap(find.text('Generate QR Code'));
    await tester.pump();
    expect(find.text('Please enter some text or a URL'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'https://example.com');
    await tester.tap(find.text('Generate QR Code'));
    await tester.pump();
    expect(find.byType(QrGeneratorScreen), findsOneWidget);
    expect(find.text('Please enter some text or a URL'), findsNothing);
  });

  testWidgets('splash screen replaces itself with Home after its animation', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
    expect(find.byType(SplashScreen), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('QR Studio'), findsOneWidget);
    expect(find.byType(SplashScreen), findsNothing);
  });

  testWidgets('home options open their matching placeholder screens', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pump(const Duration(milliseconds: 600));

    await tester.tap(find.text('Scan QR Code'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Scanner'), findsNWidgets(2));

    await tester.pageBack();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text('Text / Link'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Text / Link'), findsOneWidget);
  });

  testWidgets('Text/Link form validates required fields and text length', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: TextLinkScreen()));

    await tester.tap(find.text('Generate'));
    await tester.pump();
    expect(find.text('Add some text or a link to continue.'), findsOneWidget);
    expect(find.text('Please enter a name for your card.'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'x' * 1001);
    await tester.enterText(find.byType(TextField).last, 'Alex');
    await tester.tap(find.text('Generate'));
    await tester.pump();
    expect(find.text('Keep your text under 1,000 characters.'), findsOneWidget);
  });

  testWidgets(
    'valid Text/Link content opens a poster and Create New returns home',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(find.text('Text / Link').first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      await tester.enterText(
        find.byType(TextField).first,
        'https://example.com',
      );
      await tester.enterText(find.byType(TextField).last, 'Alex');
      await tester.tap(find.text('Generate'));
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(FinalCardScreen), findsOneWidget);
      expect(find.text('Scan to connect'), findsOneWidget);
      expect(find.text('Alex'), findsOneWidget);

      await tester.tap(find.text('Create New'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('Scan QR Code'), findsOneWidget);
    },
  );
}
