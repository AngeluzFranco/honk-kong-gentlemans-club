import 'package:geolocator/geolocator.dart';

class LocationHelper {
  // Verificar permisos de ubicación
  static Future<bool> checkPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;
    
    // Verificar si el servicio de ubicación está habilitado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }
    
    // Verificar permisos
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    
    return true;
  }
  
  // Obtener ubicación actual
  static Future<Position?> getCurrentLocation() async {
    try {
      final hasPermission = await checkPermissions();
      
      if (!hasPermission) {
        print('Location permissions not granted');
        return null;
      }
      
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      return position;
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }
  
  // Calcular distancia entre dos puntos
  static double calculateDistance(
    double startLat,
    double startLon,
    double endLat,
    double endLon,
  ) {
    return Geolocator.distanceBetween(startLat, startLon, endLat, endLon);
  }
  
  // Abrir configuración de ubicación
  static Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }
}
