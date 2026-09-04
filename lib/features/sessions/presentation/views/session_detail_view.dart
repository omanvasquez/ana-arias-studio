import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ana_arias_studio/core/constants/app_colors.dart';
import 'package:ana_arias_studio/features/clients/domain/client_model.dart';
import 'package:ana_arias_studio/features/clients/presentation/controllers/clients_controller.dart';
import 'package:ana_arias_studio/features/sessions/domain/session_model.dart';
import 'package:ana_arias_studio/features/kiosk_signature/presentation/views/kiosk_signature_view.dart';
import 'package:ana_arias_studio/features/photos/presentation/views/photo_upload_sheet.dart';
import 'package:ana_arias_studio/shared/widgets/smart_image.dart';
import 'package:ana_arias_studio/shared/providers/firebase_providers.dart';

class SessionDetailView extends ConsumerWidget {
  final SessionModel session;
  final ClientModel? client;

  const SessionDetailView({
    super.key,
    required this.session,
    this.client,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsRepo = ref.watch(sessionsRepositoryProvider);
    final clientAsync = ref.watch(clientDetailProvider(session.idCliente));
    final resolvedClient = client ?? clientAsync.value;

    final dateFormat = DateFormat('EEEE dd/MM/yyyy · hh:mm a');

    return StreamBuilder<SessionModel?>(
      stream: sessionsRepo.streamSessionsByClient(session.idCliente).map((list) {
        try {
          return list.firstWhere((s) => s.idSesion == session.idSesion);
        } catch (_) {
          return null;
        }
      }),
      initialData: session,
      builder: (context, snapshot) {
        final currentSession = snapshot.data ?? session;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(currentSession.tipoTratamiento),
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
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceMuted,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.spa, color: AppColors.primary, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currentSession.tipoTratamiento,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    dateFormat.format(currentSession.fechaCita),
                                    style: GoogleFonts.montserrat(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: AppColors.divider),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.person_outline, size: 18, color: AppColors.textMuted),
                            const SizedBox(width: 8),
                            Text(
                              'Cliente: ',
                              style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              resolvedClient?.nombre ?? 'Cargando datos...',
                              style: GoogleFonts.montserrat(fontSize: 13, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        if (resolvedClient != null && resolvedClient.telefono.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.phone_outlined, size: 18, color: AppColors.textMuted),
                              const SizedBox(width: 8),
                              Text(
                                'Teléfono: ',
                                style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                resolvedClient.telefono,
                                style: GoogleFonts.montserrat(fontSize: 13, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 16),
                        Text(
                          'PARÁMETROS TÉCNICOS REGISTRADOS',
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: currentSession.detallesTratamiento.entries.map((e) {
                            String label = e.key.replaceAll('_', ' ').toUpperCase();
                            String val = e.value is bool ? (e.value ? 'Sí' : 'No') : e.value.toString();
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceMuted,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Text(
                                '$label: $val',
                                style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w500),
                              ),
                            );
                          }).toList(),
                        ),
                        if (currentSession.notasInternas.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(
                            'NOTAS DE LA ADMINISTRADORA',
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(
                              currentSession.notasInternas,
                              style: GoogleFonts.montserrat(fontSize: 12, height: 1.4),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.draw_outlined, color: AppColors.primary, size: 22),
                                const SizedBox(width: 10),
                                Text(
                                  'CONSENTIMIENTO Y FIRMA DIGITAL',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            if (currentSession.hasSignature)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Firma Registrada',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.success,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        if (currentSession.hasSignature) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              children: [
                                SmartImage(
                                  source: currentSession.urlFirma,
                                  height: 120,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Firma digital PNG con fondo transparente registrada en Modo Kiosco.',
                                  style: GoogleFonts.montserrat(fontSize: 11, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          Text(
                            'El cliente debe firmar su consentimiento en la pantalla táctil mediante el Modo Kiosco antes de iniciar el tratamiento.',
                            style: GoogleFonts.montserrat(fontSize: 12, color: AppColors.textMuted),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (ctx) => KioskSignatureView(
                                      clientId: currentSession.idCliente,
                                      clientName: resolvedClient?.nombre ?? 'Cliente',
                                      sessionId: currentSession.idSesion,
                                      treatmentName: currentSession.tipoTratamiento,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.touch_app_outlined),
                              label: const Text('Iniciar Firma Digital (Modo Kiosco)'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.photo_library_outlined, color: AppColors.primary, size: 22),
                                const SizedBox(width: 10),
                                Text(
                                  'FOTOGRAFÍAS (ANTES Y DESPUÉS)',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                PhotoUploadSheet.show(
                                  context,
                                  clientId: currentSession.idCliente,
                                  sessionId: currentSession.idSesion,
                                );
                              },
                              icon: const Icon(Icons.add_a_photo_outlined, size: 16),
                              label: const Text('Adjuntar Foto'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        if (currentSession.urlsFotos.isEmpty) ...[
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                'No se han registrado fotografías para esta sesión.',
                                style: GoogleFonts.montserrat(fontSize: 12, color: AppColors.textMuted),
                              ),
                            ),
                          ),
                        ] else ...[
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1.2,
                            ),
                            itemCount: currentSession.urlsFotos.length,
                            itemBuilder: (ctx, i) {
                              final photoUrl = currentSession.urlsFotos[i];
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: SmartImage(
                                  source: photoUrl,
                                  fit: BoxFit.cover,
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
