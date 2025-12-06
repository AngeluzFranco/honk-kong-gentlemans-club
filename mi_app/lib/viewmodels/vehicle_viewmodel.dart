import 'dart:io';
import 'package:flutter/material.dart';
import '../models/vehicle_model.dart';
import '../services/aws_vehicle_service.dart';
import '../services/firebase_notification_service.dart';

class VehicleViewModel extends ChangeNotifier {
  final AWSVehicleService _vehicleService = AWSVehicleService();
  
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
      _vehicles = await _vehicleService.getVehicles();
      _errorMessage = null;
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
      _selectedVehicle = await _vehicleService.getVehicleById(id);
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return _selectedVehicle != null;
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
      final createdVehicle = await _vehicleService.createVehicle(vehicle);
      _vehicles.add(createdVehicle);
      _selectedVehicle = createdVehicle;
      _successMessage = 'Vehículo creado exitosamente';
      _errorMessage = null;
      _isLoading = false;
      
      // Enviar notificación push
      await _sendVehicleCreatedNotification(createdVehicle);
      
      notifyListeners();
      return createdVehicle;
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
      final updatedVehicle = await _vehicleService.updateVehicle(vehicle);
      
      final index = _vehicles.indexWhere((v) => v.id == id);
      if (index != -1) {
        _vehicles[index] = updatedVehicle;
      }
      
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
      await _vehicleService.deleteVehicle(id);
      _vehicles.removeWhere((v) => v.id == id);
      _successMessage = 'Vehículo eliminado exitosamente';
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return true;
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
      final imageFile = File(imagePath);
      final imageUrl = await _vehicleService.uploadVehicleImage(imageFile, vehicleId);
      
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
