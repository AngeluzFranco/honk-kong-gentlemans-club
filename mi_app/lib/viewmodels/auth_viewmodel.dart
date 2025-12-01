import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/user_model.dart';
import '../services/firebase_auth_service.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  FirebaseAuthService? _firebaseAuthService;
  AuthService? _demoAuthService;
  
  // Lazy initialization de servicios
  FirebaseAuthService? get _firebaseService {
    try {
      if (_firebaseAuthService == null && Firebase.apps.isNotEmpty) {
        _firebaseAuthService = FirebaseAuthService();
      }
      return _firebaseAuthService;
    } catch (e) {
      return null;
    }
  }
  
  AuthService get _demoService {
    _demoAuthService ??= AuthService();
    return _demoAuthService!;
  }
  
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
      final dynamic service = _firebaseService ?? _demoService;
      _isLoggedIn = await service.isLoggedIn();
      
      if (_isLoggedIn) {
        _currentUser = await service.getCurrentUser();
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

    final dynamic service = _firebaseService ?? _demoService;
    final result = await service.login(email, password);
    
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
    String? phoneNumber,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    final dynamic service = _firebaseService ?? _demoService;
    final result = await service.register(
      email: email,
      password: password,
      name: name,
      phoneNumber: phoneNumber,
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
    
    final dynamic service = _firebaseService ?? _demoService;
    await service.logout();
    
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
    if (_firebaseService != null) {
      await _firebaseService!.updateFcmToken(token);
    }
  }
}
