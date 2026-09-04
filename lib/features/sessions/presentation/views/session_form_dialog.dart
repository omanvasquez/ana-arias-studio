import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ana_arias_studio/core/constants/app_colors.dart';
import 'package:ana_arias_studio/features/clients/domain/client_model.dart';
import 'package:ana_arias_studio/features/clients/presentation/controllers/clients_controller.dart';
import 'package:ana_arias_studio/features/medical_alerts/domain/medical_alert_checker.dart';
import 'package:ana_arias_studio/features/sessions/domain/session_model.dart';
import 'package:ana_arias_studio/features/sessions/presentation/controllers/sessions_controller.dart';

class SessionFormDialog extends ConsumerStatefulWidget {
  final ClientModel? preselectedClient;

  const SessionFormDialog({super.key, this.preselectedClient});

  @override
  ConsumerState<SessionFormDialog> createState() => _SessionFormDialogState();
}

class _SessionFormDialogState extends ConsumerState<SessionFormDialog> {
  final _formKey = GlobalKey<FormState>();

  ClientModel? _selectedClient;
  late DateTime _fechaCita;

  static const List<String> _treatmentOptions = [
    'Microblading',
    'Micropigmentación',
    'Nanoblading',
    'Laminado con Químicos Fuertes',
    'Tatuaje Cosmético',
    'Diseño y Perfilado de Cejas',
    'Depilación con Hilo',
    'Lifting de Pestañas',
    'Hidratación / Tratamiento Spa',
  ];

  late String _selectedTreatment;

  String _pigmentTone = 'Castaño Medio';
  String _needleType = 'Microblading 18U';
  bool _usedTopicalAnesthesia = true;
  bool _allergyPatchDone = true;

  final TextEditingController _notesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedClient = widget.preselectedClient;
    _fechaCita = DateTime.now();
    _selectedTreatment = _treatmentOptions.first;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _fechaCita,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_fechaCita),
      );

      if (pickedTime != null && mounted) {
        setState(() {
          _fechaCita = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _submit(MedicalCompatibilityResult compatibility) async {
    if (_selectedClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe seleccionar un cliente'), backgroundColor: AppColors.alertPureRed),
      );
      return;
    }

    if (compatibility.isBlocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('BLOQUEO DE SEGURIDAD: Tratamiento contraindicado por alertas médicas.'),
          backgroundColor: AppColors.alertPureRed,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final session = SessionModel(
        idSesion: '',
        idCliente: _selectedClient!.id,
        fechaCita: _fechaCita,
        tipoTratamiento: _selectedTreatment,
        detallesTratamiento: {
          'tono_pigmento': _pigmentTone,
          'tipo_aguja_o_tecnica': _needleType,
          'anestesia_topica_aplicada': _usedTopicalAnesthesia,
          'prueba_alergia_previa': _allergyPatchDone,
        },
        urlFirma: '',
        urlsFotos: const [],
        notasInternas: _notesController.text.trim(),
      );

      final newId = await ref.read(sessionsControllerProvider.notifier).createSession(session);

      if (mounted) {
        Navigator.of(context).pop(newId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sesión programada y registrada con éxito.'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear sesión: ${e.toString()}'), backgroundColor: AppColors.alertPureRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final clientsAsync = ref.watch(clientsListProvider);

    final compatibility = _selectedClient != null
        ? MedicalAlertChecker.checkCompatibility(
            tratamiento: _selectedTreatment,
            alertasMedicas: _selectedClient!.alertasMedicas,
          )
        : const MedicalCompatibilityResult.compatible();

    final dateFormat = DateFormat('EEEE dd/MM/yyyy · hh:mm a');

    return Dialog(
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620, maxHeight: 760),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Registrar Cita / Sesión de Tratamiento',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Colección sesiones independiente con verificación de seguridad',
                          style: GoogleFonts.montserrat(fontSize: 12, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.divider),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '1. CLIENTE',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (widget.preselectedClient != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.person, color: AppColors.primary),
                              const SizedBox(width: 10),
                              Text(
                                widget.preselectedClient!.nombre,
                                style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                            ],
                          ),
                        )
                      else
                        clientsAsync.when(
                          data: (clients) {
                            return DropdownButtonFormField<ClientModel>(
                              initialValue: _selectedClient,
                              decoration: const InputDecoration(
                                labelText: 'Seleccionar Cliente *',
                                prefixIcon: Icon(Icons.person_search_outlined),
                              ),
                              items: clients.map((c) {
                                return DropdownMenuItem<ClientModel>(
                                  value: c,
                                  child: Text('${c.nombre} (${c.telefono})'),
                                );
                              }).toList(),
                              onChanged: (c) => setState(() => _selectedClient = c),
                              validator: (c) => c == null ? 'Seleccione un cliente' : null,
                            );
                          },
                          loading: () => const LinearProgressIndicator(),
                          error: (e, _) => Text('Error al cargar lista de clientes: $e'),
                        ),
                      const SizedBox(height: 20),
                      Text(
                        '2. FECHA Y HORA DE LA CITA',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _pickDateTime,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.primary),
                                  const SizedBox(width: 12),
                                  Text(
                                    dateFormat.format(_fechaCita),
                                    style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                              const Icon(Icons.edit, size: 16, color: AppColors.textMuted),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        '3. TIPO DE TRATAMIENTO',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedTreatment,
                        decoration: const InputDecoration(
                          labelText: 'Tratamiento *',
                          prefixIcon: Icon(Icons.spa_outlined),
                        ),
                        items: _treatmentOptions.map((t) {
                          return DropdownMenuItem<String>(value: t, child: Text(t));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedTreatment = val);
                        },
                      ),
                      const SizedBox(height: 16),
                      if (compatibility.isBlocked) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.alertBackground,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.alertPureRed, width: 1.5),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.block, color: AppColors.alertPureRed, size: 24),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'BLOQUEO DE SEGURIDAD MÉDICA',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.alertPureRed,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      compatibility.message ?? 'Tratamiento incompatible con alertas médicas del cliente.',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 12,
                                        color: AppColors.alertPureRed,
                                        height: 1.3,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'El botón de guardado ha sido inhabilitado de acuerdo al protocolo médico estricto de Fase 1.',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.alertPureRed,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ] else if (compatibility.hasWarning) ...[
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF8E1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFFFB300)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline, color: Color(0xFFE65100), size: 22),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  compatibility.message ?? '',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    color: const Color(0xFFE65100),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                      Text(
                        '4. PARÁMETROS TÉCNICOS (ESTANDARIZADOS)',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _pigmentTone,
                        decoration: const InputDecoration(labelText: 'Tono de Pigmento'),
                        items: const [
                          DropdownMenuItem(value: 'Castaño Claro', child: Text('Castaño Claro')),
                          DropdownMenuItem(value: 'Castaño Medio', child: Text('Castaño Medio')),
                          DropdownMenuItem(value: 'Castaño Oscuro', child: Text('Castaño Oscuro')),
                          DropdownMenuItem(value: 'Ébano / Negro Suave', child: Text('Ébano / Negro Suave')),
                          DropdownMenuItem(value: 'No Aplica', child: Text('No Aplica')),
                        ],
                        onChanged: (val) => setState(() => _pigmentTone = val!),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _needleType,
                        decoration: const InputDecoration(labelText: 'Técnica / Aguja'),
                        items: const [
                          DropdownMenuItem(value: 'Microblading 18U', child: Text('Microblading 18U Flex')),
                          DropdownMenuItem(value: 'Shading 3RL', child: Text('Shading / Sombreado 3RL')),
                          DropdownMenuItem(value: 'Micropigmentación 1R', child: Text('Micropigmentación 1R')),
                          DropdownMenuItem(value: 'Nano Aguja 0.18mm', child: Text('Nano Aguja 0.18mm')),
                          DropdownMenuItem(value: 'No Aplica', child: Text('No Aplica')),
                        ],
                        onChanged: (val) => setState(() => _needleType = val!),
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text('Anestésico Tópico Aplicado', style: GoogleFonts.montserrat(fontSize: 13)),
                        value: _usedTopicalAnesthesia,
                        onChanged: (v) => setState(() => _usedTopicalAnesthesia = v),
                      ),
                      SwitchListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text('Prueba de Sensibilidad / Alergia Conforme', style: GoogleFonts.montserrat(fontSize: 13)),
                        value: _allergyPatchDone,
                        onChanged: (v) => setState(() => _allergyPatchDone = v),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '5. NOTAS INTERNAS DE LA SESIÓN',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'Observaciones técnicas exclusivas de la administradora...',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(height: 1, color: AppColors.divider),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: (_isSubmitting || compatibility.isBlocked)
                        ? null
                        : () => _submit(compatibility),
                    style: compatibility.isBlocked
                        ? ElevatedButton.styleFrom(
                            backgroundColor: AppColors.disabledBackground,
                            foregroundColor: AppColors.textMuted,
                          )
                        : null,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onPrimary),
                          )
                        : Text(compatibility.isBlocked ? 'Bloqueado por Salud' : 'Guardar Sesión'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
