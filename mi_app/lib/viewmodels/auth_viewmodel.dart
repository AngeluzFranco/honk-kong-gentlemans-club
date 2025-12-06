import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/firebase_auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();
  
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isLoggedIn = false;
  
  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _isLoggedIn;
  
  // Inicializar - verificar sesión existente
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _isLoggedIn = await _authService.isLoggedIn();
      
      if (_isLoggedIn) {
        _currentUser = await _authService.getCurrentUser();
      }
    } catch (e) {
      debugPrint('Error en init: $e');
      _isLoggedIn = false;
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  // Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.login(email, password);
    
    _isLoading = false;
    
    if (result['success']) {
      _currentUser = result['user'];
      _isLoggedIn = true;
      _errorMessage = null;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }
  
  // Register
  Future<bool> register({
    required String email,
    required String password,
    required String name,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    final result = await _authService.register(
      email: email,
      password: password,
      name: name,
    );
    
    _isLoading = false;
    
    if (result['success']) {
      _currentUser = result['user'];
      _isLoggedIn = true;
      _errorMessage = null;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }
  
  // Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    
    await _authService.logout();
    
    _currentUser = null;
    _isLoggedIn = false;
    _errorMessage = null;
    _isLoading = false;
    
    notifyListeners();
  }
  
  // Limpiar mensaje de error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  // Actualizar FCM token
  Future<void> updateFcmToken(String token) async {
    await _authService.updateFcmToken(token);
  }
}
