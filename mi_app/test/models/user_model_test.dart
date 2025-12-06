import 'package:flutter_test/flutter_test.dart';
import 'package:mi_app/models/user_model.dart';

void main() {
  group('User Model Tests', () {
    late Map<String, dynamic> validJson;
    late User testUser;

    setUp(() {
      validJson = {
        'id': 'user-123',
        'email': 'test@example.com',
        'name': 'Juan Pérez',
      };

      testUser = User(
        id: 'user-123',
        email: 'test@example.com',
        name: 'Juan Pérez',
      );
    });

    test('Crear usuario con campos requeridos', () {
      final user = User(
        id: 'user-456',
        email: 'usuario@test.com',
        name: 'María García',
      );

      expect(user.id, 'user-456');
      expect(user.email, 'usuario@test.com');
      expect(user.name, 'María García');
    });

    test('Crear usuario con todos los campos', () {
      expect(testUser.id, 'user-123');
      expect(testUser.email, 'test@example.com');
      expect(testUser.name, 'Juan Pérez');
    });

    test('fromJson crea usuario correctamente', () {
      final user = User.fromJson(validJson);

      expect(user.id, validJson['id']);
      expect(user.email, validJson['email']);
      expect(user.name, validJson['name']);
    });

    test('fromJson maneja _id como alternativa', () {
      final jsonWithUnderscore = {
        '_id': 'mongo-user-123',
        'email': 'mongo@test.com',
        'name': 'Usuario MongoDB',
      };

      final user = User.fromJson(jsonWithUnderscore);

      expect(user.id, 'mongo-user-123');
      expect(user.email, 'mongo@test.com');
      expect(user.name, 'Usuario MongoDB');
    });

    test('fromJson usa valores por defecto para campos vacíos', () {
      final emptyJson = <String, dynamic>{};

      final user = User.fromJson(emptyJson);

      expect(user.id, '');
      expect(user.email, '');
      expect(user.name, '');
    });

    test('toJson convierte usuario a mapa correctamente', () {
      final json = testUser.toJson();

      expect(json['id'], testUser.id);
      expect(json['email'], testUser.email);
      expect(json['name'], testUser.name);
    });

    test('copyWith crea nueva instancia con valores actualizados', () {
      final updatedUser = testUser.copyWith(
        name: 'Juan Carlos Pérez',
      );

      expect(updatedUser.id, testUser.id);
      expect(updatedUser.email, testUser.email);
      expect(updatedUser.name, 'Juan Carlos Pérez');
    });

    test('copyWith sin parámetros retorna usuario idéntico', () {
      final copiedUser = testUser.copyWith();

      expect(copiedUser.id, testUser.id);
      expect(copiedUser.email, testUser.email);
      expect(copiedUser.name, testUser.name);
    });

    test('copyWith puede actualizar email', () {
      final updatedUser = testUser.copyWith(
        email: 'nuevo-email@test.com',
      );

      expect(updatedUser.id, testUser.id);
      expect(updatedUser.email, 'nuevo-email@test.com');
      expect(updatedUser.name, testUser.name);
    });

    test('fromJson y toJson son operaciones inversas', () {
      final json = testUser.toJson();
      final recreatedUser = User.fromJson(json);

      expect(recreatedUser.id, testUser.id);
      expect(recreatedUser.email, testUser.email);
      expect(recreatedUser.name, testUser.name);
    });

    test('Manejar emails en diferentes formatos', () {
      final emails = [
        'simple@example.com',
        'usuario.con.puntos@dominio.com.mx',
        'MAYUSCULAS@TEST.COM',
        'numeros123@test456.com',
      ];

      for (final email in emails) {
        final user = User(
          id: 'test-id',
          email: email,
          name: 'Test User',
        );

        expect(user.email, email);
        
        final json = user.toJson();
        final recreated = User.fromJson(json);
        expect(recreated.email, email);
      }
    });

    test('Manejar nombres con caracteres especiales', () {
      final nombres = [
        'José María',
        'María de los Ángeles',
        'Óscar Ramírez',
        'François Müller',
      ];

      for (final nombre in nombres) {
        final user = User(
          id: 'test-id',
          email: 'test@example.com',
          name: nombre,
        );

        expect(user.name, nombre);
        
        final json = user.toJson();
        final recreated = User.fromJson(json);
        expect(recreated.name, nombre);
      }
    });
  });
}
