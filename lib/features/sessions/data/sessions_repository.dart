import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firebase_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../domain/session_model.dart';

class SessionsRepository {
  final FirebaseFirestore _firestore;

  SessionsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _sessionsRef =>
      _firestore.collection(FirebaseConstants.sessionsCollection);

  /// Stream cronológico de todas las sesiones de un cliente específico
  /// REGLA: Los documentos son independientes y se filtran por 'id_cliente'
  Stream<List<SessionModel>> streamSessionsByClient(String clientId) {
    return _sessionsRef
        .where('id_cliente', isEqualTo: clientId)
        .orderBy('fecha_cita', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SessionModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  /// Stream de las sesiones más recientes en todo el estudio (para vista del administrador)
  Stream<List<SessionModel>> streamRecentSessions({int limit = 20}) {
    return _sessionsRef
        .orderBy('fecha_cita', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SessionModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  /// Obtiene una sesión puntual por su ID
  Future<SessionModel?> getSessionById(String sessionId) async {
    try {
      final doc = await _sessionsRef.doc(sessionId).get();
      if (!doc.exists || doc.data() == null) return null;
      return SessionModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      throw FirestoreException('Error al consultar sesión: ${e.toString()}');
    }
  }

  /// Crea una nueva sesión en la colección independiente 'sesiones'
  Future<String> createSession(SessionModel session) async {
    try {
      final docRef = _sessionsRef.doc();
      final finalSession = session.copyWith(idSesion: docRef.id);
      await docRef.set(finalSession.toMap());
      return docRef.id;
    } catch (e) {
      throw FirestoreException('Error al registrar sesión: ${e.toString()}');
    }
  }

  /// Actualiza la URL de firma en una sesión
  Future<void> updateSignatureUrl(String sessionId, String signatureUrl) async {
    try {
      await _sessionsRef.doc(sessionId).update({
        'url_firma': signatureUrl,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw FirestoreException('Error al actualizar firma: ${e.toString()}');
    }
  }

  /// Agrega una URL de foto a la sesión
  Future<void> addPhotoUrl(String sessionId, String photoUrl) async {
    try {
      await _sessionsRef.doc(sessionId).update({
        'urls_fotos': FieldValue.arrayUnion([photoUrl]),
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw FirestoreException('Error al agregar foto a la sesión: ${e.toString()}');
    }
  }
}
