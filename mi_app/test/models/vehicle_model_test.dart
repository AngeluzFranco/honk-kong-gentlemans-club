import 'package:flutter_test/flutter_test.dart';
import 'package:mi_app/models/vehicle_model.dart';

void main() {
  group('Vehicle Model Tests', () {
    late Map<String, dynamic> validJson;
    late Vehicle testVehicle;

    setUp(() {
      validJson = {
        'id': 'test-123',
        'userId': 'user-456',
        'brand': 'BMW',
        'model': 'X5',
        'year': 2023,
        'licensePlate': 'ABC-123',
        'color': 'Negro',
        'vin': 'WBAXG5C53DDY36197',
        'mileage': 15000,
        'imageUrl': 'https://example.com/image.jpg',
        'latitude': 19.432608,
        'longitude': -99.133209,
        'lastServiceDate': '2024-01-15T10:30:00.000Z',
        'notes': 'Vehículo en excelente estado',
        'createdAt': '2023-06-01T08:00:00.000Z',
        'updatedAt': '2024-01-15T10:30:00.000Z',
      };

      testVehicle = Vehicle(
        id: 'test-123',
        userId: 'user-456',
        brand: 'BMW',
        model: 'X5',
        year: 2023,
        licensePlate: 'ABC-123',
        color: 'Negro',
        vin: 'WBAXG5C53DDY36197',
        mileage: 15000,
        imageUrl: 'https://example.com/image.jpg',
        latitude: 19.432608,
        longitude: -99.133209,
        lastServiceDate: '2024-01-15T10:30:00.000Z',
        notes: 'Vehículo en excelente estado',
        createdAt: DateTime.parse('2023-06-01T08:00:00.000Z'),
        updatedAt: DateTime.parse('2024-01-15T10:30:00.000Z'),
      );
    });

    test('Crear vehículo con todos los campos requeridos', () {
      final vehicle = Vehicle(
        id: 'test-123',
        userId: 'user-456',
        brand: 'BMW',
        model: 'X5',
        year: 2023,
        licensePlate: 'ABC-123',
        color: 'Negro',
      );

      expect(vehicle.id, 'test-123');
      expect(vehicle.userId, 'user-456');
      expect(vehicle.brand, 'BMW');
      expect(vehicle.model, 'X5');
      expect(vehicle.year, 2023);
      expect(vehicle.licensePlate, 'ABC-123');
      expect(vehicle.color, 'Negro');
      expect(vehicle.vin, isNull);
      expect(vehicle.mileage, isNull);
      expect(vehicle.imageUrl, isNull);
    });

    test('Crear vehículo con todos los campos opcionales', () {
      expect(testVehicle.id, 'test-123');
      expect(testVehicle.userId, 'user-456');
      expect(testVehicle.brand, 'BMW');
      expect(testVehicle.model, 'X5');
      expect(testVehicle.year, 2023);
      expect(testVehicle.licensePlate, 'ABC-123');
      expect(testVehicle.color, 'Negro');
      expect(testVehicle.vin, 'WBAXG5C53DDY36197');
      expect(testVehicle.mileage, 15000);
      expect(testVehicle.imageUrl, 'https://example.com/image.jpg');
      expect(testVehicle.latitude, 19.432608);
      expect(testVehicle.longitude, -99.133209);
      expect(testVehicle.notes, 'Vehículo en excelente estado');
    });

    test('fromJson crea vehículo correctamente', () {
      final vehicle = Vehicle.fromJson(validJson);

      expect(vehicle.id, validJson['id']);
      expect(vehicle.userId, validJson['userId']);
      expect(vehicle.brand, validJson['brand']);
      expect(vehicle.model, validJson['model']);
      expect(vehicle.year, validJson['year']);
      expect(vehicle.licensePlate, validJson['licensePlate']);
      expect(vehicle.color, validJson['color']);
      expect(vehicle.vin, validJson['vin']);
      expect(vehicle.mileage, validJson['mileage']);
      expect(vehicle.imageUrl, validJson['imageUrl']);
      expect(vehicle.latitude, validJson['latitude']);
      expect(vehicle.longitude, validJson['longitude']);
      expect(vehicle.notes, validJson['notes']);
    });

    test('fromJson maneja campos nulos correctamente', () {
      final minimalJson = {
        'id': 'test-123',
        'userId': 'user-456',
        'brand': 'Toyota',
        'model': 'Corolla',
        'year': 2020,
        'licensePlate': 'XYZ-789',
        'color': 'Blanco',
      };

      final vehicle = Vehicle.fromJson(minimalJson);

      expect(vehicle.id, 'test-123');
      expect(vehicle.userId, 'user-456');
      expect(vehicle.brand, 'Toyota');
      expect(vehicle.model, 'Corolla');
      expect(vehicle.year, 2020);
      expect(vehicle.licensePlate, 'XYZ-789');
      expect(vehicle.color, 'Blanco');
      expect(vehicle.vin, isNull);
      expect(vehicle.mileage, isNull);
      expect(vehicle.imageUrl, isNull);
      expect(vehicle.latitude, isNull);
      expect(vehicle.longitude, isNull);
      expect(vehicle.notes, isNull);
    });

    test('fromJson maneja _id como alternativa a id', () {
      final jsonWithUnderscore = {
        '_id': 'mongo-id-123',
        'userId': 'user-456',
        'brand': 'Honda',
        'model': 'Civic',
        'year': 2021,
        'licensePlate': 'DEF-456',
        'color': 'Rojo',
      };

      final vehicle = Vehicle.fromJson(jsonWithUnderscore);

      expect(vehicle.id, 'mongo-id-123');
    });

    test('toJson convierte vehículo a mapa correctamente', () {
      final json = testVehicle.toJson();

      expect(json['id'], testVehicle.id);
      expect(json['userId'], testVehicle.userId);
      expect(json['brand'], testVehicle.brand);
      expect(json['model'], testVehicle.model);
      expect(json['year'], testVehicle.year);
      expect(json['licensePlate'], testVehicle.licensePlate);
      expect(json['color'], testVehicle.color);
      expect(json['vin'], testVehicle.vin);
      expect(json['mileage'], testVehicle.mileage);
      expect(json['imageUrl'], testVehicle.imageUrl);
      expect(json['latitude'], testVehicle.latitude);
      expect(json['longitude'], testVehicle.longitude);
      expect(json['notes'], testVehicle.notes);
    });

    test('toJson no incluye campos opcionales nulos', () {
      final vehicle = Vehicle(
        id: 'test-123',
        userId: 'user-456',
        brand: 'Ford',
        model: 'Focus',
        year: 2019,
        licensePlate: 'GHI-789',
        color: 'Azul',
      );

      final json = vehicle.toJson();

      expect(json.containsKey('color'), true);
      expect(json['color'], 'Azul');
      expect(json.containsKey('vin'), false);
      expect(json.containsKey('imageUrl'), false);
    });

    test('copyWith crea nueva instancia con valores actualizados', () {
      final updatedVehicle = testVehicle.copyWith(
        brand: 'Audi',
        model: 'A4',
        mileage: 20000,
      );

      expect(updatedVehicle.id, testVehicle.id);
      expect(updatedVehicle.userId, testVehicle.userId);
      expect(updatedVehicle.brand, 'Audi');
      expect(updatedVehicle.model, 'A4');
      expect(updatedVehicle.year, testVehicle.year);
      expect(updatedVehicle.licensePlate, testVehicle.licensePlate);
      expect(updatedVehicle.mileage, 20000);
      expect(updatedVehicle.color, testVehicle.color);
    });

    test('copyWith sin parámetros retorna vehículo idéntico', () {
      final copiedVehicle = testVehicle.copyWith();

      expect(copiedVehicle.id, testVehicle.id);
      expect(copiedVehicle.userId, testVehicle.userId);
      expect(copiedVehicle.brand, testVehicle.brand);
      expect(copiedVehicle.model, testVehicle.model);
      expect(copiedVehicle.year, testVehicle.year);
      expect(copiedVehicle.licensePlate, testVehicle.licensePlate);
      expect(copiedVehicle.color, testVehicle.color);
      expect(copiedVehicle.vin, testVehicle.vin);
      expect(copiedVehicle.mileage, testVehicle.mileage);
    });

    test('copyWith puede actualizar coordenadas GPS', () {
      final updatedVehicle = testVehicle.copyWith(
        latitude: 20.123456,
        longitude: -100.987654,
      );

      expect(updatedVehicle.latitude, 20.123456);
      expect(updatedVehicle.longitude, -100.987654);
      expect(updatedVehicle.brand, testVehicle.brand);
    });

    test('fromJson y toJson son operaciones inversas', () {
      final json = testVehicle.toJson();
      final recreatedVehicle = Vehicle.fromJson(json);

      expect(recreatedVehicle.id, testVehicle.id);
      expect(recreatedVehicle.userId, testVehicle.userId);
      expect(recreatedVehicle.brand, testVehicle.brand);
      expect(recreatedVehicle.model, testVehicle.model);
      expect(recreatedVehicle.year, testVehicle.year);
      expect(recreatedVehicle.licensePlate, testVehicle.licensePlate);
      expect(recreatedVehicle.color, testVehicle.color);
      expect(recreatedVehicle.vin, testVehicle.vin);
      expect(recreatedVehicle.mileage, testVehicle.mileage);
    });

    test('Manejar fechas correctamente en fromJson', () {
      final vehicle = Vehicle.fromJson(validJson);

      expect(vehicle.lastServiceDate, isA<String>());
      expect(vehicle.createdAt, isA<DateTime>());
      expect(vehicle.updatedAt, isA<DateTime>());
      expect(vehicle.lastServiceDate, '2024-01-15T10:30:00.000Z');
      expect(vehicle.createdAt.year, 2023);
      expect(vehicle.createdAt.month, 6);
    });

    test('Manejar fechas nulas en fromJson', () {
      final jsonWithoutDates = {
        'id': 'test-123',
        'userId': 'user-456',
        'brand': 'Nissan',
        'model': 'Altima',
        'year': 2022,
        'licensePlate': 'JKL-012',
        'color': 'Gris',
      };

      final vehicle = Vehicle.fromJson(jsonWithoutDates);

      expect(vehicle.lastServiceDate, isNull);
      expect(vehicle.createdAt, isA<DateTime>());
      expect(vehicle.updatedAt, isA<DateTime>());
    });
  });
}
