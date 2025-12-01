import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class VehicleImage extends StatelessWidget {
  final String? imageUrl;
  final double? height;
  final double? width;
  final BoxFit fit;
  final Widget? placeholder;

  const VehicleImage({
    super.key,
    this.imageUrl,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildPlaceholder();
    }

    // Si la imagen es Base64
    if (imageUrl!.startsWith('data:image')) {
      try {
        final base64String = imageUrl!.split(',').last;
        final Uint8List bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          height: height,
          width: width,
          fit: fit,
          errorBuilder: (_, __, ___) => _buildPlaceholder(),
        );
      } catch (e) {
        print('❌ Error al decodificar Base64: $e');
        return _buildPlaceholder();
      }
    }

    // Si es una URL normal
    return Image.network(
      imageUrl!,
      height: height,
      width: width,
      fit: fit,
      errorBuilder: (_, __, ___) => _buildPlaceholder(),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder() {
    return placeholder ??
        Container(
          height: height,
          width: width,
          color: Colors.grey[300],
          child: const Icon(
            Icons.directions_car,
            size: 100,
            color: Colors.grey,
          ),
        );
  }
}
