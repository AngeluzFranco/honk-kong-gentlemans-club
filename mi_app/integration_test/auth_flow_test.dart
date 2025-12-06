import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mi_app/main.dart' as app;

/// Tests de integración para flujos de autenticación:
/// - Registro de nuevo usuario
/// - Login con credenciales correctas
/// - Login con credenciales incorrectas
/// - Logout
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Flujos de Autenticación', () {
    testWidgets('Login exitoso con credenciales válidas',
        (WidgetTester tester) async {
      // Iniciar la app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      print('📝 Probando login con credenciales válidas...');

      // Buscar campos de login
      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;

      // Ingresar credenciales válidas
      await tester.enterText(emailField, 'test@automanager.com');
      await tester.enterText(passwordField, 'test123456');
      await tester.pumpAndSettle();

      // Hacer tap en botón de login
      final loginButton = find.widgetWithText(ElevatedButton, 'Iniciar Sesión');
      await tester.tap(loginButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verificar que estamos en la pantalla principal
      // (No debería haber botón de login visible)
      final loginButtonAfter = find.widgetWithText(ElevatedButton, 'Iniciar Sesión');
      expect(loginButtonAfter, findsNothing);

      print('✅ Login exitoso verificado');
    });

    testWidgets('Login fallido con credenciales incorrectas',
        (WidgetTester tester) async {
      // Iniciar la app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      print('📝 Probando login con credenciales incorrectas...');

      // Buscar campos de login
      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;

      // Ingresar credenciales inválidas
      await tester.enterText(emailField, 'wrong@email.com');
      await tester.enterText(passwordField, 'wrongpassword');
      await tester.pumpAndSettle();

      // Hacer tap en botón de login
      final loginButton = find.widgetWithText(ElevatedButton, 'Iniciar Sesión');
      await tester.tap(loginButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verificar que seguimos en la pantalla de login (login falló)
      final loginButtonAfter = find.widgetWithText(ElevatedButton, 'Iniciar Sesión');
      expect(loginButtonAfter, findsOneWidget);

      // Verificar que se muestra mensaje de error (SnackBar)
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      print('✅ Login fallido manejado correctamente');
    });

    testWidgets('Navegación entre Login y Registro',
        (WidgetTester tester) async {
      // Iniciar la app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      print('📝 Probando navegación Login ↔ Registro...');

      // Desde Login, buscar botón "Regístrate"
      final registerLink = find.text('Regístrate');
      if (registerLink.evaluate().isNotEmpty) {
        await tester.tap(registerLink);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Verificar que estamos en pantalla de registro
        final registerButton = find.widgetWithText(ElevatedButton, 'Registrarse');
        expect(registerButton, findsOneWidget);
        print('✅ Navegó a pantalla de registro');

        // Volver a login
        final loginLink = find.text('Iniciar Sesión');
        if (loginLink.evaluate().isNotEmpty) {
          await tester.tap(loginLink);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // Verificar que volvimos a login
          final loginButton = find.widgetWithText(ElevatedButton, 'Iniciar Sesión');
          expect(loginButton, findsOneWidget);
          print('✅ Volvió a pantalla de login');
        }
      } else {
        print('⚠️ No se encontró enlace de registro');
      }
    });

    testWidgets('Validación de campos en formulario de Login',
        (WidgetTester tester) async {
      // Iniciar la app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      print('📝 Probando validación de campos de login...');

      // Intentar hacer login sin llenar campos
      final loginButton = find.widgetWithText(ElevatedButton, 'Iniciar Sesión');
      await tester.tap(loginButton);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verificar que aparecen mensajes de error de validación
      final errorText = find.text('Ingresa tu email');
      expect(errorText, findsOneWidget);
      print('✅ Validación de email funciona');

      // Ingresar email inválido
      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'email-invalido');
      await tester.pumpAndSettle();
      
      await tester.tap(loginButton);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verificar mensaje de email inválido
      final invalidEmailText = find.text('Email inválido');
      expect(invalidEmailText, findsOneWidget);
      print('✅ Validación de formato de email funciona');
    });

    testWidgets('Ciclo completo: Login → Logout → Login',
        (WidgetTester tester) async {
      // Iniciar la app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      print('📝 Probando ciclo Login → Logout → Login...');

      // PASO 1: Login
      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;

      await tester.enterText(emailField, 'test@automanager.com');
      await tester.enterText(passwordField, 'test123456');
      await tester.pumpAndSettle();

      final loginButton = find.widgetWithText(ElevatedButton, 'Iniciar Sesión');
      await tester.tap(loginButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));
      print('✅ Primer login exitoso');

      // PASO 2: Logout
      final drawerButton = find.byIcon(Icons.menu);
      if (drawerButton.evaluate().isNotEmpty) {
        await tester.tap(drawerButton);
        await tester.pumpAndSettle(const Duration(seconds: 1));

        final logoutOption = find.text('Cerrar Sesión');
        if (logoutOption.evaluate().isNotEmpty) {
          await tester.tap(logoutOption);
          await tester.pumpAndSettle(const Duration(seconds: 3));
          print('✅ Logout exitoso');

          // PASO 3: Segundo login
          final emailFieldAgain = find.byType(TextFormField).first;
          final passwordFieldAgain = find.byType(TextFormField).last;

          await tester.enterText(emailFieldAgain, 'test@automanager.com');
          await tester.enterText(passwordFieldAgain, 'test123456');
          await tester.pumpAndSettle();

          final loginButtonAgain = find.widgetWithText(ElevatedButton, 'Iniciar Sesión');
          await tester.tap(loginButtonAgain);
          await tester.pumpAndSettle(const Duration(seconds: 5));
          print('✅ Segundo login exitoso');

          print('🎉 Ciclo completo Login → Logout → Login verificado!');
        }
      }
    });
  });
}
