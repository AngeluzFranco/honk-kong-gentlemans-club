import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
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

  Future<void> _openGoogleMaps(double latitude, double longitude) async {
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir Google Maps')),
        );
      }
    }
  }

  void _showFullImage(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(10),
          child: Stack(
            children: [
              // Imagen completa
              Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: VehicleImage(
                        imageUrl: _currentVehicle.imageUrl,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            // Botón de cerrar
            Positioned(
              top: 20,
              right: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.black),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Cerrar',
                ),
              ),
            ),
            // Indicador de zoom
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.pinch_rounded, color: Colors.white, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Pellizca para hacer zoom',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header con gradiente
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                '${_currentVehicle.brand} ${_currentVehicle.model}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  letterSpacing: -0.5,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3.0,
                      color: Color.fromARGB(100, 0, 0, 0),
                    ),
                  ],
                ),
              ),
              background: GestureDetector(
                onTap: () => _showFullImage(context),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Imagen del vehículo
                    Hero(
                      tag: 'vehicle-${_currentVehicle.id}',
                      child: VehicleImage(
                        imageUrl: _currentVehicle.imageUrl,
                        height: 280,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Gradiente overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.edit_rounded, color: Colors.white),
                  onPressed: _navigateToEdit,
                  tooltip: 'Editar',
                ),
              ),
            ],
          ),

          // Contenido
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Información básica
                  _InfoCard(
                    title: 'Información General',
                    icon: Icons.info_rounded,
                    iconColor: Theme.of(context).primaryColor,
                    children: [
                      _InfoRow(
                        icon: Icons.calendar_today_rounded,
                        iconColor: Colors.orange,
                        label: 'Año',
                        value: _currentVehicle.year.toString(),
                      ),
                      _InfoRow(
                        icon: Icons.palette_rounded,
                        iconColor: Colors.purple,
                        label: 'Color',
                        value: _currentVehicle.color,
                      ),
                      _InfoRow(
                        icon: Icons.credit_card_rounded,
                        iconColor: Colors.blue,
                        label: 'Placa',
                        value: _currentVehicle.licensePlate,
                      ),
                      if (_currentVehicle.vin != null)
                        _InfoRow(
                          icon: Icons.qr_code_rounded,
                          iconColor: Colors.teal,
                          label: 'Número de Serie',
                          value: _currentVehicle.vin!,
                        ),
                      if (_currentVehicle.mileage != null)
                        _InfoRow(
                          icon: Icons.speed_rounded,
                          iconColor: Colors.red,
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
                      icon: Icons.build_rounded,
                      iconColor: Colors.green,
                      children: [
                        _InfoRow(
                          icon: Icons.event_rounded,
                          iconColor: Colors.green,
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
                      icon: Icons.note_rounded,
                      iconColor: Colors.amber,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.amber.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            _currentVehicle.notes!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[800],
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Mapa de ubicación
                  if (_currentVehicle.latitude != null && _currentVehicle.longitude != null) ...[
                    const SizedBox(height: 16),
                    _InfoCard(
                      title: 'Ubicación',
                      icon: Icons.location_on_rounded,
                      iconColor: Colors.red,
                      children: [
                        InkWell(
                          onTap: () => _openGoogleMaps(_currentVehicle.latitude!, _currentVehicle.longitude!),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            height: 180,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.blue[50]!,
                                  Colors.blue[100]!,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.blue.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: Stack(
                              children: [
                                // Fondo con icono de mapa
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.blue.withOpacity(0.2),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          Icons.map_rounded,
                                          size: 48,
                                          color: Colors.blue[700],
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Toca para ver en Google Maps',
                                        style: TextStyle(
                                          color: Colors.blue[900],
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.05),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.location_on, size: 14, color: Colors.red[600]),
                                            const SizedBox(width: 6),
                                            Text(
                                              '${_currentVehicle.latitude!.toStringAsFixed(4)}, ${_currentVehicle.longitude!.toStringAsFixed(4)}',
                                              style: TextStyle(
                                                color: Colors.grey[800],
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Icono de enlace externo
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[700],
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.blue.withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.open_in_new_rounded,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final IconData? icon;
  final Color? iconColor;

  const _InfoCard({
    required this.title,
    required this.children,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (iconColor ?? Theme.of(context).primaryColor).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      size: 20,
                      color: iconColor ?? Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
  final IconData? icon;
  final Color? iconColor;

  const _InfoRow({
    required this.label,
    required this.value,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: (iconColor ?? Colors.grey).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 16,
                color: iconColor ?? Colors.grey,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                ),
                const SizedBox(width: 16),
                Flexible(
                  child: Text(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[900],
                          fontWeight: FontWeight.w500,
                        ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
