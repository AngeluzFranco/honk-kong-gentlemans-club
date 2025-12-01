import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  
  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      // ⚠️ MODO DEMO: Usuario de prueba sin backend
      // Credenciales: demo@test.com / 123456
      if (email == 'demo@test.com' && password == '123456') {
        final demoUser = User(
          id: 'demo-123',
          email: email,
          name: 'Usuario Demo',
          phoneNumber: '+52 123 456 7890',
          avatarUrl: null,
        );
        
        await _saveAuthData(
          token: 'demo-token-12345',
          user: demoUser,
          refreshToken: 'demo-refresh-token',
        );
        
        return {
          'success': true,
          'user': demoUser,
          'message': 'Login exitoso (Modo Demo)',
        };
      }
      
      // Intentar login real con backend
      final response = await _apiService.post(
        ApiConfig.login,
        data: {
          'email': email,
          'password': password,
        },
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        
        // Guardar token y usuario
        await _saveAuthData(
          token: data['token'],
          user: User.fromJson(data['user']),
          refreshToken: data['refreshToken'],
        );
        
        return {
          'success': true,
          'user': User.fromJson(data['user']),
          'message': 'Login exitoso',
        };
      }
      
      return {
        'success': false,
        'message': 'Error en el login',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Backend no disponible. Usa: demo@test.com / 123456',
      };
    }
  }
  
  // Register
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
  }) async {
    // ⚠️ MODO DEMO: Simular registro exitoso sin backend
    try {
      final newUser = User(
        id: 'user-${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        name: name,
        phoneNumber: phoneNumber ?? '',
        avatarUrl: null,
      );
      
      await _saveAuthData(
        token: 'demo-token-${DateTime.now().millisecondsSinceEpoch}',
        user: newUser,
        refreshToken: 'demo-refresh-token',
      );
      
      return {
        'success': true,
        'user': newUser,
        'message': 'Registro exitoso (Modo Demo)',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error al registrar: ${e.toString()}',
      };
    }
  }
  
  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(ApiConfig.tokenKey);
    await prefs.remove(ApiConfig.userKey);
    await prefs.remove('refresh_token');
  }
  
  // Verificar si hay sesión activa
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(ApiConfig.tokenKey);
    return token != null;
  }
  
  // Obtener usuario actual
  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(ApiConfig.userKey);
      
      if (userJson != null) {
        return User.fromJson(jsonDecode(userJson));
      }
      
      return null;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }
  
  // Guardar datos de autenticación
  Future<void> _saveAuthData({
    required String token,
    required User user,
    String? refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(ApiConfig.tokenKey, token);
    await prefs.setString(ApiConfig.userKey, jsonEncode(user.toJson()));
    
    if (refreshToken != null) {
      await prefs.setString('refresh_token', refreshToken);
    }
  }
  
  // Actualizar token FCM
  Future<void> updateFcmToken(String fcmToken) async {
    try {
      await _apiService.post(
        '/auth/fcm-token',
        data: {'fcmToken': fcmToken},
      );
    } catch (e) {
      print('Error updating FCM token: $e');
    }
  }
}
