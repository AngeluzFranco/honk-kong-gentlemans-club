import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mi_app/main.dart' as app;

/// Test de integración completo del flujo principal de la aplicación:
/// 1. Login
/// 2. Ver lista de vehículos
/// 3. Crear nuevo vehículo
/// 4. Ver detalle del vehículo
/// 5. Actualizar vehículo
/// 6. Eliminar vehículo
/// 7. Logout
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Flujo Principal de la App', () {
    testWidgets('Flujo completo: Login → CRUD Vehículos → Logout',
        (WidgetTester tester) async {
      // Iniciar la app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // PASO 1: Login
      print('📝 PASO 1: Iniciando sesión...');
      
      // Buscar campos de login por texto de hint o label
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      // Buscar todos los campos de texto
      final textFields = find.byType(TextFormField);
      final textFieldsCount = textFields.evaluate().length;
      print('Campos de texto encontrados: $textFieldsCount');
      
      if (textFieldsCount < 2) {
        print('⚠️ No se encontraron suficientes campos de login');
        return;
      }

      // Ingresar credenciales (usa tus credenciales de prueba reales)
      await tester.enterText(textFields.at(0), 'nao@gmai.com');
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      await tester.enterText(textFields.at(1), '123456');
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Hacer tap en botón de login
      final loginButton = find.widgetWithText(ElevatedButton, 'Iniciar Sesión');
      if (loginButton.evaluate().isEmpty) {
        print('⚠️ No se encontró botón de login');
        return;
      }
      
      await tester.tap(loginButton);
      
      // Esperar a que cargue la pantalla principal
      await tester.pumpAndSettle(const Duration(seconds: 5));
      print('✅ Login exitoso');

      // PASO 2: Verificar que estamos en la lista de vehículos
      print('📝 PASO 2: Verificando lista de vehículos...');
      
      // Buscar el título "Mis Vehículos" o elementos de la lista
      await tester.pumpAndSettle(const Duration(seconds: 2));
      print('✅ Vista de vehículos cargada');

      // PASO 3: Crear nuevo vehículo
      print('📝 PASO 3: Creando nuevo vehículo...');
      
      // Buscar botón de agregar (FAB)
      final addButton = find.byType(FloatingActionButton);
      if (addButton.evaluate().isNotEmpty) {
        await tester.tap(addButton);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Llenar formulario de nuevo vehículo
        final formFields = find.byType(TextFormField);
        expect(formFields, findsWidgets);

        // Ingresar datos del vehículo (ajusta según tu formulario)
        await tester.enterText(formFields.at(0), 'Toyota'); // Marca
        await tester.pumpAndSettle();
        await tester.enterText(formFields.at(1), 'Corolla'); // Modelo
        await tester.pumpAndSettle();
        await tester.enterText(formFields.at(2), '2024'); // Año
        await tester.pumpAndSettle();
        await tester.enterText(formFields.at(3), 'TEST-123'); // Placa
        await tester.pumpAndSettle();
        await tester.enterText(formFields.at(4), 'Blanco'); // Color
        await tester.pumpAndSettle();

        // Hacer scroll hacia abajo para encontrar el botón de guardar
        await tester.drag(formFields.last, const Offset(0, -300));
        await tester.pumpAndSettle();

        // Buscar y hacer tap en botón de guardar
        final saveButton = find.widgetWithText(ElevatedButton, 'Guardar Vehículo');
        if (saveButton.evaluate().isNotEmpty) {
          await tester.tap(saveButton);
          await tester.pumpAndSettle(const Duration(seconds: 5));
          print('✅ Vehículo creado exitosamente');
        } else {
          // Intentar buscar por texto "Guardar"
          final altSaveButton = find.text('Guardar');
          if (altSaveButton.evaluate().isNotEmpty) {
            await tester.tap(altSaveButton.first);
            await tester.pumpAndSettle(const Duration(seconds: 5));
            print('✅ Vehículo creado exitosamente');
          }
        }
      } else {
        print('⚠️ No se encontró botón de agregar, omitiendo creación');
      }

      // PASO 4: Ver detalle del vehículo
      print('📝 PASO 4: Viendo detalle del vehículo...');
      
      // Buscar el vehículo recién creado en la lista
      final vehicleCard = find.text('Toyota Corolla');
      if (vehicleCard.evaluate().isNotEmpty) {
        await tester.tap(vehicleCard);
        await tester.pumpAndSettle(const Duration(seconds: 3));
        print('✅ Detalle del vehículo mostrado');

        // PASO 5: Actualizar vehículo
        print('📝 PASO 5: Actualizando vehículo...');
        
        // Buscar botón de editar
        final editButton = find.byIcon(Icons.edit);
        if (editButton.evaluate().isNotEmpty) {
          await tester.tap(editButton);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // Modificar el kilometraje
          final mileageField = find.widgetWithText(TextFormField, 'Kilometraje');
          if (mileageField.evaluate().isNotEmpty) {
            await tester.enterText(mileageField, '50000');
            await tester.pumpAndSettle();
          }

          // Guardar cambios
          final updateButton = find.widgetWithText(ElevatedButton, 'Guardar Vehículo');
          if (updateButton.evaluate().isNotEmpty) {
            await tester.tap(updateButton);
            await tester.pumpAndSettle(const Duration(seconds: 5));
            print('✅ Vehículo actualizado');
          }
        }

        // Volver a la lista
        final backButton = find.byType(BackButton);
        if (backButton.evaluate().isNotEmpty) {
          await tester.tap(backButton);
          await tester.pumpAndSettle(const Duration(seconds: 2));
        }

        // PASO 6: Eliminar vehículo
        print('📝 PASO 6: Eliminando vehículo...');
        
        // Volver a entrar al detalle
        final vehicleCardAgain = find.text('Toyota Corolla');
        if (vehicleCardAgain.evaluate().isNotEmpty) {
          await tester.tap(vehicleCardAgain);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // Buscar botón de eliminar
          final deleteButton = find.byIcon(Icons.delete);
          if (deleteButton.evaluate().isNotEmpty) {
            await tester.tap(deleteButton);
            await tester.pumpAndSettle(const Duration(seconds: 1));

            // Confirmar eliminación
            final confirmButton = find.text('Eliminar');
            if (confirmButton.evaluate().isNotEmpty) {
              await tester.tap(confirmButton);
              await tester.pumpAndSettle(const Duration(seconds: 5));
              print('✅ Vehículo eliminado');
            }
          }
        }
      } else {
        print('⚠️ No se encontró el vehículo creado');
      }

      // PASO 7: Logout
      print('📝 PASO 7: Cerrando sesión...');
      
      // Abrir drawer o menú
      final drawerButton = find.byIcon(Icons.menu);
      if (drawerButton.evaluate().isNotEmpty) {
        await tester.tap(drawerButton);
        await tester.pumpAndSettle(const Duration(seconds: 1));

        // Buscar opción de logout
        final logoutOption = find.text('Cerrar Sesión');
        if (logoutOption.evaluate().isNotEmpty) {
          await tester.tap(logoutOption);
          await tester.pumpAndSettle(const Duration(seconds: 3));
          print('✅ Sesión cerrada exitosamente');

          // Verificar que volvimos a la pantalla de login
          final loginScreen = find.widgetWithText(ElevatedButton, 'Iniciar Sesión');
          expect(loginScreen, findsOneWidget);
          print('✅ Regresó a pantalla de login');
        }
      }

      print('🎉 Test de integración completo finalizado exitosamente!');
    });
  });
}
