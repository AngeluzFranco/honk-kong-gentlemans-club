import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/vehicle_model.dart';
import '../config/api_config.dart';

class AWSVehicleService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: ApiConfig.connectTimeout,
    receiveTimeout: ApiConfig.receiveTimeout,
    sendTimeout: ApiConfig.sendTimeout,
  ));

  AWSVehicleService() {
    // Interceptor para agregar el token de Firebase Auth en cada petición
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          final user = firebase_auth.FirebaseAuth.instance.currentUser;
          if (user != null) {
            final token = await user.getIdToken();
            options.headers['Authorization'] = 'Bearer $token';
          }
        } catch (e) {
          print('Error obteniendo token: $e');
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        print('Error HTTP: ${error.message}');
        return handler.next(error);
      },
    ));
  }

  /// Crear un nuevo vehículo
  Future<Vehicle> createVehicle(Vehicle vehicle) async {
    try {
      print('📤 Enviando vehículo a AWS: ${vehicle.toJson()}');
      
      final response = await _dio.post(
        ApiConfig.vehicles,
        data: vehicle.toJson(),
      );

      print('📥 Respuesta de AWS - Status: ${response.statusCode}');
      print('📥 Respuesta de AWS - Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        dynamic responseData = response.data;
        
        // Si AWS devuelve un objeto con statusCode, headers y body (Lambda Response Format)
        if (responseData is Map<String, dynamic> && responseData.containsKey('statusCode')) {
          final lambdaStatusCode = responseData['statusCode'];
          final lambdaBody = responseData['body'];
          
          print('📦 Lambda StatusCode: $lambdaStatusCode');
          print('📦 Lambda Body: $lambdaBody');
          
          if (lambdaStatusCode == 200 || lambdaStatusCode == 201) {
            // Parsear el body que viene como string JSON
            if (lambdaBody is String) {
              final vehicleData = jsonDecode(lambdaBody);
              return Vehicle.fromJson(vehicleData);
            } else if (lambdaBody is Map<String, dynamic>) {
              return Vehicle.fromJson(lambdaBody);
            }
          } else {
            throw Exception('Error Lambda: ${lambdaBody}');
          }
        }
        
        // Si AWS devuelve el vehículo directamente
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('vehicle')) {
            return Vehicle.fromJson(responseData['vehicle']);
          }
          return Vehicle.fromJson(responseData);
        }
        
        throw Exception('Formato de respuesta inesperado: $responseData');
      } else {
        throw Exception('Error al crear vehículo: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ DioException en createVehicle: ${e.message}');
      print('❌ Response: ${e.response?.data}');
      throw Exception('Error de conexión. Por favor, intenta de nuevo.');
    } catch (e) {
      print('❌ Error en createVehicle: $e');
      throw Exception('Error de conexión. Por favor, intenta de nuevo.');
    }
  }

  /// Obtener todos los vehículos del usuario actual
  Future<List<Vehicle>> getVehicles() async {
    try {
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      print('🔍 Obteniendo vehículos para userId: ${user.uid}');

      // Intentar primero con GET usando queryParams
      Response response;
      try {
        response = await _dio.get(
          ApiConfig.vehicles,
          queryParameters: {'userId': user.uid},
        );
      } catch (e) {
        // Si GET falla, intentar con el header como alternativa
        print('⚠️ GET falló, intentando alternativa...');
        response = await _dio.get(
          ApiConfig.vehicles,
          options: Options(
            headers: {'X-User-Id': user.uid},
          ),
        );
      }

      print('📥 Respuesta getVehicles - Status: ${response.statusCode}');
      print('📥 Respuesta getVehicles - Data: ${response.data}');

      if (response.statusCode == 200) {
        dynamic responseData = response.data;
        
        // Si AWS devuelve un objeto con statusCode, headers y body (Lambda Response Format)
        if (responseData is Map<String, dynamic> && responseData.containsKey('statusCode')) {
          final lambdaStatusCode = responseData['statusCode'];
          final lambdaBody = responseData['body'];
          
          print('📦 Lambda StatusCode: $lambdaStatusCode');
          print('📦 Lambda Body: $lambdaBody');
          
          if (lambdaStatusCode == 200) {
            // Parsear el body que viene como string JSON
            Map<String, dynamic> bodyData;
            if (lambdaBody is String) {
              bodyData = jsonDecode(lambdaBody);
            } else if (lambdaBody is Map<String, dynamic>) {
              bodyData = lambdaBody;
            } else {
              print('⚠️ Body en formato inesperado');
              return [];
            }
            
            print('📦 Body parseado: $bodyData');
            
            // Extraer el array de vehículos
            if (bodyData.containsKey('vehicles')) {
              final List<dynamic> vehicles = bodyData['vehicles'];
              print('✅ Encontrados ${vehicles.length} vehículos');
              return vehicles.map((json) => Vehicle.fromJson(json)).toList();
            }
          } else {
            print('❌ Error Lambda: ${lambdaBody}');
            return [];
          }
        }
        
        // Si la respuesta es directa (sin Lambda wrapper)
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('vehicles')) {
            final List<dynamic> vehicles = responseData['vehicles'];
            return vehicles.map((json) => Vehicle.fromJson(json)).toList();
          } else {
            return [Vehicle.fromJson(responseData)];
          }
        } else if (responseData is List) {
          return responseData.map((json) => Vehicle.fromJson(json)).toList();
        }
        
        // Si no hay datos, devolver lista vacía
        print('⚠️ No se encontraron vehículos');
        return [];
      } else {
        throw Exception('Error al obtener vehículos: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ DioException en getVehicles: ${e.message}');
      throw Exception('Error de conexión. Por favor, intenta de nuevo.');
    } catch (e) {
      print('❌ Error en getVehicles: $e');
      throw Exception('Error de conexión. Por favor, intenta de nuevo.');
    }
  }

  /// Obtener un vehículo específico por ID
  Future<Vehicle?> getVehicleById(String vehicleId) async {
    try {
      final response = await _dio.get('${ApiConfig.vehicles}/$vehicleId');

      if (response.statusCode == 200) {
        return Vehicle.fromJson(response.data);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Error al obtener vehículo: ${response.statusCode}');
      }
    } on DioException {
      throw Exception('Error de conexión. Por favor, intenta de nuevo.');
    }
  }

  /// Actualizar un vehículo existente
  Future<Vehicle> updateVehicle(Vehicle vehicle) async {
    try {
      print('📤 Actualizando vehículo: ${vehicle.id}');
      print('📤 Datos enviados: ${vehicle.toJson()}');
      
      final response = await _dio.put(
        '${ApiConfig.vehicles}/${vehicle.id}',
        data: vehicle.toJson(),
      );

      print('📥 Respuesta updateVehicle - Status: ${response.statusCode}');
      print('📥 Respuesta updateVehicle - Data: ${response.data}');

      if (response.statusCode == 200) {
        dynamic responseData = response.data;
        
        // Si AWS devuelve un objeto con statusCode, headers y body (Lambda Response Format)
        if (responseData is Map<String, dynamic> && responseData.containsKey('statusCode')) {
          final lambdaStatusCode = responseData['statusCode'];
          final lambdaBody = responseData['body'];
          
          print('📦 Lambda StatusCode: $lambdaStatusCode');
          print('📦 Lambda Body: $lambdaBody');
          
          if (lambdaStatusCode != 200) {
            String errorMessage = 'Error al actualizar vehículo';
            if (lambdaBody is String) {
              try {
                final bodyData = jsonDecode(lambdaBody);
                errorMessage = bodyData['error'] ?? errorMessage;
              } catch (e) {
                errorMessage = lambdaBody;
              }
            }
            throw Exception(errorMessage);
          }
          
          // Parsear el vehículo actualizado del body
          Map<String, dynamic> vehicleData;
          if (lambdaBody is String) {
            vehicleData = jsonDecode(lambdaBody);
          } else if (lambdaBody is Map<String, dynamic>) {
            vehicleData = lambdaBody;
          } else {
            // Si no hay datos, devolver el vehículo original
            print('⚠️ No se recibieron datos actualizados, usando datos enviados');
            return vehicle;
          }
          
          print('📦 Vehículo actualizado parseado: $vehicleData');
          print('✅ Vehículo actualizado exitosamente');
          return Vehicle.fromJson(vehicleData);
        } else if (responseData is Map<String, dynamic>) {
          // Respuesta directa sin wrapper
          print('✅ Vehículo actualizado exitosamente (respuesta directa)');
          return Vehicle.fromJson(responseData);
        } else {
          // Si no hay datos válidos, devolver el vehículo original
          print('⚠️ Respuesta en formato inesperado, usando datos enviados');
          return vehicle;
        }
      } else {
        throw Exception('Error al actualizar vehículo: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ DioException en updateVehicle: ${e.message}');
      throw Exception('Error de conexión. Por favor, intenta de nuevo.');
    } catch (e) {
      print('❌ Error en updateVehicle: $e');
      rethrow;
    }
  }

  /// Eliminar un vehículo
  Future<void> deleteVehicle(String vehicleId) async {
    try {
      print('🗑️ Eliminando vehículo: $vehicleId');
      
      // Enviar el ID también en el body como fallback por si API Gateway no pasa pathParameters
      final response = await _dio.delete(
        '${ApiConfig.vehicles}/$vehicleId',
        data: {'id': vehicleId},
      );

      print('📥 Respuesta deleteVehicle - Status: ${response.statusCode}');
      print('📥 Respuesta deleteVehicle - Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        dynamic responseData = response.data;
        
        // Si AWS devuelve un objeto con statusCode, headers y body (Lambda Response Format)
        if (responseData is Map<String, dynamic> && responseData.containsKey('statusCode')) {
          final lambdaStatusCode = responseData['statusCode'];
          final lambdaBody = responseData['body'];
          
          print('📦 Lambda StatusCode: $lambdaStatusCode');
          print('📦 Lambda Body: $lambdaBody');
          
          if (lambdaStatusCode != 200 && lambdaStatusCode != 204) {
            String errorMessage = 'Error al eliminar vehículo';
            if (lambdaBody is String) {
              try {
                final bodyData = jsonDecode(lambdaBody);
                errorMessage = bodyData['error'] ?? errorMessage;
              } catch (e) {
                errorMessage = lambdaBody;
              }
            }
            throw Exception(errorMessage);
          }
          
          print('✅ Vehículo eliminado exitosamente');
        } else {
          // Respuesta directa sin wrapper
          print('✅ Vehículo eliminado exitosamente (respuesta directa)');
        }
      } else {
        throw Exception('Error al eliminar vehículo: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ DioException en deleteVehicle: ${e.message}');
      throw Exception('Error de conexión. Por favor, intenta de nuevo.');
    } catch (e) {
      print('❌ Error en deleteVehicle: $e');
      rethrow;
    }
  }

  /// Subir imagen de vehículo a S3 a través del backend
  Future<String?> uploadVehicleImage(File imageFile, String vehicleId) async {
    try {
      print('📸 Subiendo imagen: ${imageFile.path}');
      String fileName = imageFile.path.split('/').last;
      
      FormData formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
        'vehicleId': vehicleId,
      });

      print('📤 Enviando imagen a: ${ApiConfig.uploadImage}');
      final response = await _dio.post(
        ApiConfig.uploadImage,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );

      print('📥 Respuesta uploadImage - Status: ${response.statusCode}');
      print('📥 Respuesta uploadImage - Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        dynamic responseData = response.data;
        
        // Manejar formato Lambda wrapper si es necesario
        if (responseData is Map<String, dynamic> && responseData.containsKey('statusCode')) {
          final lambdaStatusCode = responseData['statusCode'];
          final lambdaBody = responseData['body'];
          
          if (lambdaStatusCode == 200 || lambdaStatusCode == 201) {
            Map<String, dynamic> bodyData;
            if (lambdaBody is String) {
              bodyData = jsonDecode(lambdaBody);
            } else {
              bodyData = lambdaBody;
            }
            
            final imageUrl = bodyData['imageUrl'] ?? bodyData['url'];
            print('✅ Imagen subida exitosamente: $imageUrl');
            return imageUrl;
          }
        } else if (responseData is Map<String, dynamic>) {
          final imageUrl = responseData['imageUrl'] ?? responseData['url'];
          print('✅ Imagen subida exitosamente: $imageUrl');
          return imageUrl;
        }
        
        throw Exception('Respuesta sin URL de imagen');
      } else {
        throw Exception('Error al subir imagen: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ DioException en uploadImage: ${e.message}');
      print('❌ Response: ${e.response?.data}');
      print('⚠️ Nota: El Lambda UploadImage puede no estar configurado');
      // No lanzar excepción, solo retornar null para que no falle el flujo
      return null;
    } catch (e) {
      print('❌ Error en uploadImage: $e');
      return null;
    }
  }
}
