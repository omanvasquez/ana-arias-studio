/// Constantes de colecciones y rutas de almacenamiento para Firebase.
/// Diseñadas respetando la regla estricta:
/// - Colección 'clientes' (documentos raíz)
/// - Colección 'sesiones' (documentos independientes en la raíz, NUNCA anidadas en clientes)
abstract class FirebaseConstants {
  // Colecciones Firestore
  static const String clientsCollection = 'clientes';
  static const String sessionsCollection = 'sesiones';

  // Rutas en Firebase Storage
  static const String signaturesStoragePath = 'firmas';
  static const String photosStoragePath = 'fotos';

  // Límite máximo estricto para subida de fotos (500 KB)
  static const int maxPhotoSizeBytes = 500 * 1024;
}
