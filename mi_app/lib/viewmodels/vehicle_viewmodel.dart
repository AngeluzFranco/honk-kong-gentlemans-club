import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/vehicle_model.dart';
import '../services/aws_vehicle_service.dart';
import '../services/vehicle_service.dart';
import '../services/firebase_notification_service.dart';

class VehicleViewModel extends ChangeNotifier {
  AWSVehicleService? _awsVehicleService;
  VehicleService? _demoVehicleService;
  
  // Lazy initialization de servicios
  AWSVehicleService? get _awsService {
    try {
      if (_awsVehicleService == null && Firebase.apps.isNotEmpty) {
        _awsVehicleService = AWSVehicleService();
      }
      return _awsVehicleService;
    } catch (e) {
      return null;
    }
  }
  
  VehicleService get _demoService {
    _demoVehicleService ??= VehicleService();
    return _demoVehicleService!;
  }
  
  List<Vehicle> _vehicles = [];
  Vehicle? _selectedVehicle;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  
  // Getters
  List<Vehicle> get vehicles => _vehicles;
  Vehicle? get selectedVehicle => _selectedVehicle;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  
  // Cargar todos los vehículos
  Future<void> loadVehicles() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      if (_awsService != null) {
        // Usar servicio AWS
        _vehicles = await _awsService!.getVehicles();
        _errorMessage = null;
      } else {
        // Usar servicio demo
        final result = await _demoService.getVehicles();
        if (result['success']) {
          _vehicles = result['vehicles'];
          _errorMessage = null;
        } else {
          _errorMessage = result['message'];
          _vehicles = [];
        }
      }
    } catch (e) {
      _errorMessage = 'Error de conexión. Por favor, intenta de nuevo.';
      _vehicles = [];
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  // Cargar vehículo específico
  Future<bool> loadVehicle(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      if (_awsService != null) {
        _selectedVehicle = await _awsService!.getVehicleById(id);
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return _selectedVehicle != null;
      } else {
        final result = await _demoService.getVehicleById(id);
        _isLoading = false;
        if (result['success']) {
          _selectedVehicle = result['vehicle'];
          _errorMessage = null;
          notifyListeners();
          return true;
        } else {
          _errorMessage = result['message'];
          notifyListeners();
          return false;
        }
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error de conexión. Por favor, intenta de nuevo.';
      notifyListeners();
      return false;
    }
  }
  
  // Crear nuevo vehículo
  Future<Vehicle?> createVehicle(Vehicle vehicle) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
    
    try {
      if (_awsService != null) {
        final createdVehicle = await _awsService!.createVehicle(vehicle);
        _vehicles.add(createdVehicle);
        _selectedVehicle = createdVehicle; // Guardar como seleccionado
        _successMessage = 'Vehículo creado exitosamente';
        _errorMessage = null;
        _isLoading = false;
        
        // Enviar notificación push
        await _sendVehicleCreatedNotification(createdVehicle);
        
        notifyListeners();
        return createdVehicle;
      } else {
        final result = await _demoService.createVehicle(vehicle);
        _isLoading = false;
        if (result['success']) {
          final createdVehicle = result['vehicle'] as Vehicle;
          _vehicles.add(createdVehicle);
          _selectedVehicle = createdVehicle;
          _successMessage = result['message'];
          _errorMessage = null;
          
          // Enviar notificación push
          await _sendVehicleCreatedNotification(createdVehicle);
          
          notifyListeners();
          return createdVehicle;
        } else {
          _errorMessage = result['message'];
          notifyListeners();
          return null;
        }
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error de conexión. Por favor, intenta de nuevo.';
      notifyListeners();
      return null;
    }
  }

  // Método privado para enviar notificación de creación
  Future<void> _sendVehicleCreatedNotification(Vehicle vehicle) async {
    try {
      final notificationService = FirebaseNotificationService();
      await notificationService.sendVehicleCreatedNotification(
        brand: vehicle.brand,
        model: vehicle.model,
        year: vehicle.year.toString(),
        imageUrl: vehicle.imageUrl,
      );
    } catch (e) {
      print('⚠️ Error al enviar notificación: $e');
      // No propagar el error para no afectar la creación del vehículo
    }
  }

  // Método privado para enviar notificación de actualización
  Future<void> _sendVehicleUpdatedNotification(Vehicle vehicle) async {
    try {
      final notificationService = FirebaseNotificationService();
      await notificationService.sendVehicleUpdatedNotification(
        brand: vehicle.brand,
        model: vehicle.model,
        year: vehicle.year.toString(),
        imageUrl: vehicle.imageUrl,
      );
    } catch (e) {
      print('⚠️ Error al enviar notificación: $e');
      // No propagar el error para no afectar la actualización del vehículo
    }
  }
  
  // Actualizar vehículo
  Future<bool> updateVehicle(String id, Vehicle vehicle) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
    
    try {
      if (_awsService != null) {
        // Obtener el vehículo actualizado desde el servidor
        final updatedVehicle = await _awsService!.updateVehicle(vehicle);
        
        // Actualizar el vehículo en la lista local con los datos del servidor
        final index = _vehicles.indexWhere((v) => v.id == id);
        if (index != -1) {
          _vehicles[index] = updatedVehicle;
        }
        
        // También actualizar el vehículo seleccionado si es el mismo
        if (_selectedVehicle?.id == id) {
          _selectedVehicle = updatedVehicle;
        }
        
        _successMessage = 'Vehículo actualizado exitosamente';
        _errorMessage = null;
        _isLoading = false;
        
        // Enviar notificación push
        await _sendVehicleUpdatedNotification(updatedVehicle);
        
        notifyListeners();
        return true;
      } else {
        final result = await _demoService.updateVehicle(id, vehicle);
        _isLoading = false;
        if (result['success']) {
          final index = _vehicles.indexWhere((v) => v.id == id);
          if (index != -1) {
            _vehicles[index] = result['vehicle'];
          }
          
          // También actualizar el vehículo seleccionado
          if (_selectedVehicle?.id == id) {
            _selectedVehicle = result['vehicle'];
          }
          
          _successMessage = result['message'];
          _errorMessage = null;
          
          // Enviar notificación push
          await _sendVehicleUpdatedNotification(result['vehicle']);
          
          notifyListeners();
          return true;
        } else {
          _errorMessage = result['message'];
          notifyListeners();
          return false;
        }
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error de conexión. Por favor, intenta de nuevo.';
      notifyListeners();
      return false;
    }
  }
  
  // Eliminar vehículo
  Future<bool> deleteVehicle(String id) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
    
    try {
      if (_awsService != null) {
        await _awsService!.deleteVehicle(id);
        _vehicles.removeWhere((v) => v.id == id);
        _successMessage = 'Vehículo eliminado exitosamente';
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final result = await _demoService.deleteVehicle(id);
        _isLoading = false;
        if (result['success']) {
          _vehicles.removeWhere((v) => v.id == id);
          _successMessage = result['message'];
          _errorMessage = null;
          notifyListeners();
          return true;
        } else {
          _errorMessage = result['message'];
          notifyListeners();
          return false;
        }
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error de conexión. Por favor, intenta de nuevo.';
      notifyListeners();
      return false;
    }
  }
  
  // Subir imagen de vehículo
  Future<String?> uploadVehicleImage(String vehicleId, String imagePath) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      if (_awsService != null) {
        final imageFile = File(imagePath);
        final imageUrl = await _awsService!.uploadVehicleImage(imageFile, vehicleId);
        
        if (imageUrl != null) {
          // Actualizar URL en la lista local
          final index = _vehicles.indexWhere((v) => v.id == vehicleId);
          if (index != -1) {
            _vehicles[index] = _vehicles[index].copyWith(imageUrl: imageUrl);
          }
          
          if (_selectedVehicle?.id == vehicleId) {
            _selectedVehicle = _selectedVehicle!.copyWith(imageUrl: imageUrl);
          }
          
          print('✅ Imagen actualizada en vehículo: $vehicleId');
        } else {
          print('⚠️ No se pudo subir la imagen (Lambda UploadImage no configurado)');
          _errorMessage = 'Error al subir la imagen. Por favor, intenta de nuevo.';
        }
        
        _isLoading = false;
        notifyListeners();
        return imageUrl;
      } else {
        // Modo demo - no hay subida de imágenes
        _isLoading = false;
        _errorMessage = 'Servicio no disponible temporalmente';
        notifyListeners();
        return null;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error de conexión. Por favor, intenta de nuevo.';
      notifyListeners();
      return null;
    }
  }
  
  // Seleccionar vehículo
  void selectVehicle(Vehicle vehicle) {
    _selectedVehicle = vehicle;
    notifyListeners();
  }
  
  // Limpiar mensajes
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
  
  // Limpiar selección
  void clearSelection() {
    _selectedVehicle = null;
    notifyListeners();
  }
}
