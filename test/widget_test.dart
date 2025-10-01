// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:avivamiento_app/main.dart';
import 'package:avivamiento_app/providers/services_provider.dart';
import 'package:avivamiento_app/services/auth_service.dart';
import 'package:avivamiento_app/services/user_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MockAuthService extends Mock implements AuthService {}

class MockUserService extends Mock implements UserService {}

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    final mockAuthService = MockAuthService();
    final mockUserService = MockUserService();
    // Devuelve un stream vacío del tipo correcto para authStateChanges
    when(
      mockAuthService.authStateChanges,
    ).thenAnswer((_) => Stream<User?>.empty());

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
          userServiceProvider.overrideWithValue(mockUserService),
        ],
        child: const MyApp(),
      ),
    );

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
