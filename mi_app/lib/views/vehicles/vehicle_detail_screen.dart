import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../models/vehicle_model.dart';
import '../../viewmodels/vehicle_viewmodel.dart';
import '../../widgets/vehicle_image.dart';
import 'vehicle_form_screen.dart';

class VehicleDetailScreen extends StatefulWidget {
  final Vehicle vehicle;

  const VehicleDetailScreen({super.key, required this.vehicle});

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  late Vehicle _currentVehicle;

  @override
  void initState() {
    super.initState();
    _currentVehicle = widget.vehicle;
  }

  Future<void> _navigateToEdit() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VehicleFormScreen(vehicle: _currentVehicle),
      ),
    );

    // Si regresó de la edición, actualizar con los datos del viewmodel
    if (result == true && mounted) {
      final vehicleViewModel = Provider.of<VehicleViewModel>(context, listen: false);
      
      // Buscar el vehículo actualizado en la lista (más confiable que selectedVehicle)
      final updatedVehicle = vehicleViewModel.vehicles.firstWhere(
        (v) => v.id == _currentVehicle.id,
        orElse: () => _currentVehicle,
      );
      
      // También intentar desde selectedVehicle como fallback
      final vehicleToUse = vehicleViewModel.selectedVehicle?.id == _currentVehicle.id
          ? vehicleViewModel.selectedVehicle!
          : updatedVehicle;
      
      print('🔄 Actualizando vista - Vehículo anterior: ${_currentVehicle.brand} ${_currentVehicle.model}');
      print('🔄 Vehículo actualizado: ${vehicleToUse.brand} ${vehicleToUse.model}');
      
      setState(() {
        _currentVehicle = vehicleToUse;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Vehículo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _navigateToEdit,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Imagen
            VehicleImage(
              imageUrl: _currentVehicle.imageUrl,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    '${_currentVehicle.brand} ${_currentVehicle.model}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 24),

                  // Información básica
                  _InfoCard(
                    title: 'Información General',
                    children: [
                      _InfoRow(label: 'Año', value: _currentVehicle.year.toString()),
                      _InfoRow(label: 'Color', value: _currentVehicle.color),
                      _InfoRow(label: 'Placa', value: _currentVehicle.licensePlate),
                      if (_currentVehicle.vin != null)
                        _InfoRow(label: 'VIN', value: _currentVehicle.vin!),
                      if (_currentVehicle.mileage != null)
                        _InfoRow(
                          label: 'Kilometraje',
                          value: '${_currentVehicle.mileage!.toStringAsFixed(0)} km',
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Servicio
                  if (_currentVehicle.lastServiceDate != null)
                    _InfoCard(
                      title: 'Mantenimiento',
                      children: [
                        _InfoRow(
                          label: 'Último Servicio',
                          value: _currentVehicle.lastServiceDate!,
                        ),
                      ],
                    ),

                  // Notas
                  if (_currentVehicle.notes != null && _currentVehicle.notes!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _InfoCard(
                      title: 'Notas',
                      children: [
                        Text(
                          _currentVehicle.notes!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],

                  // Mapa de ubicación (Deshabilitado - requiere API Key)
                  if (_currentVehicle.latitude != null && _currentVehicle.longitude != null) ...[
                    const SizedBox(height: 16),
                    _InfoCard(
                      title: 'Ubicación',
                      children: [
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 60,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Mapa no disponible',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Configura Google Maps API Key',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Lat: ${_currentVehicle.latitude!.toStringAsFixed(6)}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                'Lng: ${_currentVehicle.longitude!.toStringAsFixed(6)}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // GoogleMap comentado hasta configurar API Key
                        /* 
                        SizedBox(
                          height: 200,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: LatLng(
                                  vehicle.latitude!,
                                  vehicle.longitude!,
                                ),
                                zoom: 15,
                              ),
                              markers: {
                                Marker(
                                  markerId: const MarkerId('vehicle_location'),
                                  position: LatLng(
                                    vehicle.latitude!,
                                    vehicle.longitude!,
                                  ),
                                  infoWindow: InfoWindow(
                                    title: '${vehicle.brand} ${vehicle.model}',
                                  ),
                                ),
                              },
                            ),
                          ),
                        ),
                        */
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
