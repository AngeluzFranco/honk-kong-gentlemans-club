import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../config/api_config.dart';

class FirebaseAuthService {
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    firebase_auth.UserCredential? credential;
    String? userId;
    
    try {
      credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      userId = credential.user?.uid;
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('FirebaseAuthException en login: ${e.code} - ${e.message}');
      String message = 'Error de conexión. Por favor, intenta de nuevo.';
      
      switch (e.code) {
        case 'user-not-found':
          message = 'Usuario no encontrado';
          break;
        case 'wrong-password':
          message = 'Contraseña incorrecta';
          break;
        case 'invalid-email':
          message = 'Email inválido';
          break;
        case 'user-disabled':
          message = 'Usuario deshabilitado';
          break;
        case 'too-many-requests':
          message = 'Demasiados intentos. Intenta más tarde';
          break;
        case 'invalid-credential':
          message = 'Email o contraseña incorrectos';
          break;
        case 'network-request-failed':
          message = 'Error de conexión. Por favor, intenta de nuevo.';
          break;
        default:
          message = 'Error de conexión. Por favor, intenta de nuevo.';
      }
      
      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      print('Error al iniciar sesión: $e');
      // El usuario podría haber iniciado sesión aunque haya error
      userId = _firebaseAuth.currentUser?.uid;
    }
    
    // Si tenemos userId, el login fue exitoso
    if (userId != null && userId.isNotEmpty) {
      try {
        String userName = 'Usuario';
        
        // Intentar obtener datos del usuario desde Firestore
        try {
          final userDoc = await _firestore
              .collection('users')
              .doc(userId)
              .get();
          
          if (userDoc.exists) {
            final userData = userDoc.data() ?? {};
            userName = userData['name'] ?? 'Usuario';
            print('Datos de Firestore obtenidos: $userName');
          }
        } catch (e) {
          print('No se pudo obtener datos de Firestore: $e');
        }
        
        final user = User(
          id: userId,
          email: email,
          name: userName,
        );
        
        // Guardar localmente
        await _saveUserLocally(user);
        
        return {
          'success': true,
          'user': user,
          'message': 'Sesión iniciada correctamente',
        };
      } catch (e) {
        print('Error al procesar login: $e');
        return {
          'success': false,
          'message': 'Error de conexión. Por favor, intenta de nuevo.',
        };
      }
    }
    
    return {
      'success': false,
      'message': 'Error de conexión. Por favor, intenta de nuevo.',
    };
  }
  
  // Register
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    firebase_auth.UserCredential? credential;
    String? userId;
    
    try {
      credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      userId = credential.user?.uid;
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('FirebaseAuthException en register: ${e.code} - ${e.message}');
      String message = 'Error de conexión. Por favor, intenta de nuevo.';
      
      switch (e.code) {
        case 'email-already-in-use':
          message = 'Este email ya está registrado';
          break;
        case 'invalid-email':
          message = 'Email inválido';
          break;
        case 'weak-password':
          message = 'La contraseña es muy débil (mínimo 6 caracteres)';
          break;
        case 'operation-not-allowed':
          message = 'Registro con email/password no habilitado';
          break;
        case 'network-request-failed':
          message = 'Error de conexión. Por favor, intenta de nuevo.';
          break;
        default:
          message = 'Error de conexión. Por favor, intenta de nuevo.';
      }
      
      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      print('Error al crear usuario: $e');
      // El usuario podría haberse creado aunque haya error
      userId = _firebaseAuth.currentUser?.uid;
    }
    
    // Si tenemos userId, el usuario se creó exitosamente
    if (userId != null && userId.isNotEmpty) {
      try {
        final user = User(
          id: userId,
          email: email,
          name: name,
        );
        
        // Guardar localmente primero
        await _saveUserLocally(user);
        
        // Intentar guardar datos adicionales en Firestore (opcional)
        _firestore.collection('users').doc(userId).set({
          'name': name,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }).catchError((e) {
          print('No se pudo guardar en Firestore: $e');
        });
        
        return {
          'success': true,
          'user': user,
          'message': 'Usuario registrado exitosamente',
        };
      } catch (e) {
        print('Error al procesar usuario: $e');
        return {
          'success': false,
          'message': 'Error de conexión. Por favor, intenta de nuevo.',
        };
      }
    }
    
    return {
      'success': false,
      'message': 'Error de conexión. Por favor, intenta de nuevo.',
    };
  }
  
  // Logout
  Future<void> logout() async {
    await _firebaseAuth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(ApiConfig.userKey);
    await prefs.remove(ApiConfig.fcmTokenKey);
  }
  
  // Verificar si está logueado
  Future<bool> isLoggedIn() async {
    return _firebaseAuth.currentUser != null;
  }
  
  // Obtener usuario actual
  Future<User?> getCurrentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;
    
    // Intentar obtener de local primero
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(ApiConfig.userKey);
    
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    
    // Si no hay local, obtener de Firestore
    final userDoc = await _firestore
        .collection('users')
        .doc(firebaseUser.uid)
        .get();
    
    if (userDoc.exists) {
      final userData = userDoc.data()!;
      final user = User(
        id: firebaseUser.uid,
        email: firebaseUser.email!,
        name: userData['name'] ?? 'Usuario',
      );
      await _saveUserLocally(user);
      return user;
    }
    
    return null;
  }
  
  // Actualizar FCM Token
  Future<void> updateFcmToken(String token) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;
    
    try {
      await _firestore.collection('users').doc(user.uid).update({
        'fcmToken': token,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(ApiConfig.fcmTokenKey, token);
    } catch (e) {
      print('Error al actualizar FCM token: $e');
    }
  }
  
  // Guardar usuario localmente
  Future<void> _saveUserLocally(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(ApiConfig.userKey, jsonEncode(user.toJson()));
  }
}
