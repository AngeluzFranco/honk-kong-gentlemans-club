import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

class ImageHelper {
  static final ImagePicker _picker = ImagePicker();
  
  // Seleccionar imagen de galería
  static Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        return await compressImage(File(image.path));
      }
      
      return null;
    } catch (e) {
      print('Error picking image from gallery: $e');
      return null;
    }
  }
  
  // Tomar foto con cámara
  static Future<File?> takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (photo != null) {
        return await compressImage(File(photo.path));
      }
      
      return null;
    } catch (e) {
      print('Error taking photo: $e');
      return null;
    }
  }
  
  // Comprimir imagen
  static Future<File> compressImage(File file) async {
    try {
      // Leer imagen original
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) return file;
      
      // Redimensionar si es muy grande
      img.Image resized = image;
      if (image.width > 1920 || image.height > 1080) {
        resized = img.copyResize(
          image,
          width: image.width > 1920 ? 1920 : null,
          height: image.height > 1080 ? 1080 : null,
        );
      }
      
      // Comprimir a JPEG con calidad 85
      final compressed = img.encodeJpg(resized, quality: 85);
      
      // Guardar imagen comprimida
      final compressedFile = File(file.path)..writeAsBytesSync(compressed);
      
      print('Original size: ${bytes.length} bytes');
      print('Compressed size: ${compressed.length} bytes');
      
      return compressedFile;
    } catch (e) {
      print('Error compressing image: $e');
      return file;
    }
  }
}
