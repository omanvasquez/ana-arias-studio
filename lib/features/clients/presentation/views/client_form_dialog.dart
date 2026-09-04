import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ana_arias_studio/core/constants/app_colors.dart';
import 'package:ana_arias_studio/features/clients/domain/client_model.dart';
import 'package:ana_arias_studio/features/clients/domain/medical_alert_model.dart';
import 'package:ana_arias_studio/features/clients/presentation/controllers/clients_controller.dart';
import 'package:ana_arias_studio/shared/providers/firebase_providers.dart';

class ClientFormDialog extends ConsumerStatefulWidget {
  final ClientModel? initialClient;

  const ClientFormDialog({super.key, this.initialClient});

  @override
  ConsumerState<ClientFormDialog> createState() => _ClientFormDialogState();
}

class _ClientFormDialogState extends ConsumerState<ClientFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;

  late final Map<String, bool> _alertas;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialClient?.nombre ?? '');
    _phoneController = TextEditingController(text: widget.initialClient?.telefono ?? '');
    _emailController = TextEditingController(text: widget.initialClient?.email ?? '');

    _alertas = {};
    for (final key in MedicalAlertKeys.allKeys) {
      _alertas[key] = widget.initialClient?.alertasMedicas[key] ?? false;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      if (widget.initialClient == null) {
        await ref.read(clientsControllerProvider.notifier).createClient(
              nombre: _nameController.text.trim(),
              telefono: _phoneController.text.trim(),
              email: _emailController.text.trim(),
              alertasMedicas: _alertas,
            );
      } else {
        final updated = widget.initialClient!.copyWith(
          nombre: _nameController.text.trim(),
          telefono: _phoneController.text.trim(),
          email: _emailController.text.trim(),
          alertasMedicas: _alertas,
        );
        await ref.read(clientsRepositoryProvider).updateClient(updated);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.initialClient == null ? 'Cliente registrado exitosamente.' : 'Ficha actualizada.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.alertPureRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialClient != null;

    return Dialog(
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580, maxHeight: 720),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                          isEditing ? 'Editar Ficha de Cliente' : 'Nuevo Registro de Cliente',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Datos básicos y ficha de contraindicaciones médicas',
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
                        'INFORMACIÓN BÁSICA',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre Completo *',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingrese el nombre' : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                labelText: 'Teléfono *',
                                prefixIcon: Icon(Icons.phone_outlined),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingrese el teléfono' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'Correo Electrónico',
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          const Icon(Icons.medical_information_outlined, size: 20, color: AppColors.alertPureRed),
                          const SizedBox(width: 8),
                          Text(
                            'ALERTAS MÉDICAS (ESTANDARIZADAS)',
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: AppColors.alertPureRed,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Marque las condiciones aplicables. Un diagnóstico positivo bloqueará automáticamente tratamientos de alto riesgo.',
                        style: GoogleFonts.montserrat(fontSize: 11, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: MedicalAlertKeys.allKeys.map((key) {
                            final isActive = _alertas[key] ?? false;
                            final label = MedicalAlertKeys.getLabel(key);
                            final isLast = key == MedicalAlertKeys.allKeys.last;

                            return Column(
                              children: [
                                SwitchListTile(
                                  dense: true,
                                  title: Text(
                                    label,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 13,
                                      fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                                      color: isActive ? AppColors.alertPureRed : AppColors.textPrimary,
                                    ),
                                  ),
                                  value: isActive,
                                  activeThumbColor: AppColors.alertPureRed,
                                  activeTrackColor: AppColors.alertBackground,
                                  onChanged: (val) {
                                    setState(() => _alertas[key] = val);
                                  },
                                ),
                                if (!isLast) const Divider(height: 1, color: AppColors.divider),
                              ],
                            );
                          }).toList(),
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
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onPrimary),
                          )
                        : Text(isEditing ? 'Guardar Cambios' : 'Registrar Cliente'),
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
