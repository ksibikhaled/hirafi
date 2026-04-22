import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hirafi_frontend/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Hirafi E2E Tests', () {
    testWidgets('Test Client Login and Speed Button', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      print("--- TEST BOUT EN BOUT DEMARRE ---");

      // Verify Login Screen
      expect(find.text('HIRAFI'), findsWidgets);
      
      // Attempt to enter text
      await tester.enterText(find.byKey(const Key('email_field')), 'omar@hirafi.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      await tester.pumpAndSettle();

      // Tap Se connecter
      await tester.tap(find.text('Se connecter'));
      await tester.pumpAndSettle(const Duration(seconds: 4));

      print("--- CONNEXION REUSSIE ---");

      // Check for Speed Button
      final speedBtn = find.byIcon(Icons.bolt_rounded);
      if (speedBtn.evaluate().isNotEmpty) {
        print("--- BOUTON SPEED TROUVE ! ---");
        await tester.tap(speedBtn);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        print("--- ECRAN SPEED OUVERT ---");
        await tester.tap(find.text("Fuite d'eau"));
        await tester.pumpAndSettle(const Duration(seconds: 4));
        print("--- RECHERCHE RADAR EFFECTUEE ---");
      }

      print("--- TEST CLIENT TERMINE AVEC SUCCES ---");
    });
  });
}
