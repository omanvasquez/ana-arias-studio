import '../../clients/domain/medical_alert_model.dart';

/// Validador de compatibilidad de tratamientos según alertas médicas del cliente.
/// Implementa la regla de negocio crítica:
/// Hard block para tratamientos invasivos o incompatibles si existen alertas médicas activas.
class MedicalAlertChecker {
  /// Lista de tratamientos de alta contraindicación
  static const List<String> highRiskTreatments = [
    'Microblading',
    'Micropigmentación',
    'Nanoblading',
    'Laminado con Químicos Fuertes',
    'Tatuaje Cosmético',
  ];

  /// Comprueba si un tratamiento está estrictamente bloqueado por una o más alertas médicas
  static MedicalCompatibilityResult checkCompatibility({
    required String tratamiento,
    required Map<String, bool> alertasMedicas,
  }) {
    final activeAlerts = alertasMedicas.entries
        .where((e) => e.value == true)
        .map((e) => e.key)
        .toList();

    if (activeAlerts.isEmpty) {
      return const MedicalCompatibilityResult.compatible();
    }

    final isHighRisk = highRiskTreatments.any(
      (t) => t.toLowerCase() == tratamiento.trim().toLowerCase(),
    );

    // Contraindicaciones absolutas
    final hasAbsoluteContraindication = activeAlerts.any((alert) =>
        alert == MedicalAlertKeys.embarazo ||
        alert == MedicalAlertKeys.lactancia ||
        alert == MedicalAlertKeys.queloides ||
        alert == MedicalAlertKeys.tratamientoAnticoagulante ||
        alert == MedicalAlertKeys.afeccionesPiel);

    if (isHighRisk && hasAbsoluteContraindication) {
      final reasons = activeAlerts
          .map((k) => MedicalAlertKeys.getLabel(k))
          .join(', ');
      return MedicalCompatibilityResult.blocked(
        'Tratamiento estrictamente BLOQUEADO por contraindicaciones médicas detectadas: $reasons.',
      );
    }

    // Si tiene alertas menores pero no absolutas, advertencia grave
    final alertLabels = activeAlerts.map((k) => MedicalAlertKeys.getLabel(k)).join(', ');
    return MedicalCompatibilityResult.warning(
      'Atención: El cliente presenta condiciones médicas registradas ($alertLabels). Verifique autorización médica.',
    );
  }
}

class MedicalCompatibilityResult {
  final bool isBlocked;
  final bool hasWarning;
  final String? message;

  const MedicalCompatibilityResult._({
    required this.isBlocked,
    required this.hasWarning,
    this.message,
  });

  const MedicalCompatibilityResult.compatible()
      : this._(isBlocked: false, hasWarning: false);

  const MedicalCompatibilityResult.blocked(String message)
      : this._(isBlocked: true, hasWarning: true, message: message);

  const MedicalCompatibilityResult.warning(String message)
      : this._(isBlocked: false, hasWarning: true, message: message);
}
