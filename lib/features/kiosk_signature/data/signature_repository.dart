import 'dart:convert';
import 'dart:typed_data';
import 'package:ana_arias_studio/core/errors/app_exception.dart';
import 'package:ana_arias_studio/core/utils/image_compressor.dart';

class SignatureRepository {
  SignatureRepository();

  /// Optimiza la firma PNG en el cliente y la codifica en Base64 Data URL.
  /// Solución 100% Gratuita (Plan Spark sin requerir tarjeta ni Cloud Storage).
  /// Retorna la cadena data URL lista para persistirse en Firestore en el campo `url_firma`.
  Future<String> uploadSignature({
    required String clientId,
    required String sessionId,
    required Uint8List rawPngBytes,
  }) async {
    try {
      // 1. Optimizar PNG transparente en el frontend (reducción a trazo ligero < 30 KB)
      final optimizedBytes = await ImageCompressor.optimizeSignatureBytes(
        rawPngBytes,
        maxWidth: 800,
      );

      // 2. Codificar a Base64 Data URL para almacenamiento directo en Firestore
      final base64String = base64Encode(optimizedBytes);
      final dataUrl = 'data:image/png;base64,$base64String';

      return dataUrl;
    } catch (e) {
      throw StorageException('Error al procesar la firma digital: ${e.toString()}');
    }
  }
}
