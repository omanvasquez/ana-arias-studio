import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firebase_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../domain/client_model.dart';

class ClientsRepository {
  final FirebaseFirestore _firestore;

  ClientsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _clientsRef =>
      _firestore.collection(FirebaseConstants.clientsCollection);

  /// Obtiene stream reactivo de la lista de todos los clientes
  Stream<List<ClientModel>> streamClients() {
    return _clientsRef
        .orderBy('nombre')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ClientModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  /// Obtiene un cliente por su ID
  Future<ClientModel?> getClientById(String clientId) async {
    try {
      final doc = await _clientsRef.doc(clientId).get();
      if (!doc.exists || doc.data() == null) return null;
      return ClientModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      throw FirestoreException('Error al consultar cliente: ${e.toString()}');
    }
  }

  /// Registra un nuevo cliente en Firestore
  Future<String> createClient({
    required String nombre,
    required String telefono,
    required String email,
    required Map<String, bool> alertasMedicas,
  }) async {
    try {
      final docRef = _clientsRef.doc();
      final client = ClientModel(
        id: docRef.id,
        nombre: nombre.trim(),
        telefono: telefono.trim(),
        email: email.trim(),
        alertasMedicas: alertasMedicas,
        createdAt: DateTime.now(),
      );

      await docRef.set(client.toMap());
      return docRef.id;
    } catch (e) {
      throw FirestoreException('Error al registrar cliente: ${e.toString()}');
    }
  }

  /// Actualiza información de un cliente existente
  Future<void> updateClient(ClientModel client) async {
    try {
      await _clientsRef.doc(client.id).update(client.toMap());
    } catch (e) {
      throw FirestoreException('Error al actualizar cliente: ${e.toString()}');
    }
  }

  /// Actualiza específicamente las alertas médicas de un cliente
  Future<void> updateMedicalAlerts(String clientId, Map<String, bool> alertas) async {
    try {
      await _clientsRef.doc(clientId).update({
        'alertas_medicas': alertas,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw FirestoreException('Error al actualizar alertas médicas: ${e.toString()}');
    }
  }
}
