import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_storage/firebase_storage.dart';
import '../models/vehicle_model.dart';

class FirebaseVehicleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  // CREATE
  Future<Map<String, dynamic>> createVehicle(Vehicle vehicle) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'Usuario no autenticado',
        };
      }
      
      final docRef = await _firestore.collection('vehicles').add({
        'userId': user.uid,
        'brand': vehicle.brand,
        'model': vehicle.model,
        'year': vehicle.year,
        'licensePlate': vehicle.licensePlate,
        'color': vehicle.color,
        'vin': vehicle.vin,
        'mileage': vehicle.mileage,
        'imageUrl': vehicle.imageUrl,
        'latitude': vehicle.latitude,
        'longitude': vehicle.longitude,
        'lastServiceDate': vehicle.lastServiceDate,
        'notes': vehicle.notes,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      final createdVehicle = vehicle.copyWith(id: docRef.id);
      
      return {
        'success': true,
        'vehicle': createdVehicle,
        'message': 'Vehículo creado exitosamente',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error al crear vehículo: $e',
      };
    }
  }
  
  // READ ALL
  Future<Map<String, dynamic>> getVehicles() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'Usuario no autenticado',
          'vehicles': <Vehicle>[],
        };
      }
      
      final querySnapshot = await _firestore
          .collection('vehicles')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();
      
      final vehicles = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Vehicle(
          id: doc.id,
          userId: data['userId'],
          brand: data['brand'],
          model: data['model'],
          year: data['year'],
          licensePlate: data['licensePlate'],
          color: data['color'],
          vin: data['vin'],
          mileage: data['mileage']?.toDouble(),
          imageUrl: data['imageUrl'],
          latitude: data['latitude']?.toDouble(),
          longitude: data['longitude']?.toDouble(),
          lastServiceDate: data['lastServiceDate'],
          notes: data['notes'],
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
      
      return {
        'success': true,
        'vehicles': vehicles,
        'message': 'Vehículos obtenidos exitosamente',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error al obtener vehículos: $e',
        'vehicles': <Vehicle>[],
      };
    }
  }
  
  // READ ONE
  Future<Map<String, dynamic>> getVehicleById(String id) async {
    try {
      final doc = await _firestore.collection('vehicles').doc(id).get();
      
      if (!doc.exists) {
        return {
          'success': false,
          'message': 'Vehículo no encontrado',
        };
      }
      
      final data = doc.data()!;
      final vehicle = Vehicle(
        id: doc.id,
        userId: data['userId'],
        brand: data['brand'],
        model: data['model'],
        year: data['year'],
        licensePlate: data['licensePlate'],
        color: data['color'],
        vin: data['vin'],
        mileage: data['mileage']?.toDouble(),
        imageUrl: data['imageUrl'],
        latitude: data['latitude']?.toDouble(),
        longitude: data['longitude']?.toDouble(),
        lastServiceDate: data['lastServiceDate'],
        notes: data['notes'],
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
      
      return {
        'success': true,
        'vehicle': vehicle,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error al obtener vehículo: $e',
      };
    }
  }
  
  // UPDATE
  Future<Map<String, dynamic>> updateVehicle(String id, Vehicle vehicle) async {
    try {
      await _firestore.collection('vehicles').doc(id).update({
        'brand': vehicle.brand,
        'model': vehicle.model,
        'year': vehicle.year,
        'licensePlate': vehicle.licensePlate,
        'color': vehicle.color,
        'vin': vehicle.vin,
        'mileage': vehicle.mileage,
        'imageUrl': vehicle.imageUrl,
        'latitude': vehicle.latitude,
        'longitude': vehicle.longitude,
        'lastServiceDate': vehicle.lastServiceDate,
        'notes': vehicle.notes,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      return {
        'success': true,
        'message': 'Vehículo actualizado exitosamente',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error al actualizar vehículo: $e',
      };
    }
  }
  
  // DELETE
  Future<Map<String, dynamic>> deleteVehicle(String id) async {
    try {
      // Obtener URL de imagen si existe para eliminarla
      final doc = await _firestore.collection('vehicles').doc(id).get();
      if (doc.exists) {
        final imageUrl = doc.data()?['imageUrl'];
        if (imageUrl != null && imageUrl.toString().contains('firebase')) {
          try {
            await _storage.refFromURL(imageUrl).delete();
          } catch (e) {
            print('Error al eliminar imagen: $e');
          }
        }
      }
      
      await _firestore.collection('vehicles').doc(id).delete();
      
      return {
        'success': true,
        'message': 'Vehículo eliminado exitosamente',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error al eliminar vehículo: $e',
      };
    }
  }
  
  // UPLOAD IMAGE
  Future<Map<String, dynamic>> uploadVehicleImage(File imageFile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'Usuario no autenticado',
        };
      }
      
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('vehicle_images/${user.uid}/$fileName');
      
      final uploadTask = await ref.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      
      return {
        'success': true,
        'imageUrl': downloadUrl,
        'message': 'Imagen subida exitosamente',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error al subir imagen: $e',
      };
    }
  }
}
