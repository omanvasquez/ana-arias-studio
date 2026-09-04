import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../core/constants/firebase_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/utils/image_compressor.dart';

class SignatureRepository {
  final FirebaseStorage _storage;

  SignatureRepository({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  /// Optimiza la firma PNG en el cliente y la sube a Firebase Storage
  /// Ruta: `firmas/{clientId}/{sessionId}_signature.png`
  /// Retorna la URL pública de descarga
  Future<String> uploadSignature({
    required String clientId,
    required String sessionId,
    required Uint8List rawPngBytes,
  }) async {
    try {
      // Optimizar PNG transparente en el frontend
      final optimizedBytes = await ImageCompressor.optimizeSignatureBytes(rawPngBytes);

      final storagePath =
          '${FirebaseConstants.signaturesStoragePath}/$clientId/${sessionId}_signature.png';

      final ref = _storage.ref().child(storagePath);
      final metadata = SettableMetadata(
        contentType: 'image/png',
        customMetadata: {
          'client_id': clientId,
          'session_id': sessionId,
          'type': 'kiosk_signature',
        },
      );

      final uploadTask = await ref.putData(optimizedBytes, metadata);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw StorageException('Error al subir firma digital: ${e.toString()}');
    }
  }
}
