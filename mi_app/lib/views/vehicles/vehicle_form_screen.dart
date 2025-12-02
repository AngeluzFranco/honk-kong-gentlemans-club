import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image/image.dart' as img;
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/vehicle_model.dart';
import '../../viewmodels/vehicle_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../utils/validators.dart';
import '../../utils/image_helper.dart';
import '../../utils/location_helper.dart';
import '../../widgets/vehicle_image.dart';

class VehicleFormScreen extends StatefulWidget {
  final Vehicle? vehicle;

  const VehicleFormScreen({super.key, this.vehicle});

  @override
  State<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends State<VehicleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _brandController;
  late TextEditingController _modelController;
  late TextEditingController _yearController;
  late TextEditingController _licensePlateController;
  late TextEditingController _colorController;
  late TextEditingController _vinController;
  late TextEditingController _mileageController;
  late TextEditingController _lastServiceDateController;
  late TextEditingController _notesController;

  File? _selectedImage;
  Position? _currentLocation;
  bool _loadingLocation = false;

  @override
  void initState() {
    super.initState();
    _brandController = TextEditingController(text: widget.vehicle?.brand ?? '');
    _modelController = TextEditingController(text: widget.vehicle?.model ?? '');
    _yearController = TextEditingController(
      text: widget.vehicle?.year.toString() ?? '',
    );
    _licensePlateController = TextEditingController(
      text: widget.vehicle?.licensePlate ?? '',
    );
    _colorController = TextEditingController(text: widget.vehicle?.color ?? '');
    _vinController = TextEditingController(text: widget.vehicle?.vin ?? '');
    _mileageController = TextEditingController(
      text: widget.vehicle?.mileage?.toString() ?? '',
    );
    _lastServiceDateController = TextEditingController(
      text: widget.vehicle?.lastServiceDate ?? '',
    );
    _notesController = TextEditingController(text: widget.vehicle?.notes ?? '');

    if (widget.vehicle?.latitude != null && widget.vehicle?.longitude != null) {
      _currentLocation = Position(
        latitude: widget.vehicle!.latitude!,
        longitude: widget.vehicle!.longitude!,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );
    }
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _licensePlateController.dispose();
    _colorController.dispose();
    _vinController.dispose();
    _mileageController.dispose();
    _lastServiceDateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final File? image = source == ImageSource.camera
        ? await ImageHelper.takePhoto()
        : await ImageHelper.pickImageFromGallery();

    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tomar Foto'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Seleccionar de Galería'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _loadingLocation = true;
    });

    final position = await LocationHelper.getCurrentLocation();

    setState(() {
      _loadingLocation = false;
      if (position != null) {
        _currentLocation = position;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ubicación obtenida exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo obtener la ubicación'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _lastServiceDateController.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _saveVehicle() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authViewModel = context.read<AuthViewModel>();
    final vehicleViewModel = context.read<VehicleViewModel>();
    final userId = authViewModel.currentUser?.id ?? '';

    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Usuario no identificado'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Convertir imagen a Base64 si fue seleccionada
    String? imageBase64;
    if (_selectedImage != null) {
      print('📸 Comprimiendo y convirtiendo imagen a Base64...');
      try {
        // Leer la imagen
        final bytes = await _selectedImage!.readAsBytes();
        print('📏 Tamaño original: ${bytes.length} bytes');
        
        // Decodificar la imagen
        img.Image? image = img.decodeImage(bytes);
        
        if (image != null) {
          // Redimensionar si es muy grande (máximo 800px de ancho)
          if (image.width > 800) {
            image = img.copyResize(image, width: 800);
            print('🔄 Imagen redimensionada a ${image.width}x${image.height}');
          }
          
          // Comprimir a JPEG con calidad 70%
          final compressedBytes = img.encodeJpg(image, quality: 70);
          print('📏 Tamaño comprimido: ${compressedBytes.length} bytes');
          
          // Verificar que no exceda 300KB (dejando margen para otros campos)
          if (compressedBytes.length > 300000) {
            // Si aún es muy grande, reducir más
            image = img.copyResize(image, width: 600);
            final recompressed = img.encodeJpg(image, quality: 60);
            imageBase64 = 'data:image/jpeg;base64,${base64Encode(recompressed)}';
            print('📏 Tamaño final (re-comprimido): ${recompressed.length} bytes');
          } else {
            imageBase64 = 'data:image/jpeg;base64,${base64Encode(compressedBytes)}';
          }
          
          print('✅ Imagen convertida: ${imageBase64.length} caracteres');
        } else {
          print('❌ No se pudo decodificar la imagen');
        }
      } catch (e) {
        print('❌ Error al convertir imagen: $e');
      }
    }

    final vehicle = Vehicle(
      id: widget.vehicle?.id,
      userId: userId,
      brand: _brandController.text.trim(),
      model: _modelController.text.trim(),
      year: int.parse(_yearController.text.trim()),
      licensePlate: _licensePlateController.text.trim(),
      color: _colorController.text.trim(),
      imageUrl: imageBase64 ?? widget.vehicle?.imageUrl, // Guardar Base64 o mantener la anterior
      vin: _vinController.text.trim().isNotEmpty
          ? _vinController.text.trim()
          : null,
      mileage: _mileageController.text.trim().isNotEmpty
          ? double.parse(_mileageController.text.trim())
          : null,
      latitude: _currentLocation?.latitude,
      longitude: _currentLocation?.longitude,
      lastServiceDate: _lastServiceDateController.text.trim().isNotEmpty
          ? _lastServiceDateController.text.trim()
          : null,
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
    );

    bool success;
    Vehicle? savedVehicle;
    
    if (widget.vehicle == null) {
      // Crear nuevo - capturar el vehículo con ID generado
      savedVehicle = await vehicleViewModel.createVehicle(vehicle);
      success = savedVehicle != null;
    } else {
      // Actualizar existente
      success = await vehicleViewModel.updateVehicle(widget.vehicle!.id!, vehicle);
      savedVehicle = success ? vehicle : null;
    }

    if (!mounted) return;

    if (success && savedVehicle != null) {
      // Ya no necesitamos uploadVehicleImage, la imagen ya está en el vehículo

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vehicleViewModel.successMessage ?? 'Guardado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop(true); // Devolver true para indicar éxito
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vehicleViewModel.errorMessage ?? 'Error de conexión. Por favor, intenta de nuevo.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.vehicle == null ? 'Nuevo Vehículo' : 'Editar Vehículo',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Imagen
            Center(
              child: GestureDetector(
                onTap: _showImageSourceDialog,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : widget.vehicle?.imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: VehicleImage(
                                imageUrl: widget.vehicle!.imageUrl!,
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_a_photo,
                                  size: 50,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Agregar Foto',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Marca
            TextFormField(
              controller: _brandController,
              decoration: const InputDecoration(
                labelText: 'Marca *',
                prefixIcon: Icon(Icons.business),
              ),
              validator: (value) => Validators.validateRequired(value, 'La marca'),
            ),
            const SizedBox(height: 16),

            // Modelo
            TextFormField(
              controller: _modelController,
              decoration: const InputDecoration(
                labelText: 'Modelo *',
                prefixIcon: Icon(Icons.directions_car),
              ),
              validator: (value) => Validators.validateRequired(value, 'El modelo'),
            ),
            const SizedBox(height: 16),

            // Año
            TextFormField(
              controller: _yearController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Año *',
                prefixIcon: Icon(Icons.calendar_today),
              ),
              validator: Validators.validateYear,
            ),
            const SizedBox(height: 16),

            // Placa
            TextFormField(
              controller: _licensePlateController,
              decoration: const InputDecoration(
                labelText: 'Placa *',
                prefixIcon: Icon(Icons.badge),
              ),
              validator: Validators.validateLicensePlate,
            ),
            const SizedBox(height: 16),

            // Color
            TextFormField(
              controller: _colorController,
              decoration: const InputDecoration(
                labelText: 'Color *',
                prefixIcon: Icon(Icons.palette),
              ),
              validator: (value) => Validators.validateRequired(value, 'El color'),
            ),
            const SizedBox(height: 16),

            // Número de Serie
            TextFormField(
              controller: _vinController,
              decoration: const InputDecoration(
                labelText: 'Número de Serie (opcional)',
                prefixIcon: Icon(Icons.fingerprint),
              ),
            ),
            const SizedBox(height: 16),

            // Kilometraje
            TextFormField(
              controller: _mileageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Kilometraje (opcional)',
                prefixIcon: Icon(Icons.speed),
                suffixText: 'km',
              ),
              validator: Validators.validateMileage,
            ),
            const SizedBox(height: 16),

            // Último servicio
            TextFormField(
              controller: _lastServiceDateController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Último Servicio (opcional)',
                prefixIcon: const Icon(Icons.build),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _selectDate,
                ),
              ),
              onTap: _selectDate,
            ),
            const SizedBox(height: 16),

            // Ubicación
            Card(
              child: ListTile(
                leading: const Icon(Icons.location_on),
                title: Text(
                  _currentLocation != null
                      ? 'Ubicación Guardada'
                      : 'Agregar Ubicación',
                ),
                subtitle: _currentLocation != null
                    ? Text(
                        'Lat: ${_currentLocation!.latitude.toStringAsFixed(6)}\nLng: ${_currentLocation!.longitude.toStringAsFixed(6)}',
                      )
                    : const Text('Obtener ubicación actual'),
                trailing: _loadingLocation
                    ? const CircularProgressIndicator()
                    : const Icon(Icons.chevron_right),
                onTap: _loadingLocation ? null : _getCurrentLocation,
              ),
            ),
            const SizedBox(height: 16),

            // Notas
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notas (opcional)',
                prefixIcon: Icon(Icons.notes),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 32),

            // Botón Guardar
            Consumer<VehicleViewModel>(
              builder: (context, vehicleViewModel, child) {
                return ElevatedButton(
                  onPressed: vehicleViewModel.isLoading ? null : _saveVehicle,
                  child: vehicleViewModel.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(widget.vehicle == null ? 'Crear Vehículo' : 'Actualizar'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
