import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de datos de Cliente para Ana Arias Studio.
/// Siguiendo la regla de base de datos de Fase 1:
/// Solo contiene información estática y el mapa de alertas médicas.
class ClientModel {
  final String id;
  final String nombre;
  final String telefono;
  final String email;
  final Map<String, bool> alertasMedicas;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ClientModel({
    required this.id,
    required this.nombre,
    required this.telefono,
    required this.email,
    required this.alertasMedicas,
    this.createdAt,
    this.updatedAt,
  });

  /// Determina si el cliente tiene alguna alerta médica activa
  bool get hasActiveAlerts => alertasMedicas.values.any((active) => active == true);

  /// Lista de claves de alertas médicas activas
  List<String> get activeAlertKeys => alertasMedicas.entries
      .where((entry) => entry.value == true)
      .map((entry) => entry.key)
      .toList();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'telefono': telefono,
      'email': email,
      'alertas_medicas': alertasMedicas,
      'created_at': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    };
  }

  factory ClientModel.fromMap(Map<String, dynamic> map, String documentId) {
    final rawAlerts = map['alertas_medicas'];
    final Map<String, bool> parsedAlerts = {};
    if (rawAlerts is Map) {
      rawAlerts.forEach((key, value) {
        parsedAlerts[key.toString()] = value == true;
      });
    }

    DateTime? parseTimestamp(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      return null;
    }

    return ClientModel(
      id: documentId,
      nombre: map['nombre']?.toString() ?? '',
      telefono: map['telefono']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      alertasMedicas: parsedAlerts,
      createdAt: parseTimestamp(map['created_at']),
      updatedAt: parseTimestamp(map['updated_at']),
    );
  }

  ClientModel copyWith({
    String? id,
    String? nombre,
    String? telefono,
    String? email,
    Map<String, bool>? alertasMedicas,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ClientModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      alertasMedicas: alertasMedicas ?? this.alertasMedicas,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
