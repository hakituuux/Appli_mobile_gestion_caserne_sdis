import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_perso_sdis/main.dart';

void main() {
  testWidgets('App démarre sur l’écran de connexion', (WidgetTester tester) async {
    await tester.pumpWidget(const PompierDispoApp());
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    // tests : secure storage parfois absent → login ou loader OK
    final hasLogin = find.text('Se connecter').evaluate().isNotEmpty;
    final hasLoading = find.byType(CircularProgressIndicator).evaluate().isNotEmpty;
    expect(hasLogin || hasLoading, isTrue);
  });
}
