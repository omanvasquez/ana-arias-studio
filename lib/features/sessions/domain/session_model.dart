import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo para Sesión / Cita de tratamiento en Ana Arias Studio.
/// Siguiendo la regla de base de datos de Fase 1:
/// Los documentos de sesión son INDEPENDIENTES en la colección 'sesiones'.
/// NUNCA se anidan dentro de la colección 'clientes'.
class SessionModel {
  final String idSesion;
  final String idCliente;
  final DateTime fechaCita;
  final String tipoTratamiento;
  final Map<String, dynamic> detallesTratamiento;
  final String urlFirma;
  final List<String> urlsFotos;
  final String notasInternas;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SessionModel({
    required this.idSesion,
    required this.idCliente,
    required this.fechaCita,
    required this.tipoTratamiento,
    required this.detallesTratamiento,
    required this.urlFirma,
    required this.urlsFotos,
    required this.notasInternas,
    this.createdAt,
    this.updatedAt,
  });

  bool get hasSignature => urlFirma.isNotEmpty;
  bool get hasPhotos => urlsFotos.isNotEmpty;

  Map<String, dynamic> toMap() {
    return {
      'id_sesion': idSesion,
      'id_cliente': idCliente,
      'fecha_cita': Timestamp.fromDate(fechaCita),
      'tipo_tratamiento': tipoTratamiento,
      'detalles_tratamiento': detallesTratamiento,
      'url_firma': urlFirma,
      'urls_fotos': urlsFotos,
      'notas_internas': notasInternas,
      'created_at': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    };
  }

  factory SessionModel.fromMap(Map<String, dynamic> map, String documentId) {
    DateTime parseTimestamp(dynamic value, DateTime fallback) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      return fallback;
    }

    final rawPhotos = map['urls_fotos'];
    final List<String> photosList = [];
    if (rawPhotos is List) {
      for (final item in rawPhotos) {
        if (item != null) photosList.add(item.toString());
      }
    }

    final rawDetails = map['detalles_tratamiento'];
    final Map<String, dynamic> detailsMap = {};
    if (rawDetails is Map) {
      rawDetails.forEach((k, v) {
        detailsMap[k.toString()] = v;
      });
    }

    return SessionModel(
      idSesion: documentId,
      idCliente: map['id_cliente']?.toString() ?? '',
      fechaCita: parseTimestamp(map['fecha_cita'], DateTime.now()),
      tipoTratamiento: map['tipo_tratamiento']?.toString() ?? '',
      detallesTratamiento: detailsMap,
      urlFirma: map['url_firma']?.toString() ?? '',
      urlsFotos: photosList,
      notasInternas: map['notas_internas']?.toString() ?? '',
      createdAt: map['created_at'] is Timestamp ? (map['created_at'] as Timestamp).toDate() : null,
      updatedAt: map['updated_at'] is Timestamp ? (map['updated_at'] as Timestamp).toDate() : null,
    );
  }

  SessionModel copyWith({
    String? idSesion,
    String? idCliente,
    DateTime? fechaCita,
    String? tipoTratamiento,
    Map<String, dynamic>? detallesTratamiento,
    String? urlFirma,
    List<String>? urlsFotos,
    String? notasInternas,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SessionModel(
      idSesion: idSesion ?? this.idSesion,
      idCliente: idCliente ?? this.idCliente,
      fechaCita: fechaCita ?? this.fechaCita,
      tipoTratamiento: tipoTratamiento ?? this.tipoTratamiento,
      detallesTratamiento: detallesTratamiento ?? this.detallesTratamiento,
      urlFirma: urlFirma ?? this.urlFirma,
      urlsFotos: urlsFotos ?? this.urlsFotos,
      notasInternas: notasInternas ?? this.notasInternas,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
