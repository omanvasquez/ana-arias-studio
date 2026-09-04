import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ana_arias_studio/core/constants/app_colors.dart';
import 'package:ana_arias_studio/features/clients/domain/client_model.dart';
import 'package:ana_arias_studio/features/clients/domain/medical_alert_model.dart';
import 'package:ana_arias_studio/features/clients/presentation/controllers/clients_controller.dart';
import 'package:ana_arias_studio/features/sessions/presentation/controllers/sessions_controller.dart';
import 'package:ana_arias_studio/features/sessions/presentation/views/session_detail_view.dart';
import 'package:ana_arias_studio/features/sessions/presentation/views/session_form_dialog.dart';
import 'package:ana_arias_studio/features/clients/presentation/views/client_form_dialog.dart';

class ClientDetailView extends ConsumerWidget {
  final ClientModel client;

  const ClientDetailView({super.key, required this.client});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientAsync = ref.watch(clientDetailProvider(client.id));
    final currentClient = clientAsync.value ?? client;
    final sessionsAsync = ref.watch(clientSessionsProvider(client.id));
    final hasAlerts = currentClient.hasActiveAlerts;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(currentClient.nombre),
        actions: [
          IconButton(
            tooltip: 'Editar Ficha',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => ClientFormDialog(initialClient: currentClient),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: hasAlerts ? AppColors.alertBackground : AppColors.surfaceMuted,
                          child: Text(
                            currentClient.nombre.isNotEmpty ? currentClient.nombre.trim()[0].toUpperCase() : '?',
                            style: GoogleFonts.montserrat(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: hasAlerts ? AppColors.alertPureRed : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentClient.nombre,
                                style: GoogleFonts.montserrat(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.phone_outlined, size: 14, color: AppColors.textMuted),
                                  const SizedBox(width: 6),
                                  Text(
                                    currentClient.telefono,
                                    style: GoogleFonts.montserrat(fontSize: 13, color: AppColors.textSecondary),
                                  ),
                                  if (currentClient.email.isNotEmpty) ...[
                                    const SizedBox(width: 16),
                                    const Icon(Icons.email_outlined, size: 14, color: AppColors.textMuted),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        currentClient.email,
                                        style: GoogleFonts.montserrat(fontSize: 13, color: AppColors.textSecondary),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: AppColors.divider),
                    const SizedBox(height: 12),
                    if (hasAlerts) ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.alertBackground,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.alertBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.warning_rounded, color: AppColors.alertPureRed, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'CONTRAINDICACIONES MÉDICAS DETECTADAS',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.alertPureRed,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: currentClient.activeAlertKeys.map((k) {
                                return Chip(
                                  backgroundColor: AppColors.surface,
                                  side: const BorderSide(color: AppColors.alertBorder),
                                  label: Text(
                                    MedicalAlertKeys.getLabel(k),
                                    style: GoogleFonts.montserrat(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.alertPureRed,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'El sistema aplicará un bloqueo duro en la creación de tratamientos de alto riesgo (Microblading, Micropigmentación, etc.).',
                              style: GoogleFonts.montserrat(
                                fontSize: 11,
                                color: AppColors.alertPureRed.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      Row(
                        children: [
                          const Icon(Icons.check_circle_outline, color: AppColors.success, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Sin contraindicaciones médicas registradas',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              color: AppColors.success,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HISTORIAL DE SESIONES',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Documentos independientes en colección sesiones',
                      style: GoogleFonts.montserrat(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => SessionFormDialog(preselectedClient: currentClient),
                    );
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Nueva Sesión'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            sessionsAsync.when(
              data: (sessions) {
                if (sessions.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(Icons.event_note_outlined, size: 40, color: AppColors.textMuted),
                            const SizedBox(height: 12),
                            Text(
                              'No hay sesiones registradas para este cliente',
                              style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Inicia una nueva sesión para registrar tratamiento, firma y fotografías.',
                              style: GoogleFonts.montserrat(fontSize: 11, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sessions.length,
                  separatorBuilder: (ctx, i) => const SizedBox(height: 10),
                  itemBuilder: (ctx, i) {
                    final session = sessions[i];
                    final dateFormat = DateFormat('dd/MM/yyyy · hh:mm a');

                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.spa_outlined, color: AppColors.primary),
                        ),
                        title: Text(
                          session.tipoTratamiento,
                          style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              dateFormat.format(session.fechaCita),
                              style: GoogleFonts.montserrat(fontSize: 12, color: AppColors.textMuted),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: session.hasSignature
                                        ? AppColors.success.withValues(alpha: 0.1)
                                        : AppColors.alertBackground,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        session.hasSignature ? Icons.draw : Icons.edit_note,
                                        size: 12,
                                        color: session.hasSignature ? AppColors.success : AppColors.alertPureRed,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        session.hasSignature ? 'Firma OK' : 'Sin Firma',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: session.hasSignature ? AppColors.success : AppColors.alertPureRed,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceMuted,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.photo_camera_outlined, size: 12, color: AppColors.textSecondary),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${session.urlsFotos.length} fotos',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 10,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (ctx) => SessionDetailView(session: session, client: currentClient),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Text('Error al cargar historial: $err'),
            ),
          ],
        ),
      ),
    );
  }
}
