import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/vehicle_viewmodel.dart';
import '../../models/vehicle_model.dart';
import '../../widgets/vehicle_image.dart';
import 'vehicle_detail_screen.dart';
import 'vehicle_form_screen.dart';

class VehiclesListScreen extends StatefulWidget {
  const VehiclesListScreen({super.key});

  @override
  State<VehiclesListScreen> createState() => _VehiclesListScreenState();
}

class _VehiclesListScreenState extends State<VehiclesListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<VehicleViewModel>().loadVehicles();
    });
  }

  Future<void> _refreshVehicles() async {
    await context.read<VehicleViewModel>().loadVehicles();
  }

  Future<void> _confirmDelete(Vehicle vehicle) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Vehículo'),
        content: Text(
          '¿Estás seguro de eliminar ${vehicle.brand} ${vehicle.model}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (shouldDelete == true && mounted) {
      final success = await context
          .read<VehicleViewModel>()
          .deleteVehicle(vehicle.id!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Vehículo eliminado exitosamente'
                  : 'Error al eliminar vehículo',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<VehicleViewModel>(
        builder: (context, vehicleViewModel, child) {
          if (vehicleViewModel.isLoading && vehicleViewModel.vehicles.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (vehicleViewModel.errorMessage != null &&
              vehicleViewModel.vehicles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(vehicleViewModel.errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshVehicles,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (vehicleViewModel.vehicles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.directions_car_outlined,
                    size: 100,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes vehículos registrados',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Agrega tu primer vehículo',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshVehicles,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: vehicleViewModel.vehicles.length,
              itemBuilder: (context, index) {
                final vehicle = vehicleViewModel.vehicles[index];
                return _VehicleCard(
                  vehicle: vehicle,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => VehicleDetailScreen(vehicle: vehicle),
                      ),
                    );
                  },
                  onDelete: () => _confirmDelete(vehicle),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const VehicleFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _VehicleCard({
    required this.vehicle,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Imagen o icono
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: VehicleImage(
                  imageUrl: vehicle.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              
              // Información
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${vehicle.brand} ${vehicle.model}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Año: ${vehicle.year}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      'Placa: ${vehicle.licensePlate}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (vehicle.mileage != null)
                      Text(
                        'Kilometraje: ${vehicle.mileage!.toStringAsFixed(0)} km',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
              
              // Botón eliminar
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
