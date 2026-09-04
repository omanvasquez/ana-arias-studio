/// Catálogo estandarizado de alertas médicas para Ana Arias Studio.
/// Cero texto libre: Uso de opciones fijas con flags booleanas.
class MedicalAlertKeys {
  static const String embarazo = 'embarazo';
  static const String lactancia = 'lactancia';
  static const String hipertension = 'hipertension';
  static const String diabetes = 'diabetes';
  static const String queloides = 'queloides';
  static const String alergiaPigmentos = 'alergia_pigmentos';
  static const String tratamientoAnticoagulante = 'tratamiento_anticoagulante';
  static const String afeccionesPiel = 'afecciones_piel';

  static const List<String> allKeys = [
    embarazo,
    lactancia,
    hipertension,
    diabetes,
    queloides,
    alergiaPigmentos,
    tratamientoAnticoagulante,
    afeccionesPiel,
  ];

  static String getLabel(String key) {
    switch (key) {
      case embarazo:
        return 'Embarazo';
      case lactancia:
        return 'Período de Lactancia';
      case hipertension:
        return 'Hipertensión no controlada';
      case diabetes:
        return 'Diabetes no controlada';
      case queloides:
        return 'Tendencia a cicatrización queloide';
      case alergiaPigmentos:
        return 'Alergia conocida a pigmentos/anestésicos';
      case tratamientoAnticoagulante:
        return 'Tratamiento con anticoagulantes';
      case afeccionesPiel:
        return 'Afecciones activas en la zona de la piel';
      default:
        return key;
    }
  }
}
