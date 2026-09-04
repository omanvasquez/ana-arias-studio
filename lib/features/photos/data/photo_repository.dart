import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../core/constants/firebase_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/utils/image_compressor.dart';

class PhotoRepository {
  final FirebaseStorage _storage;

  PhotoRepository({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  /// Comprime la foto en el cliente (< 500 KB) y la sube a Firebase Storage.
  /// REGLA ESTRICTA: Ninguna imagen sube cruda a Storage.
  Future<String> uploadSessionPhoto({
    required String clientId,
    required String sessionId,
    required Uint8List rawBytes,
    required String label, // 'antes' | 'despues' | 'detalle'
  }) async {
    try {
      // Compresión en el frontend
      final compressedBytes = await ImageCompressor.compressImageBytes(
        rawBytes,
        maxBytes: FirebaseConstants.maxPhotoSizeBytes,
      );

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storagePath =
          '${FirebaseConstants.photosStoragePath}/$clientId/${sessionId}_${label}_$timestamp.jpg';

      final ref = _storage.ref().child(storagePath);
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'client_id': clientId,
          'session_id': sessionId,
          'label': label,
          'compressed_size_bytes': compressedBytes.lengthInBytes.toString(),
        },
      );

      final uploadTask = await ref.putData(compressedBytes, metadata);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw StorageException('Error al subir fotografía comprimida: ${e.toString()}');
    }
  }
}
