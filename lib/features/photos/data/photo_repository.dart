import 'dart:convert';
import 'dart:typed_data';
import 'package:ana_arias_studio/core/errors/app_exception.dart';
import 'package:ana_arias_studio/core/utils/image_compressor.dart';

class PhotoRepository {
  PhotoRepository();

  /// Comprime la foto en el cliente (< 180 KB) y la codifica en Base64 Data URL.
  /// Solución 100% Gratuita (Plan Spark sin requerir tarjeta ni Cloud Storage).
  /// Se almacena directamente en el array `urls_fotos` del documento de sesión en Firestore.
  Future<String> uploadSessionPhoto({
    required String clientId,
    required String sessionId,
    required Uint8List rawBytes,
    required String label, // 'antes' | 'despues' | 'detalle'
  }) async {
    try {
      // Compresión cliente optimizada a resolución estándar para caber en Firestore (< 180 KB)
      final compressedBytes = await ImageCompressor.compressImageBytes(
        rawBytes,
        maxWidth: 900,
        maxHeight: 900,
        quality: 68,
        maxBytes: 180 * 1024,
      );

      final base64String = base64Encode(compressedBytes);
      final dataUrl = 'data:image/jpeg;base64,$base64String';

      return dataUrl;
    } catch (e) {
      throw StorageException('Error al procesar fotografía: ${e.toString()}');
    }
  }
}
