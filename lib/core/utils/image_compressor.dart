import 'dart:typed_data';
import 'package:image/image.dart' as img;
import '../constants/firebase_constants.dart';
import '../errors/app_exception.dart';

/// Utilidad para compresión y optimización de imágenes en el cliente (Frontend).
/// Cumple con la regla de infraestructura estricta:
/// Ninguna foto sube cruda a Firebase Storage (Objetivo < 500 KB por imagen).
abstract class ImageCompressor {
  /// Comprime bytes de imagen JPG/PNG a un máximo aproximado de [maxBytes] (por defecto 500 KB).
  /// Reduce resolución si excede [maxWidth] o [maxHeight] y ajusta calidad JPEG.
  static Future<Uint8List> compressImageBytes(
    Uint8List originalBytes, {
    int maxWidth = 1600,
    int maxHeight = 1600,
    int quality = 80,
    int maxBytes = FirebaseConstants.maxPhotoSizeBytes,
  }) async {
    final decodedImage = img.decodeImage(originalBytes);
    if (decodedImage == null) {
      throw const StorageException('No se pudo decodificar la imagen para compresión.');
    }

    // Redimensionar manteniendo proporción si excede dimensiones máximas
    img.Image resized = decodedImage;
    if (decodedImage.width > maxWidth || decodedImage.height > maxHeight) {
      resized = img.copyResize(
        decodedImage,
        width: decodedImage.width > decodedImage.height ? maxWidth : null,
        height: decodedImage.height >= decodedImage.width ? maxHeight : null,
        interpolation: img.Interpolation.linear,
      );
    }

    int currentQuality = quality;
    Uint8List encoded = Uint8List.fromList(img.encodeJpg(resized, quality: currentQuality));

    // Si aún excede los 500 KB, reducir calidad progresivamente
    while (encoded.lengthInBytes > maxBytes && currentQuality > 40) {
      currentQuality -= 15;
      encoded = Uint8List.fromList(img.encodeJpg(resized, quality: currentQuality));
    }

    return encoded;
  }

  /// Comprime trazo de firma en PNG transparente preservando fondo transparente
  static Future<Uint8List> optimizeSignatureBytes(
    Uint8List originalPngBytes, {
    int maxWidth = 1000,
  }) async {
    final decoded = img.decodeImage(originalPngBytes);
    if (decoded == null) {
      return originalPngBytes;
    }

    if (decoded.width > maxWidth) {
      final resized = img.copyResize(decoded, width: maxWidth);
      return Uint8List.fromList(img.encodePng(resized, level: 6));
    }

    return Uint8List.fromList(img.encodePng(decoded, level: 6));
  }
}
