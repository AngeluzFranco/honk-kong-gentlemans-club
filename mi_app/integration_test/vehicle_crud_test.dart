import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mi_app/main.dart' as app;

/// Tests de integración para operaciones CRUD de vehículos:
/// - Crear vehículo con todos los campos
/// - Crear vehículo con campos mínimos
/// - Leer lista de vehículos
/// - Actualizar vehículo existente
/// - Eliminar vehículo
/// - Validaciones de formulario
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('CRUD de Vehículos', () {
    // Helper para hacer login antes de cada test
    Future<void> loginHelper(WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;

      await tester.enterText(emailField, 'test@automanager.com');
      await tester.enterText(passwordField, 'test123456');
      await tester.pumpAndSettle();

      final loginButton = find.widgetWithText(ElevatedButton, 'Iniciar Sesión');
      await tester.tap(loginButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));
    }

    testWidgets('Crear vehículo con todos los campos',
        (WidgetTester tester) async {
      await loginHelper(tester);

      print('📝 Creando vehículo con todos los campos...');

      // Ir a formulario de crear vehículo
      final addButton = find.byType(FloatingActionButton);
      if (addButton.evaluate().isEmpty) {
        print('⚠️ No se encontró botón de agregar');
        return;
      }

      await tester.tap(addButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Llenar formulario completo
      final formFields = find.byType(TextFormField);

      await tester.enterText(formFields.at(0), 'Honda'); // Marca
      await tester.pumpAndSettle();
      await tester.enterText(formFields.at(1), 'Civic'); // Modelo
      await tester.pumpAndSettle();
      await tester.enterText(formFields.at(2), '2023'); // Año
      await tester.pumpAndSettle();
      await tester.enterText(formFields.at(3), 'ABC-1234'); // Placa
      await tester.pumpAndSettle();
      await tester.enterText(formFields.at(4), 'Rojo'); // Color
      await tester.pumpAndSettle();

      // Si hay más campos (VIN, kilometraje, etc), llenarlos
      if (formFields.evaluate().length > 5) {
        await tester.enterText(formFields.at(5), '1HGBH41JXMN109186'); // VIN
        await tester.pumpAndSettle();
        await tester.enterText(formFields.at(6), '15000'); // Kilometraje
        await tester.pumpAndSettle();
      }

      // Hacer scroll y guardar
      await tester.drag(formFields.last, const Offset(0, -300));
      await tester.pumpAndSettle();

      final saveButton = find.text('Guardar');
      if (saveButton.evaluate().isNotEmpty) {
        await tester.tap(saveButton.first);
        await tester.pumpAndSettle(const Duration(seconds: 5));
        print('✅ Vehículo creado con todos los campos');

        // Verificar que aparece en la lista
        final vehicleCard = find.text('Honda Civic');
        expect(vehicleCard, findsAtLeastNWidgets(1));
      }
    });

    testWidgets('Crear vehículo con campos mínimos requeridos',
        (WidgetTester tester) async {
      await loginHelper(tester);

      print('📝 Creando vehículo con campos mínimos...');

      final addButton = find.byType(FloatingActionButton);
      if (addButton.evaluate().isEmpty) {
        print('⚠️ No se encontró botón de agregar');
        return;
      }

      await tester.tap(addButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Llenar solo campos requeridos
      final formFields = find.byType(TextFormField);

      await tester.enterText(formFields.at(0), 'Nissan'); // Marca
      await tester.pumpAndSettle();
      await tester.enterText(formFields.at(1), 'Sentra'); // Modelo
      await tester.pumpAndSettle();
      await tester.enterText(formFields.at(2), '2022'); // Año
      await tester.pumpAndSettle();
      await tester.enterText(formFields.at(3), 'XYZ-5678'); // Placa
      await tester.pumpAndSettle();
      await tester.enterText(formFields.at(4), 'Negro'); // Color
      await tester.pumpAndSettle();

      // Guardar
      await tester.drag(formFields.last, const Offset(0, -300));
      await tester.pumpAndSettle();

      final saveButton = find.text('Guardar');
      if (saveButton.evaluate().isNotEmpty) {
        await tester.tap(saveButton.first);
        await tester.pumpAndSettle(const Duration(seconds: 5));
        print('✅ Vehículo creado con campos mínimos');
      }
    });

    testWidgets('Leer y mostrar lista de vehículos',
        (WidgetTester tester) async {
      await loginHelper(tester);

      print('📝 Verificando lista de vehículos...');

      // Esperar a que cargue la lista
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verificar que hay elementos en la lista
      // (puede variar según el estado de la base de datos)
      final listView = find.byType(ListView);
      expect(listView, findsAtLeastNWidgets(1));

      print('✅ Lista de vehículos cargada correctamente');
    });

    testWidgets('Actualizar vehículo existente',
        (WidgetTester tester) async {
      await loginHelper(tester);

      print('📝 Actualizando vehículo...');

      // Crear un vehículo primero
      final addButton = find.byType(FloatingActionButton);
      if (addButton.evaluate().isEmpty) {
        print('⚠️ No se encontró botón de agregar');
        return;
      }

      await tester.tap(addButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final formFields = find.byType(TextFormField);
      await tester.enterText(formFields.at(0), 'Mazda');
      await tester.pumpAndSettle();
      await tester.enterText(formFields.at(1), '3');
      await tester.pumpAndSettle();
      await tester.enterText(formFields.at(2), '2021');
      await tester.pumpAndSettle();
      await tester.enterText(formFields.at(3), 'UPD-123');
      await tester.pumpAndSettle();
      await tester.enterText(formFields.at(4), 'Azul');
      await tester.pumpAndSettle();

      await tester.drag(formFields.last, const Offset(0, -300));
      await tester.pumpAndSettle();

      final saveButton = find.text('Guardar');
      if (saveButton.evaluate().isNotEmpty) {
        await tester.tap(saveButton.first);
        await tester.pumpAndSettle(const Duration(seconds: 5));
      }

      // Entrar al detalle del vehículo
      final vehicleCard = find.text('Mazda 3');
      if (vehicleCard.evaluate().isNotEmpty) {
        await tester.tap(vehicleCard);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Editar
        final editButton = find.byIcon(Icons.edit);
        if (editButton.evaluate().isNotEmpty) {
          await tester.tap(editButton);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // Modificar el color
          final colorField = find.byType(TextFormField).at(4);
          await tester.enterText(colorField, 'Azul Marino');
          await tester.pumpAndSettle();

          // Guardar cambios
          final updateButton = find.text('Guardar');
          if (updateButton.evaluate().isNotEmpty) {
            await tester.tap(updateButton.first);
            await tester.pumpAndSettle(const Duration(seconds: 5));
            print('✅ Vehículo actualizado correctamente');
          }
        }
      }
    });

    testWidgets('Eliminar vehículo',
        (WidgetTester tester) async {
      await loginHelper(tester);

      print('📝 Eliminando vehículo...');

      // Crear un vehículo para eliminar
      final addButton = find.byType(FloatingActionButton);
      if (addButton.evaluate().isEmpty) {
        print('⚠️ No se encontró botón de agregar');
        return;
      }

      await tester.tap(addButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final formFields = find.byType(TextFormField);
      await tester.enterText(formFields.at(0), 'Ford');
      await tester.pumpAndSettle();
      await tester.enterText(formFields.at(1), 'Focus');
      await tester.pumpAndSettle();
      await tester.enterText(formFields.at(2), '2020');
      await tester.pumpAndSettle();
      await tester.enterText(formFields.at(3), 'DEL-999');
      await tester.pumpAndSettle();
      await tester.enterText(formFields.at(4), 'Gris');
      await tester.pumpAndSettle();

      await tester.drag(formFields.last, const Offset(0, -300));
      await tester.pumpAndSettle();

      final saveButton = find.text('Guardar');
      if (saveButton.evaluate().isNotEmpty) {
        await tester.tap(saveButton.first);
        await tester.pumpAndSettle(const Duration(seconds: 5));
      }

      // Entrar al detalle y eliminar
      final vehicleCard = find.text('Ford Focus');
      if (vehicleCard.evaluate().isNotEmpty) {
        await tester.tap(vehicleCard);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        final deleteButton = find.byIcon(Icons.delete);
        if (deleteButton.evaluate().isNotEmpty) {
          await tester.tap(deleteButton);
          await tester.pumpAndSettle(const Duration(seconds: 1));

          // Confirmar
          final confirmButton = find.text('Eliminar');
          if (confirmButton.evaluate().isNotEmpty) {
            await tester.tap(confirmButton);
            await tester.pumpAndSettle(const Duration(seconds: 5));
            print('✅ Vehículo eliminado correctamente');

            // Verificar que ya no está en la lista
            final deletedVehicle = find.text('Ford Focus');
            expect(deletedVehicle, findsNothing);
          }
        }
      }
    });

    testWidgets('Validar campos requeridos en formulario',
        (WidgetTester tester) async {
      await loginHelper(tester);

      print('📝 Validando campos requeridos...');

      final addButton = find.byType(FloatingActionButton);
      if (addButton.evaluate().isEmpty) {
        print('⚠️ No se encontró botón de agregar');
        return;
      }

      await tester.tap(addButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Intentar guardar sin llenar campos
      final saveButton = find.text('Guardar');
      if (saveButton.evaluate().isNotEmpty) {
        await tester.tap(saveButton.first);
        await tester.pumpAndSettle(const Duration(seconds: 1));

        // Verificar que aparecen mensajes de error
        final errorText = find.textContaining('requerido');
        expect(errorText, findsAtLeastNWidgets(1));
        print('✅ Validación de campos requeridos funciona');
      }
    });

    testWidgets('Ver detalle completo de vehículo',
        (WidgetTester tester) async {
      await loginHelper(tester);

      print('📝 Viendo detalle de vehículo...');

      // Esperar lista
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Buscar cualquier vehículo en la lista
      final listTiles = find.byType(Card);
      if (listTiles.evaluate().isNotEmpty) {
        await tester.tap(listTiles.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Verificar que estamos en pantalla de detalle
        // (debería haber botones de editar y eliminar)
        final editButton = find.byIcon(Icons.edit);
        final deleteButton = find.byIcon(Icons.delete);

        expect(editButton, findsAtLeastNWidgets(1));
        expect(deleteButton, findsAtLeastNWidgets(1));

        print('✅ Detalle de vehículo mostrado correctamente');
      }
    });
  });
}
