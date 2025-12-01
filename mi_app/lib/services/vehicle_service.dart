import '../config/api_config.dart';
import '../models/vehicle_model.dart';
import 'api_service.dart';

class VehicleService {
  final ApiService _apiService = ApiService();
  
  // ⚠️ MODO DEMO: Almacenamiento local temporal
  static final List<Vehicle> _demoVehicles = [
    Vehicle(
      id: 'demo-1',
      userId: 'demo-123',
      brand: 'Toyota',
      model: 'Corolla',
      year: 2020,
      licensePlate: 'ABC-123',
      color: 'Blanco',
      vin: '1HGBH41JXMN109186',
      mileage: 45000.0,
      imageUrl: null,
      latitude: 19.4326,
      longitude: -99.1332,
      lastServiceDate: '2024-10-25',
      notes: 'Vehículo en excelente estado',
      createdAt: DateTime.now().subtract(const Duration(days: 180)),
      updatedAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    Vehicle(
      id: 'demo-2',
      userId: 'demo-123',
      brand: 'Honda',
      model: 'Civic',
      year: 2021,
      licensePlate: 'XYZ-789',
      color: 'Gris',
      vin: '2HGFC2F59MH123456',
      mileage: 28000.0,
      imageUrl: null,
      latitude: 19.4284,
      longitude: -99.1276,
      lastServiceDate: '2024-11-09',
      notes: 'Último servicio: Cambio de aceite',
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
      updatedAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
  ];
  
  // CREATE - Crear nuevo vehículo
  Future<Map<String, dynamic>> createVehicle(Vehicle vehicle) async {
    // ⚠️ MODO DEMO: Agregar a lista local
    try {
      await Future.delayed(const Duration(milliseconds: 300)); // Simular latencia
      
      final newVehicle = vehicle.copyWith(
        id: 'demo-${DateTime.now().millisecondsSinceEpoch}',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      _demoVehicles.add(newVehicle);
      
      return {
        'success': true,
        'vehicle': newVehicle,
        'message': 'Vehículo creado (Modo Demo)',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error al crear vehículo: ${e.toString()}',
      };
    }
  }
  
  // READ - Obtener todos los vehículos del usuario
  Future<Map<String, dynamic>> getVehicles() async {
    try {
      // ⚠️ MODO DEMO: Retornar vehículos de prueba
      await Future.delayed(const Duration(milliseconds: 500)); // Simular latencia
      return {
        'success': true,
        'vehicles': _demoVehicles,
        'message': 'Vehículos obtenidos (Modo Demo)',
      };
      
      // Código real comentado para cuando tengas backend
      /*
      final response = await _apiService.get(ApiConfig.vehicles);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is List 
            ? response.data 
            : response.data['vehicles'] ?? [];
        
        final vehicles = data.map((json) => Vehicle.fromJson(json)).toList();
        
        return {
          'success': true,
          'vehicles': vehicles,
        };
      }
      
      return {
        'success': false,
        'message': 'Error al obtener vehículos',
        'vehicles': <Vehicle>[],
      };
      */
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
        'vehicles': <Vehicle>[],
      };
    }
  }
  
  // READ - Obtener un vehículo específico
  Future<Map<String, dynamic>> getVehicleById(String id) async {
    // ⚠️ MODO DEMO: Buscar en lista local
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      
      final vehicle = _demoVehicles.firstWhere(
        (v) => v.id == id,
        orElse: () => throw Exception('Vehículo no encontrado'),
      );
      
      return {
        'success': true,
        'vehicle': vehicle,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Vehículo no encontrado',
      };
    }
  }
  
  // UPDATE - Actualizar vehículo
  Future<Map<String, dynamic>> updateVehicle(String id, Vehicle vehicle) async {
    // ⚠️ MODO DEMO: Actualizar en lista local
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      
      final index = _demoVehicles.indexWhere((v) => v.id == id);
      if (index == -1) {
        return {
          'success': false,
          'message': 'Vehículo no encontrado',
        };
      }
      
      final updatedVehicle = vehicle.copyWith(
        id: id,
        updatedAt: DateTime.now(),
      );
      
      _demoVehicles[index] = updatedVehicle;
      
      return {
        'success': true,
        'vehicle': updatedVehicle,
        'message': 'Vehículo actualizado (Modo Demo)',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error al actualizar: ${e.toString()}',
      };
    }
  }
  
  // DELETE - Eliminar vehículo
  Future<Map<String, dynamic>> deleteVehicle(String id) async {
    // ⚠️ MODO DEMO: Eliminar de lista local
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      
      final initialLength = _demoVehicles.length;
      _demoVehicles.removeWhere((v) => v.id == id);
      final removed = _demoVehicles.length < initialLength;
      
      if (removed) {
        return {
          'success': true,
          'message': 'Vehículo eliminado (Modo Demo)',
        };
      }
      
      return {
        'success': false,
        'message': 'Error al eliminar vehículo',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
  
  // Subir imagen del vehículo
  Future<Map<String, dynamic>> uploadVehicleImage(String vehicleId, String imagePath) async {
    // ⚠️ MODO DEMO: Simular subida exitosa (sin imagen real)
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      return {
        'success': true,
        'imageUrl': 'https://via.placeholder.com/400x300.png?text=Demo+Vehicle',
        'message': 'Imagen simulada (Modo Demo)',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
}
