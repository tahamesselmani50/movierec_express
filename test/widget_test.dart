// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:movierec_express/features/auth/data/models/user_model.dart';

import 'package:movierec_express/main.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final tempDir = Directory.systemTemp.createTempSync('movierec_test_');
    Hive.init(tempDir.path);
    Hive.registerAdapter(UserModelAdapter());
  });

  testWidgets('App launches to splash screen', (WidgetTester tester) async {
    // Build the app inside ProviderScope required by Riverpod.
    await tester.pumpWidget(const ProviderScope(child: MovieRecApp()));

    // Verify splash screen appears.
    expect(find.text('MovieRec'), findsOneWidget);
    expect(find.text('Express'), findsOneWidget);
  });
}
